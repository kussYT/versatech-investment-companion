import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/errors/failure.dart';
import 'package:versatech_investment_companion/features/market_data/data/datasources/local_market_data_source.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/remote_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

void main() {
  late AppDatabase database;
  late LocalMarketDataSource local;
  late FixedClock clock;
  late _FakeRemote remote;
  late CachedMarketDataRepository repository;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = LocalMarketDataSource(database.marketDataDao);
    clock = FixedClock(DateTime.utc(2024, 6, 3, 12));
    remote = _FakeRemote();
    repository = CachedMarketDataRepository(
      remote: remote,
      local: local,
      policy: const CachePolicy(),
      clock: clock,
    );
  });

  tearDown(() => database.close());

  test('serves a fresh quote without calling the remote source', () async {
    await local.saveQuote(_quote(), clock.now());
    remote.error = const NetworkUnavailableException();

    final result = await repository.getQuote('aapl');

    expect(result.data, _quote());
    expect(result.origin, DataOrigin.cache);
    expect(result.isStale, isFalse);
    expect(result.lastUpdatedAt, clock.now());
    expect(remote.quoteCalls, 0);
  });

  test('refreshes a stale quote and stores the remote response', () async {
    await local.saveQuote(_quote(price: 100), clock.now());
    clock.set(clock.now().add(const Duration(minutes: 15)));
    remote.quote = _quote(price: 110);

    final result = await repository.getQuote('AAPL');

    expect(remote.quoteCalls, 1);
    expect(result.origin, DataOrigin.remote);
    expect(result.isStale, isFalse);
    expect(result.data.price, 110);
    expect(result.lastUpdatedAt, clock.now());
    expect((await local.readQuote('AAPL'))?.price, 110);
  });

  test('falls back to a stale quote when the network fails', () async {
    final syncedAt = clock.now();
    await local.saveQuote(_quote(), syncedAt);
    clock.set(syncedAt.add(const Duration(minutes: 16)));
    remote.error = const NetworkUnavailableException();

    final result = await repository.getQuote('AAPL');

    expect(result.data, _quote());
    expect(result.origin, DataOrigin.cache);
    expect(result.isStale, isTrue);
    expect(result.lastUpdatedAt, syncedAt);
    expect(result.remoteFailure?.code, FailureCode.networkUnavailable);
  });

  test('stores a remote quote when the cache is empty', () async {
    remote.quote = _quote();

    final result = await repository.getQuote(' AAPL ');

    expect(result.origin, DataOrigin.remote);
    expect(result.isStale, isFalse);
    expect(result.data, _quote());
    expect(await local.readQuote('aapl'), _quote());
  });

  test('propagates a remote failure when no cache exists', () async {
    remote.error = const RequestTimeoutException();

    await expectLater(
      repository.getQuote('AAPL'),
      throwsA(isA<RequestTimeoutException>()),
    );
    expect(await local.readQuote('AAPL'), isNull);
  });

  test('forceRefresh calls the remote source even when the cache is fresh',
      () async {
    await local.saveQuote(_quote(price: 100), clock.now());
    remote.quote = _quote(price: 125);

    final result = await repository.getQuote('AAPL', forceRefresh: true);

    expect(remote.quoteCalls, 1);
    expect(result.origin, DataOrigin.remote);
    expect(result.data.price, 125);
    expect((await local.readQuote('AAPL'))?.price, 125);
  });

  test('does not replace a valid quote with an invalid remote response',
      () async {
    await local.saveQuote(_quote(price: 100), clock.now());
    clock.set(clock.now().add(const Duration(hours: 1)));
    remote.quote = _quote(symbol: 'MSFT', price: 1);

    await expectLater(
      repository.getQuote('AAPL', forceRefresh: true),
      throwsA(isA<InvalidMarketDataException>()),
    );
    expect((await local.readQuote('AAPL'))?.price, 100);

    remote.quote = null;
    remote.error = const MarketDataNotFoundException();
    await expectLater(
      repository.getQuote('AAPL', forceRefresh: true),
      throwsA(isA<MarketDataNotFoundException>()),
    );
    expect((await local.readQuote('AAPL'))?.price, 100);
  });

  test('searches locally when the remote search fails', () async {
    await local.saveAssets(
      assets: [_asset(), _asset(symbol: 'MSFT', name: 'Microsoft')],
      syncedAt: clock.now().subtract(const Duration(days: 3)),
      resourceKey: 'search:other',
      symbolList: 'AAPL,MSFT',
    );
    remote.error = const RateLimitException();

    final result = await repository.searchAssets('apple');

    expect(result.origin, DataOrigin.cache);
    expect(result.isStale, isTrue);
    expect(result.data, [_asset()]);
    expect(result.remoteFailure?.code, FailureCode.rateLimited);
    expect(result.remoteFailure?.detail, isNull);
  });

  test('persists a successful remote search', () async {
    remote.assets = [_asset(symbol: ' aapl ')];

    final result = await repository.searchAssets('Apple');

    expect(result.origin, DataOrigin.remote);
    expect(result.data.single.symbol, 'AAPL');
    expect(await local.findAsset('AAPL'), result.data.single);

    clock.set(clock.now().add(const Duration(hours: 25)));
    remote.error = const NetworkUnavailableException();
    final cached = await repository.searchAssets('inc');
    expect(cached.origin, DataOrigin.cache);
    expect(cached.isStale, isTrue);
    expect(cached.data.single.symbol, 'AAPL');
  });

  test('returns partial local history when a later remote call fails',
      () async {
    await local.saveHistory(
      symbol: 'AAPL',
      prices: [_bar(DateTime.utc(2024, 1, 2))],
      syncedAt: DateTime.utc(2024, 1, 2, 12),
      coverageFrom: DateTime.utc(2024, 1, 2),
      coverageTo: DateTime.utc(2024, 1, 2),
    );
    clock.set(DateTime.utc(2024, 1, 2, 18));
    remote.error = const NetworkUnavailableException();

    final result = await repository.getHistoricalPrices(
      symbol: 'aapl',
      from: DateTime.utc(2024, 1, 2),
      to: DateTime.utc(2024, 1, 4),
    );

    expect(result.origin, DataOrigin.cache);
    expect(result.isStale, isTrue);
    expect(result.data.map((price) => price.date), [DateTime.utc(2024, 1, 2)]);
    expect(remote.historyRequests.single.from, DateTime.utc(2024, 1, 3));
    expect(remote.historyRequests.single.to, DateTime.utc(2024, 1, 4));
  });

  test('serves covered fresh history without a remote call', () async {
    await local.saveHistory(
      symbol: 'AAPL',
      prices: [
        _bar(DateTime.utc(2024, 1, 2)),
        _bar(DateTime.utc(2024, 1, 3)),
      ],
      syncedAt: clock.now(),
      coverageFrom: DateTime.utc(2024, 1, 2),
      coverageTo: DateTime.utc(2024, 1, 3),
    );

    final result = await repository.getHistoricalPrices(
      symbol: 'AAPL',
      from: DateTime(2024, 1, 2, 15),
      to: DateTime(2024, 1, 3, 1),
    );

    expect(remote.historyCalls, 0);
    expect(result.origin, DataOrigin.cache);
    expect(result.isStale, isFalse);
    expect(result.data, hasLength(2));
  });

  test('does not erase stored history when the remote range is empty',
      () async {
    await local.saveHistory(
      symbol: 'AAPL',
      prices: [_bar(DateTime.utc(2024, 1, 2), close: 50)],
      syncedAt: clock.now().subtract(const Duration(days: 2)),
      coverageFrom: DateTime.utc(2024, 1, 2),
      coverageTo: DateTime.utc(2024, 1, 2),
    );
    remote.history = const [];

    final result = await repository.getHistoricalPrices(
      symbol: 'AAPL',
      from: DateTime.utc(2024, 1, 2),
      to: DateTime.utc(2024, 1, 2),
      forceRefresh: true,
    );

    expect(result.data.single.close, 50);
    expect(await database.marketDataDao.countHistoricalPrices('AAPL'), 1);
  });

  test('propagates a profile miss and keeps the previous profile', () async {
    final profile = _profile();
    await local.saveProfile(
        profile, clock.now().subtract(const Duration(days: 8)));
    remote.error = const MarketDataNotFoundException();

    await expectLater(
      repository.getProfile('AAPL'),
      throwsA(isA<MarketDataNotFoundException>()),
    );
    expect(await local.readProfile('AAPL'), profile);
  });
}

class _FakeRemote implements MarketDataRemote {
  List<Asset> assets = const [];
  MarketQuote? quote;
  AppException? error;
  List<HistoricalPrice> history = const [];

  int quoteCalls = 0;
  int historyCalls = 0;
  final historyRequests = <({DateTime from, DateTime to})>[];

  void _check() {
    final current = error;
    if (current != null) {
      throw current;
    }
  }

  @override
  Future<List<Asset>> searchAssets(String query) async {
    _check();
    return assets;
  }

  @override
  Future<AssetProfile> getProfile(String symbol) async {
    _check();
    throw const MarketDataNotFoundException();
  }

  @override
  Future<MarketQuote> getQuote(String symbol) async {
    quoteCalls += 1;
    _check();
    return quote!;
  }

  @override
  Future<List<HistoricalPrice>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
  }) async {
    historyCalls += 1;
    historyRequests.add((from: from, to: to));
    _check();
    return history;
  }
}

Asset _asset({String symbol = 'AAPL', String name = 'Apple Inc.'}) {
  return Asset(
    symbol: symbol,
    name: name,
    type: AssetType.stock,
    exchange: 'NASDAQ',
    currency: 'USD',
  );
}

AssetProfile _profile() {
  return const AssetProfile(
    symbol: 'AAPL',
    companyName: 'Apple Inc.',
    description: 'Designs consumer electronics.',
    currency: 'USD',
    exchange: 'NASDAQ',
  );
}

MarketQuote _quote({String symbol = 'AAPL', double price = 191.5}) {
  return MarketQuote(
    symbol: symbol,
    price: price,
    change: 1.25,
    changePercent: 0.66,
    previousClose: 190.25,
    timestamp: DateTime.utc(2024, 6, 3, 20),
  );
}

HistoricalPrice _bar(DateTime date, {double close = 100}) {
  return HistoricalPrice(
    symbol: 'AAPL',
    date: date,
    open: 99,
    high: 101,
    low: 98,
    close: close,
    volume: 1000,
  );
}
