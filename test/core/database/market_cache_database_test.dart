import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/financial_values.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/datasources/local_market_data_source.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_sync_record.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

void main() {
  late AppDatabase database;
  late LocalMarketDataSource local;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = LocalMarketDataSource(database.marketDataDao);
  });

  tearDown(() async {
    try {
      await database.close();
    } on Object {
      // The close test already released the connection.
    }
  });

  test('schema version is explicit', () {
    expect(database.schemaVersion, 2);
    expect(AppDatabase.latestSchemaVersion, 2);
  });

  test('inserts and reads an asset', () async {
    await _saveAssets(local, [_asset()]);

    expect(await local.findAsset('AAPL'), _asset());
    expect(await database.marketDataDao.countAssets(), 1);
  });

  test('searches assets without regard to case', () async {
    await _saveAssets(local, [
      _asset(),
      _asset(symbol: 'MSFT', name: 'Microsoft Corporation'),
    ]);

    expect(
      await local.searchAssets('apple'),
      [_asset()],
    );
    expect(
      await local.searchAssets('AaPl'),
      [_asset()],
    );
    expect(await local.searchAssets('   '), isEmpty);
  });

  test('replaces an existing asset', () async {
    await _saveAssets(local, [_asset(name: 'Apple')]);
    await _saveAssets(
      local,
      [_asset(name: 'Apple Inc.')],
      resourceKey: 'search:apple inc',
    );

    expect(await database.marketDataDao.countAssets(), 1);
    expect((await local.findAsset('AAPL'))?.name, 'Apple Inc.');
  });

  test('inserts and reads a profile', () async {
    final profile = _profile();
    await local.saveProfile(profile, _syncedAt);

    expect(await local.readProfile('aapl'), profile);
  });

  test('inserts and reads a quote', () async {
    final quote = _quote();
    await local.saveQuote(quote, _syncedAt);

    final stored = await local.readQuote('AAPL');
    expect(stored, quote);
    expect(stored?.previousClose, 190.25);
  });

  test('inserts a history batch and its metadata together', () async {
    await local.saveHistory(
      symbol: 'AAPL',
      prices: [_bar(DateTime.utc(2024, 1, 2)), _bar(DateTime.utc(2024, 1, 3))],
      syncedAt: _syncedAt,
      coverageFrom: DateTime.utc(2024, 1, 2),
      coverageTo: DateTime.utc(2024, 1, 3),
    );

    expect(await database.marketDataDao.countHistoricalPrices('AAPL'), 2);
    final metadata =
        await local.readMetadata(CacheResourceKeys.history('AAPL'));
    expect(metadata?.lastSyncedAt, _syncedAt);
    expect(metadata?.oldestDataAt, DateTime.utc(2024, 1, 2));
    expect(metadata?.newestDataAt, DateTime.utc(2024, 1, 3));
    expect(metadata?.status, 'synced');
  });

  test('does not duplicate a historical point for the same symbol and date',
      () async {
    await local.saveHistory(
      symbol: 'AAPL',
      prices: [_bar(DateTime.utc(2024, 1, 2), close: 10)],
      syncedAt: _syncedAt,
      coverageFrom: DateTime.utc(2024, 1, 2),
      coverageTo: DateTime.utc(2024, 1, 2),
    );
    await local.saveHistory(
      symbol: 'aapl',
      prices: [_bar(DateTime.utc(2024, 1, 2), close: 12)],
      syncedAt: _syncedAt,
      coverageFrom: DateTime.utc(2024, 1, 2),
      coverageTo: DateTime.utc(2024, 1, 2),
    );

    expect(await database.marketDataDao.countHistoricalPrices('AAPL'), 1);
    final stored = await local.readHistory(
      symbol: 'AAPL',
      from: DateTime.utc(2024, 1, 1),
      to: DateTime.utc(2024, 1, 4),
    );
    expect(stored.single.close, 12);
  });

  test('returns history in chronological order', () async {
    await local.saveHistory(
      symbol: 'AAPL',
      prices: [
        _bar(DateTime.utc(2024, 1, 5)),
        _bar(DateTime.utc(2024, 1, 2)),
        _bar(DateTime.utc(2024, 1, 3)),
      ],
      syncedAt: _syncedAt,
      coverageFrom: DateTime.utc(2024, 1, 2),
      coverageTo: DateTime.utc(2024, 1, 5),
    );

    final stored = await local.readHistory(
      symbol: 'AAPL',
      from: DateTime.utc(2024, 1, 1),
      to: DateTime.utc(2024, 1, 31),
    );
    expect(
      stored.map((price) => price.date),
      [
        DateTime.utc(2024, 1, 2),
        DateTime.utc(2024, 1, 3),
        DateTime.utc(2024, 1, 5),
      ],
    );
  });

  test('limits history to the requested period', () async {
    await local.saveHistory(
      symbol: 'AAPL',
      prices: [
        _bar(DateTime.utc(2024, 1, 2)),
        _bar(DateTime.utc(2024, 1, 3)),
        _bar(DateTime.utc(2024, 1, 4)),
      ],
      syncedAt: _syncedAt,
      coverageFrom: DateTime.utc(2024, 1, 2),
      coverageTo: DateTime.utc(2024, 1, 4),
    );

    final stored = await local.readHistory(
      symbol: 'AAPL',
      from: DateTime.utc(2024, 1, 3),
      to: DateTime.utc(2024, 1, 3),
    );
    expect(stored.map((price) => price.date), [DateTime.utc(2024, 1, 3)]);
  });

  test('writes and reads synchronization metadata', () async {
    await local.saveQuote(_quote(), _syncedAt);

    final metadata = await local.readMetadata(CacheResourceKeys.quote('AAPL'));
    expect(metadata?.resourceKey, 'quote:AAPL');
    expect(metadata?.lastSyncedAt, _syncedAt);
    expect(metadata?.newestDataAt, _quote().timestamp);
    expect(metadata?.status, 'synced');

    await local.deleteMetadata(CacheResourceKeys.quote('AAPL'));
    expect(await local.readMetadata(CacheResourceKeys.quote('AAPL')), isNull);
  });

  test('round-trips every stored field through the domain', () async {
    final profile = _profile(
      sector: null,
      industry: null,
      website: null,
      imageUrl: null,
    );
    final quote = _quote(previousClose: null, price: 10.123456789);
    await _saveAssets(local, [_asset(symbol: 'spy', type: AssetType.etf)]);
    await local.saveProfile(profile, _syncedAt);
    await local.saveQuote(quote, _syncedAt);
    await local.saveHistory(
      symbol: 'AAPL',
      prices: [_bar(DateTime.utc(2024, 6, 3), volume: 42)],
      syncedAt: _syncedAt,
      coverageFrom: DateTime.utc(2024, 6, 3),
      coverageTo: DateTime.utc(2024, 6, 3),
    );

    expect((await local.findAsset('SPY'))?.type, AssetType.etf);
    expect(await local.readProfile('AAPL'), profile);
    expect(await local.readQuote('AAPL'), quote);
    expect(
      (await local.readHistory(
        symbol: 'AAPL',
        from: DateTime.utc(2024, 6, 3),
        to: DateTime.utc(2024, 6, 3),
      ))
          .single
          .volume,
      42,
    );
  });

  test('normalizes symbols before every read and write', () async {
    await local.saveQuote(_quote(symbol: ' aapl '), _syncedAt);
    await local.saveQuote(_quote(symbol: 'Aapl'), _syncedAt);
    await local.saveProfile(_profile(symbol: ' aapl '), _syncedAt);

    expect(await database.marketDataDao.countAssets(), 0);
    expect(await local.readQuote('aapl'), _quote());
    expect((await local.readProfile('Aapl'))?.symbol, 'AAPL');
    expect(
      (await database.marketDataDao.findQuote('AAPL'))?.symbol,
      'AAPL',
    );
  });

  test('keeps a reopened file database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'versatech_market_cache_',
    );
    final file = File(p.join(directory.path, 'cache.sqlite'));
    final first = AppDatabase(NativeDatabase(file));
    final firstLocal = LocalMarketDataSource(first.marketDataDao);
    await _saveAssets(firstLocal, [_asset()]);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    final secondLocal = LocalMarketDataSource(second.marketDataDao);
    expect(await secondLocal.findAsset('AAPL'), _asset());
    await second.close();
    await directory.delete(recursive: true);
  });

  test('closes database resources', () async {
    expect(await database.marketDataDao.countAssets(), 0);
    await database.close();

    await expectLater(
      database.marketDataDao.countAssets(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('closing'),
        ),
      ),
    );
  });

  test('rejects a non-finite financial value', () {
    expect(
      () => FinancialValues.toSql(double.nan),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('does not hide an unexpected stored asset type', () async {
    await database.customStatement(
      "INSERT INTO cached_assets "
      "(symbol, name, asset_type, exchange, currency, updated_at) "
      "VALUES ('BAD', 'Bad', 'bond', 'NYSE', 'USD', 0)",
    );

    await expectLater(
      local.findAsset('BAD'),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('deletes one symbol cache explicitly', () async {
    await _saveAssets(
        local, [_asset(), _asset(symbol: 'MSFT', name: 'Microsoft')]);
    await local.saveQuote(_quote(), _syncedAt);
    await local.deleteSymbolCache('aapl');

    expect(await local.findAsset('AAPL'), isNull);
    expect(await local.readQuote('AAPL'), isNull);
    expect(await local.findAsset('MSFT'), isNotNull);
  });

  test('migrates a schema 1 cache without deleting stored market data',
      () async {
    final directory = await Directory.systemTemp.createTemp(
      'versatech_schema1_',
    );
    final file = File(p.join(directory.path, 'cache.sqlite'));
    final legacy = _LegacyMarketCacheDatabase(NativeDatabase(file));
    try {
      final legacyLocal = LocalMarketDataSource(legacy.marketDataDao);
      await _saveAssets(legacyLocal, [_asset()]);
      await legacyLocal.saveProfile(_profile(), _syncedAt);
      await legacyLocal.saveQuote(_quote(), _syncedAt);
      await legacyLocal.saveHistory(
        symbol: 'AAPL',
        prices: [_bar(DateTime.utc(2024, 1, 2))],
        syncedAt: _syncedAt,
        coverageFrom: DateTime.utc(2024, 1, 2),
        coverageTo: DateTime.utc(2024, 1, 2),
      );
      expect(legacy.schemaVersion, 1);
      expect(await legacy.marketDataDao.countAssets(), 1);
    } finally {
      await legacy.close();
    }

    final migrated = AppDatabase(NativeDatabase(file));
    try {
      expect(migrated.schemaVersion, 2);
      final migratedLocal = LocalMarketDataSource(migrated.marketDataDao);
      expect(await migratedLocal.findAsset('AAPL'), _asset());
      expect(
        (await migratedLocal.readProfile('AAPL'))?.companyName,
        'Apple Inc.',
      );
      expect((await migratedLocal.readQuote('AAPL'))?.price, 191.5);
      expect(await migrated.marketDataDao.countHistoricalPrices('AAPL'), 1);
      expect(
        await migratedLocal.readMetadata(CacheResourceKeys.quote('AAPL')),
        isNotNull,
      );
      expect(await migrated.favoriteDao.getAll(), isEmpty);

      final tables = await migrated
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )
          .get();
      final names = [for (final row in tables) row.read<String>('name')];
      expect(
        names,
        containsAll([
          'cached_assets',
          'cached_asset_profiles',
          'cached_market_quotes',
          'cached_historical_prices',
          'cache_metadata',
          'favorites',
        ]),
      );

      await migrated.favoriteDao.insertFavorite(
        symbol: 'AAPL',
        createdAt: _syncedAt,
      );
      expect(await migratedLocal.findAsset('AAPL'), _asset());
      expect((await migrated.favoriteDao.getAll()).single.symbol, 'AAPL');
    } finally {
      await migrated.close();
      await directory.delete(recursive: true);
    }
  });
}

final _syncedAt = DateTime.utc(2024, 6, 3, 12);

Asset _asset({
  String symbol = 'AAPL',
  String name = 'Apple Inc.',
  AssetType type = AssetType.stock,
}) {
  return Asset(
    symbol: symbol,
    name: name,
    type: type,
    exchange: 'NASDAQ',
    currency: 'USD',
  );
}

AssetProfile _profile({
  String symbol = 'AAPL',
  String? sector = 'Technology',
  String? industry = 'Consumer Electronics',
  String? website = 'https://apple.com',
  String? imageUrl = 'https://example.com/aapl.png',
}) {
  return AssetProfile(
    symbol: symbol,
    companyName: 'Apple Inc.',
    description: 'Designs consumer electronics.',
    sector: sector,
    industry: industry,
    website: website,
    imageUrl: imageUrl,
    currency: 'USD',
    exchange: 'NASDAQ',
  );
}

MarketQuote _quote({
  String symbol = 'AAPL',
  double price = 191.5,
  double? previousClose = 190.25,
}) {
  return MarketQuote(
    symbol: symbol,
    price: price,
    change: 1.25,
    changePercent: 0.66,
    previousClose: previousClose,
    timestamp: DateTime.utc(2024, 6, 3, 20),
  );
}

HistoricalPrice _bar(
  DateTime date, {
  double close = 100,
  int volume = 1000,
}) {
  return HistoricalPrice(
    symbol: 'AAPL',
    date: date,
    open: 99,
    high: 101,
    low: 98,
    close: close,
    volume: volume,
  );
}

Future<void> _saveAssets(
  LocalMarketDataSource local,
  List<Asset> assets, {
  String resourceKey = 'search:apple',
}) {
  return local.saveAssets(
    assets: assets,
    syncedAt: _syncedAt,
    resourceKey: resourceKey,
    symbolList: assets.map((asset) => normalizeSymbol(asset.symbol)).join(','),
  );
}

/// Opens the market cache as it existed before favorites were added.
final class _LegacyMarketCacheDatabase extends AppDatabase {
  _LegacyMarketCacheDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createTable(cachedAssets);
        await migrator.createTable(cachedAssetProfiles);
        await migrator.createTable(cachedMarketQuotes);
        await migrator.createTable(cachedHistoricalPrices);
        await migrator.createTable(cacheMetadata);
      },
    );
  }
}
