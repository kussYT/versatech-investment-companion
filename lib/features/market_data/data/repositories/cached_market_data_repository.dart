import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/datasources/local_market_data_source.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/remote_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_sync_record.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';

class CachedMarketDataRepository implements MarketDataRepository {
  CachedMarketDataRepository({
    required MarketDataRemote remote,
    required LocalMarketDataSource local,
    required CachePolicy policy,
    required Clock clock,
  })  : _remote = remote,
        _local = local,
        _policy = policy,
        _clock = clock;

  final MarketDataRemote _remote;
  final LocalMarketDataSource _local;
  final CachePolicy _policy;
  final Clock _clock;

  @override
  Future<CachedResult<List<Asset>>> searchAssets(
    String query, {
    bool forceRefresh = false,
  }) async {
    final normalizedQuery = requiredSearchQuery(query);
    final resourceKey = CacheResourceKeys.search(normalizedQuery);
    final metadata = await _local.readMetadata(resourceKey);
    final fresh = _isFresh(metadata?.lastSyncedAt, _policy.searchMaxAge);

    if (!forceRefresh && fresh && metadata != null) {
      return CachedResult(
        data: await _storedSearch(metadata),
        origin: DataOrigin.cache,
        lastUpdatedAt: metadata.lastSyncedAt,
        isStale: false,
      );
    }

    try {
      final remoteAssets = _normalizeAssets(
        await _remote.searchAssets(normalizedQuery),
      );
      final syncedAt = _clock.now().toUtc();
      await _local.saveAssets(
        assets: remoteAssets,
        syncedAt: syncedAt,
        resourceKey: resourceKey,
        symbolList: remoteAssets.map((asset) => asset.symbol).join(','),
      );
      return CachedResult(
        data: remoteAssets,
        origin: DataOrigin.remote,
        lastUpdatedAt: syncedAt,
        isStale: false,
      );
    } on AppException catch (error) {
      if (!_canServeCache(error)) {
        rethrow;
      }
      final cached = await _local.searchAssets(normalizedQuery);
      if (cached.isEmpty) {
        rethrow;
      }
      return CachedResult(
        data: cached,
        origin: DataOrigin.cache,
        lastUpdatedAt: metadata?.lastSyncedAt,
        isStale: true,
        remoteFailure: error.failure,
      );
    }
  }

  @override
  Future<CachedResult<AssetProfile>> getProfile(
    String symbol, {
    bool forceRefresh = false,
  }) {
    final normalized = requiredSymbol(symbol);
    return _load(
      resourceKey: CacheResourceKeys.profile(normalized),
      maxAge: _policy.profileMaxAge,
      forceRefresh: forceRefresh,
      readLocal: () => _local.readProfile(normalized),
      readRemote: () => _remote.getProfile(normalized),
      save: (profile, syncedAt) => _local.saveProfile(
        _withSymbol(profile, normalized),
        syncedAt,
      ),
    );
  }

  @override
  Future<CachedResult<MarketQuote>> getQuote(
    String symbol, {
    bool forceRefresh = false,
  }) {
    final normalized = requiredSymbol(symbol);
    return _load(
      resourceKey: CacheResourceKeys.quote(normalized),
      maxAge: _policy.quoteMaxAge,
      forceRefresh: forceRefresh,
      readLocal: () => _local.readQuote(normalized),
      readRemote: () => _remote.getQuote(normalized),
      save: (quote, syncedAt) => _local.saveQuote(
        _withQuoteSymbol(quote, normalized),
        syncedAt,
      ),
    );
  }

  @override
  Future<CachedResult<List<HistoricalPrice>>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
    bool forceRefresh = false,
  }) async {
    final normalized = requiredSymbol(symbol);
    final start = calendarDate(from);
    final end = calendarDate(to);
    if (start.isAfter(end)) {
      throw InvalidMarketDataException('The historical range is reversed.');
    }

    final local = await _local.readHistory(
      symbol: normalized,
      from: start,
      to: end,
    );
    final metadata = await _local.readMetadata(
      CacheResourceKeys.history(normalized),
    );
    final fresh = _isFresh(metadata?.lastSyncedAt, _policy.historyMaxAge);
    final covered = _rangeIsCovered(metadata, start, end);

    if (!forceRefresh && fresh && covered) {
      return CachedResult(
        data: local,
        origin: DataOrigin.cache,
        lastUpdatedAt: metadata?.lastSyncedAt,
        isStale: false,
      );
    }

    final ranges = !forceRefresh && fresh
        ? _missingEdges(metadata, start, end)
        : [_DateRange(start, end)];

    try {
      final fetched = <HistoricalPrice>[];
      for (final range in ranges) {
        final rows = await _remote.getHistoricalPrices(
          symbol: normalized,
          from: range.from,
          to: range.to,
        );
        fetched.addAll(_acceptedBars(rows, normalized));
      }
      final syncedAt = _clock.now().toUtc();
      final coverageFrom = _earliest(metadata?.oldestDataAt, start);
      final coverageTo = _latest(metadata?.newestDataAt, end);
      await _local.saveHistory(
        symbol: normalized,
        prices: fetched,
        syncedAt: syncedAt,
        coverageFrom: coverageFrom,
        coverageTo: coverageTo,
      );
      final merged = await _local.readHistory(
        symbol: normalized,
        from: start,
        to: end,
      );
      return CachedResult(
        data: merged,
        origin: DataOrigin.remote,
        lastUpdatedAt: syncedAt,
        isStale: false,
      );
    } on AppException catch (error) {
      if (_canServeCache(error) && local.isNotEmpty) {
        return CachedResult(
          data: local,
          origin: DataOrigin.cache,
          lastUpdatedAt: metadata?.lastSyncedAt,
          isStale: true,
          remoteFailure: error.failure,
        );
      }
      rethrow;
    }
  }

  Future<CachedResult<T>> _load<T>({
    required String resourceKey,
    required Duration maxAge,
    required bool forceRefresh,
    required Future<T?> Function() readLocal,
    required Future<T> Function() readRemote,
    required Future<void> Function(T value, DateTime syncedAt) save,
  }) async {
    final local = await readLocal();
    final metadata = await _local.readMetadata(resourceKey);
    final fresh = _isFresh(metadata?.lastSyncedAt, maxAge);

    if (!forceRefresh && fresh && local != null) {
      return CachedResult(
        data: local,
        origin: DataOrigin.cache,
        lastUpdatedAt: metadata?.lastSyncedAt,
        isStale: false,
      );
    }

    try {
      final remoteValue = await readRemote();
      final syncedAt = _clock.now().toUtc();
      await save(remoteValue, syncedAt);
      final stored = await readLocal();
      if (stored == null) {
        throw InvalidMarketDataException(
          'The remote value could not be stored.',
        );
      }
      return CachedResult(
        data: stored,
        origin: DataOrigin.remote,
        lastUpdatedAt: syncedAt,
        isStale: false,
      );
    } on AppException catch (error) {
      if (_canServeCache(error) && local != null) {
        return CachedResult(
          data: local,
          origin: DataOrigin.cache,
          lastUpdatedAt: metadata?.lastSyncedAt,
          isStale: true,
          remoteFailure: error.failure,
        );
      }
      rethrow;
    }
  }

  bool _isFresh(DateTime? lastSyncedAt, Duration maxAge) {
    return _policy.isFresh(
      lastSyncedAt: lastSyncedAt,
      maxAge: maxAge,
      now: _clock.now(),
    );
  }

  bool _canServeCache(AppException error) {
    return error is NetworkUnavailableException ||
        error is RequestTimeoutException ||
        error is RateLimitException ||
        error is UnknownRemoteException ||
        error is MissingApiKeyException ||
        error is UnauthorizedException;
  }

  Future<List<Asset>> _storedSearch(CacheSyncRecord metadata) {
    final detail = metadata.detail;
    if (detail == null || detail.isEmpty) {
      return Future.value(const []);
    }
    return _local.assetsBySymbols(detail.split(','));
  }

  List<Asset> _normalizeAssets(List<Asset> assets) {
    return [
      for (final asset in assets)
        Asset(
          symbol: requiredSymbol(asset.symbol),
          name: asset.name,
          type: asset.type,
          exchange: asset.exchange,
          currency: asset.currency,
        ),
    ];
  }

  AssetProfile _withSymbol(AssetProfile profile, String symbol) {
    if (normalizeSymbol(profile.symbol) != symbol) {
      throw InvalidMarketDataException(
        'The response symbol does not match the request.',
      );
    }
    return AssetProfile(
      symbol: symbol,
      companyName: profile.companyName,
      description: profile.description,
      sector: profile.sector,
      industry: profile.industry,
      website: profile.website,
      imageUrl: profile.imageUrl,
      currency: profile.currency,
      exchange: profile.exchange,
    );
  }

  MarketQuote _withQuoteSymbol(MarketQuote quote, String symbol) {
    if (normalizeSymbol(quote.symbol) != symbol) {
      throw InvalidMarketDataException(
        'The response symbol does not match the request.',
      );
    }
    return MarketQuote(
      symbol: symbol,
      price: quote.price,
      change: quote.change,
      changePercent: quote.changePercent,
      previousClose: quote.previousClose,
      timestamp: quote.timestamp,
    );
  }

  List<HistoricalPrice> _acceptedBars(
    List<HistoricalPrice> prices,
    String symbol,
  ) {
    return [
      for (final price in prices)
        if (normalizeSymbol(price.symbol) == symbol)
          HistoricalPrice(
            symbol: symbol,
            date: calendarDate(price.date),
            open: price.open,
            high: price.high,
            low: price.low,
            close: price.close,
            volume: price.volume,
          ),
    ];
  }

  bool _rangeIsCovered(CacheSyncRecord? metadata, DateTime from, DateTime to) {
    final oldest = metadata?.oldestDataAt;
    final newest = metadata?.newestDataAt;
    if (oldest == null || newest == null) {
      return false;
    }
    final start = calendarDate(oldest);
    final end = calendarDate(newest);
    return !from.isBefore(start) && !to.isAfter(end);
  }

  List<_DateRange> _missingEdges(
    CacheSyncRecord? metadata,
    DateTime from,
    DateTime to,
  ) {
    final oldest = metadata?.oldestDataAt;
    final newest = metadata?.newestDataAt;
    if (oldest == null || newest == null) {
      return [_DateRange(from, to)];
    }

    final ranges = <_DateRange>[];
    final storedStart = calendarDate(oldest);
    final storedEnd = calendarDate(newest);
    if (from.isBefore(storedStart)) {
      ranges.add(
        _DateRange(from, storedStart.subtract(const Duration(days: 1))),
      );
    }
    if (to.isAfter(storedEnd)) {
      ranges.add(_DateRange(storedEnd.add(const Duration(days: 1)), to));
    }
    return [
      for (final range in ranges)
        if (!range.from.isAfter(range.to)) range,
    ];
  }

  DateTime _earliest(DateTime? current, DateTime candidate) {
    if (current == null || candidate.isBefore(calendarDate(current))) {
      return candidate;
    }
    return calendarDate(current);
  }

  DateTime _latest(DateTime? current, DateTime candidate) {
    if (current == null || candidate.isAfter(calendarDate(current))) {
      return candidate;
    }
    return calendarDate(current);
  }
}

class _DateRange {
  const _DateRange(this.from, this.to);

  final DateTime from;
  final DateTime to;
}

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final cachePolicyProvider = Provider<CachePolicy>((ref) {
  return const CachePolicy();
});

final marketDataRepositoryProvider = Provider<MarketDataRepository>((ref) {
  return CachedMarketDataRepository(
    remote: ref.watch(remoteMarketDataRepositoryProvider),
    local: ref.watch(localMarketDataSourceProvider),
    policy: ref.watch(cachePolicyProvider),
    clock: ref.watch(clockProvider),
  );
});
