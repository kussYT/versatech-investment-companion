import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/app_database_provider.dart';
import 'package:versatech_investment_companion/core/database/daos/market_data_dao.dart';
import 'package:versatech_investment_companion/core/database/financial_values.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_sync_record.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

class LocalMarketDataSource {
  LocalMarketDataSource(this._dao);

  final MarketDataDao _dao;

  Future<void> saveAssets({
    required List<Asset> assets,
    required DateTime syncedAt,
    required String resourceKey,
    required String symbolList,
  }) {
    final storedAt = syncedAt.toUtc();
    return _dao.saveAssetsWithMetadata(
      assets: [
        for (final asset in assets) _assetCompanion(asset, storedAt),
      ],
      metadata: CacheMetadataCompanion.insert(
        resourceKey: resourceKey,
        lastSyncedAt: storedAt,
        status: 'synced',
        detail: Value(symbolList),
      ),
    );
  }

  Future<List<Asset>> searchAssets(String query) async {
    final rows = await _dao.searchAssets(query);
    return [for (final row in rows) _assetFromRow(row)];
  }

  Future<List<Asset>> assetsBySymbols(List<String> symbols) async {
    final rows = await _dao.assetsBySymbols(symbols);
    final bySymbol = {for (final row in rows) row.symbol: _assetFromRow(row)};
    return [
      for (final symbol in symbols)
        if (bySymbol[symbol] != null) bySymbol[symbol]!,
    ];
  }

  Future<Asset?> findAsset(String symbol) async {
    final row = await _dao.findAsset(normalizeSymbol(symbol));
    if (row == null) {
      return null;
    }
    return _assetFromRow(row);
  }

  Future<void> saveProfile(AssetProfile profile, DateTime syncedAt) {
    final symbol = normalizeSymbol(profile.symbol);
    final storedAt = syncedAt.toUtc();
    return _dao.saveProfileWithMetadata(
      profile: CachedAssetProfilesCompanion.insert(
        symbol: symbol,
        companyName: profile.companyName,
        description: profile.description,
        currency: profile.currency,
        exchange: profile.exchange,
        updatedAt: storedAt,
        sector: Value(profile.sector),
        industry: Value(profile.industry),
        website: Value(profile.website),
        imageUrl: Value(profile.imageUrl),
      ),
      metadata: CacheMetadataCompanion.insert(
        resourceKey: CacheResourceKeys.profile(symbol),
        lastSyncedAt: storedAt,
        newestDataAt: Value(storedAt),
        status: 'synced',
      ),
    );
  }

  Future<AssetProfile?> readProfile(String symbol) async {
    final row = await _dao.findProfile(normalizeSymbol(symbol));
    if (row == null) {
      return null;
    }
    return AssetProfile(
      symbol: row.symbol,
      companyName: row.companyName,
      description: row.description,
      sector: row.sector,
      industry: row.industry,
      website: row.website,
      imageUrl: row.imageUrl,
      currency: row.currency,
      exchange: row.exchange,
    );
  }

  Future<void> saveQuote(MarketQuote quote, DateTime syncedAt) {
    final symbol = normalizeSymbol(quote.symbol);
    final storedAt = syncedAt.toUtc();
    return _dao.saveQuoteWithMetadata(
      quote: CachedMarketQuotesCompanion.insert(
        symbol: symbol,
        price: FinancialValues.toSql(quote.price),
        priceChange: FinancialValues.toSql(quote.change),
        changePercent: FinancialValues.toSql(quote.changePercent),
        quotedAt: quote.timestamp.toUtc(),
        fetchedAt: storedAt,
        previousClose: Value(
          quote.previousClose == null
              ? null
              : FinancialValues.toSql(quote.previousClose!),
        ),
      ),
      metadata: CacheMetadataCompanion.insert(
        resourceKey: CacheResourceKeys.quote(symbol),
        lastSyncedAt: storedAt,
        newestDataAt: Value(quote.timestamp.toUtc()),
        status: 'synced',
      ),
    );
  }

  Future<MarketQuote?> readQuote(String symbol) async {
    final row = await _dao.findQuote(normalizeSymbol(symbol));
    if (row == null) {
      return null;
    }
    return MarketQuote(
      symbol: row.symbol,
      price: FinancialValues.fromSql(row.price),
      change: FinancialValues.fromSql(row.priceChange),
      changePercent: FinancialValues.fromSql(row.changePercent),
      previousClose: FinancialValues.fromSqlNullable(row.previousClose),
      timestamp: row.quotedAt.toUtc(),
    );
  }

  Future<void> saveHistory({
    required String symbol,
    required List<HistoricalPrice> prices,
    required DateTime syncedAt,
    required DateTime coverageFrom,
    required DateTime coverageTo,
  }) {
    final normalized = normalizeSymbol(symbol);
    final storedAt = syncedAt.toUtc();
    return _dao.saveHistoricalPricesWithMetadata(
      symbol: normalized,
      syncedAt: storedAt,
      resourceKey: CacheResourceKeys.history(normalized),
      coverageFrom: calendarDate(coverageFrom),
      coverageTo: calendarDate(coverageTo),
      prices: [
        for (final price in prices)
          CachedHistoricalPricesCompanion.insert(
            symbol: normalized,
            quoteDate: calendarDate(price.date),
            open: FinancialValues.toSql(price.open),
            high: FinancialValues.toSql(price.high),
            low: FinancialValues.toSql(price.low),
            close: FinancialValues.toSql(price.close),
            volume: price.volume,
            fetchedAt: storedAt,
          ),
      ],
    );
  }

  Future<List<HistoricalPrice>> readHistory({
    required String symbol,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _dao.historicalPrices(
      symbol: normalizeSymbol(symbol),
      from: calendarDate(from),
      to: calendarDate(to),
    );
    return [for (final row in rows) _historyFromRow(row)];
  }

  Future<({DateTime? oldest, DateTime? newest})> historyBounds(String symbol) {
    return _dao.historyBounds(normalizeSymbol(symbol));
  }

  Future<CacheSyncRecord?> readMetadata(String resourceKey) async {
    final row = await _dao.findMetadata(resourceKey);
    if (row == null) {
      return null;
    }
    return CacheSyncRecord(
      resourceKey: row.resourceKey,
      lastSyncedAt: row.lastSyncedAt.toUtc(),
      newestDataAt: row.newestDataAt?.toUtc(),
      oldestDataAt: row.oldestDataAt?.toUtc(),
      status: row.status,
      detail: row.detail,
    );
  }

  Future<void> deleteSymbolCache(String symbol) {
    return _dao.deleteSymbolCache(normalizeSymbol(symbol));
  }

  Future<void> deleteMetadata(String resourceKey) {
    return _dao.deleteMetadata(resourceKey);
  }

  CachedAssetsCompanion _assetCompanion(Asset asset, DateTime storedAt) {
    final symbol = normalizeSymbol(asset.symbol);
    if (symbol.isEmpty) {
      throw InvalidMarketDataException('Symbol is empty.');
    }
    return CachedAssetsCompanion.insert(
      symbol: symbol,
      name: asset.name,
      assetType: _assetTypeToStorage(asset.type),
      exchange: asset.exchange,
      currency: asset.currency,
      updatedAt: storedAt,
    );
  }

  Asset _assetFromRow(CachedAssetRow row) {
    return Asset(
      symbol: row.symbol,
      name: row.name,
      type: _assetTypeFromStorage(row.assetType),
      exchange: row.exchange,
      currency: row.currency,
    );
  }

  HistoricalPrice _historyFromRow(CachedHistoricalPriceRow row) {
    return HistoricalPrice(
      symbol: row.symbol,
      date: row.quoteDate.toUtc(),
      open: FinancialValues.fromSql(row.open),
      high: FinancialValues.fromSql(row.high),
      low: FinancialValues.fromSql(row.low),
      close: FinancialValues.fromSql(row.close),
      volume: row.volume,
    );
  }

  String _assetTypeToStorage(AssetType type) {
    return switch (type) {
      AssetType.stock => 'stock',
      AssetType.etf => 'etf',
    };
  }

  AssetType _assetTypeFromStorage(String value) {
    return switch (value) {
      'stock' => AssetType.stock,
      'etf' => AssetType.etf,
      _ => throw InvalidMarketDataException(
          'Unknown stored asset type: $value.',
        ),
    };
  }
}

final localMarketDataSourceProvider = Provider<LocalMarketDataSource>((ref) {
  return LocalMarketDataSource(ref.watch(marketDataDaoProvider));
});
