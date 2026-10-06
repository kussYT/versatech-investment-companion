import 'package:drift/drift.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/tables/cache_metadata.dart';
import 'package:versatech_investment_companion/core/database/tables/cached_asset_profiles.dart';
import 'package:versatech_investment_companion/core/database/tables/cached_assets.dart';
import 'package:versatech_investment_companion/core/database/tables/cached_historical_prices.dart';
import 'package:versatech_investment_companion/core/database/tables/cached_market_quotes.dart';

part 'market_data_dao.g.dart';

@DriftAccessor(
  tables: [
    CachedAssets,
    CachedAssetProfiles,
    CachedMarketQuotes,
    CachedHistoricalPrices,
    CacheMetadata,
  ],
)
class MarketDataDao extends DatabaseAccessor<AppDatabase>
    with _$MarketDataDaoMixin {
  MarketDataDao(super.db);

  Future<void> saveAssetsWithMetadata({
    required List<CachedAssetsCompanion> assets,
    required CacheMetadataCompanion metadata,
  }) {
    return transaction(() async {
      for (final asset in assets) {
        await into(cachedAssets).insert(
          asset,
          mode: InsertMode.insertOrReplace,
        );
      }
      await into(cacheMetadata).insertOnConflictUpdate(metadata);
    });
  }

  Future<List<CachedAssetRow>> searchAssets(String query) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) {
      return Future.value(const []);
    }

    return (select(cachedAssets)
          ..where(
            (row) =>
                row.symbol.lower().contains(term) |
                row.name.lower().contains(term),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.symbol)]))
        .get();
  }

  Future<List<CachedAssetRow>> assetsBySymbols(List<String> symbols) {
    if (symbols.isEmpty) {
      return Future.value(const []);
    }
    return (select(cachedAssets)..where((row) => row.symbol.isIn(symbols)))
        .get();
  }

  Future<CachedAssetRow?> findAsset(String symbol) {
    return (select(cachedAssets)..where((row) => row.symbol.equals(symbol)))
        .getSingleOrNull();
  }

  Future<int> countAssets() async {
    final count = cachedAssets.symbol.count();
    final query = selectOnly(cachedAssets)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<void> saveProfileWithMetadata({
    required CachedAssetProfilesCompanion profile,
    required CacheMetadataCompanion metadata,
  }) {
    return transaction(() async {
      await into(cachedAssetProfiles).insert(
        profile,
        mode: InsertMode.insertOrReplace,
      );
      await into(cacheMetadata).insertOnConflictUpdate(metadata);
    });
  }

  Future<CachedAssetProfileRow?> findProfile(String symbol) {
    return (select(cachedAssetProfiles)
          ..where((row) => row.symbol.equals(symbol)))
        .getSingleOrNull();
  }

  Future<void> saveQuoteWithMetadata({
    required CachedMarketQuotesCompanion quote,
    required CacheMetadataCompanion metadata,
  }) {
    return transaction(() async {
      await into(cachedMarketQuotes).insert(
        quote,
        mode: InsertMode.insertOrReplace,
      );
      await into(cacheMetadata).insertOnConflictUpdate(metadata);
    });
  }

  Future<CachedMarketQuoteRow?> findQuote(String symbol) {
    return (select(cachedMarketQuotes)
          ..where((row) => row.symbol.equals(symbol)))
        .getSingleOrNull();
  }

  Future<void> saveHistoricalPricesWithMetadata({
    required String symbol,
    required List<CachedHistoricalPricesCompanion> prices,
    required DateTime syncedAt,
    required String resourceKey,
    required DateTime coverageFrom,
    required DateTime coverageTo,
    String status = 'synced',
  }) {
    return transaction(() async {
      for (final price in prices) {
        await into(cachedHistoricalPrices).insert(
          price,
          mode: InsertMode.insertOrReplace,
        );
      }
      final bounds = await _historyBounds(symbol);
      await into(cacheMetadata).insertOnConflictUpdate(
        CacheMetadataCompanion(
          resourceKey: Value(resourceKey),
          lastSyncedAt: Value(syncedAt),
          oldestDataAt: Value(_earliest(bounds.oldest, coverageFrom)),
          newestDataAt: Value(_latest(bounds.newest, coverageTo)),
          status: Value(status),
        ),
      );
    });
  }

  Future<List<CachedHistoricalPriceRow>> historicalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
  }) {
    return (select(cachedHistoricalPrices)
          ..where(
            (row) =>
                row.symbol.equals(symbol) &
                row.quoteDate.isBiggerOrEqualValue(from) &
                row.quoteDate.isSmallerOrEqualValue(to),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.quoteDate)]))
        .get();
  }

  Future<({DateTime? oldest, DateTime? newest})> historyBounds(String symbol) {
    return _historyBounds(symbol);
  }

  Future<int> countHistoricalPrices(String symbol) async {
    final count = cachedHistoricalPrices.symbol.count();
    final query = selectOnly(cachedHistoricalPrices)
      ..addColumns([count])
      ..where(cachedHistoricalPrices.symbol.equals(symbol));
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<void> saveMetadata(CacheMetadataCompanion metadata) {
    return into(cacheMetadata).insertOnConflictUpdate(metadata);
  }

  Future<CacheMetadataRow?> findMetadata(String resourceKey) {
    return (select(cacheMetadata)
          ..where((row) => row.resourceKey.equals(resourceKey)))
        .getSingleOrNull();
  }

  Future<void> deleteSymbolCache(String symbol) {
    return transaction(() async {
      await (delete(cachedAssets)..where((row) => row.symbol.equals(symbol)))
          .go();
      await (delete(cachedAssetProfiles)
            ..where((row) => row.symbol.equals(symbol)))
          .go();
      await (delete(cachedMarketQuotes)
            ..where((row) => row.symbol.equals(symbol)))
          .go();
      await (delete(cachedHistoricalPrices)
            ..where((row) => row.symbol.equals(symbol)))
          .go();
      await (delete(cacheMetadata)
            ..where(
              (row) =>
                  row.resourceKey.equals('profile:$symbol') |
                  row.resourceKey.equals('quote:$symbol') |
                  row.resourceKey.equals('history:$symbol'),
            ))
          .go();
    });
  }

  Future<void> deleteMetadata(String resourceKey) {
    return (delete(cacheMetadata)
          ..where((row) => row.resourceKey.equals(resourceKey)))
        .go();
  }

  Future<({DateTime? oldest, DateTime? newest})> _historyBounds(
    String symbol,
  ) async {
    final oldest = cachedHistoricalPrices.quoteDate.min();
    final newest = cachedHistoricalPrices.quoteDate.max();
    final query = selectOnly(cachedHistoricalPrices)
      ..addColumns([oldest, newest])
      ..where(cachedHistoricalPrices.symbol.equals(symbol));
    final row = await query.getSingle();
    return (
      oldest: row.read(oldest),
      newest: row.read(newest),
    );
  }

  DateTime _earliest(DateTime? current, DateTime candidate) {
    final stored = current?.toUtc();
    if (stored == null || candidate.isBefore(stored)) {
      return candidate;
    }
    return stored;
  }

  DateTime _latest(DateTime? current, DateTime candidate) {
    final stored = current?.toUtc();
    if (stored == null || candidate.isAfter(stored)) {
      return candidate;
    }
    return stored;
  }
}
