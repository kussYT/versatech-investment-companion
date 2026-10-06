import 'package:drift/drift.dart';
import 'package:versatech_investment_companion/core/database/daos/favorite_dao.dart';
import 'package:versatech_investment_companion/core/database/daos/market_data_dao.dart';
import 'package:versatech_investment_companion/core/database/tables/cache_metadata.dart';
import 'package:versatech_investment_companion/core/database/tables/cached_asset_profiles.dart';
import 'package:versatech_investment_companion/core/database/tables/cached_assets.dart';
import 'package:versatech_investment_companion/core/database/tables/cached_historical_prices.dart';
import 'package:versatech_investment_companion/core/database/tables/cached_market_quotes.dart';
import 'package:versatech_investment_companion/core/database/tables/favorites.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CachedAssets,
    CachedAssetProfiles,
    CachedMarketQuotes,
    CachedHistoricalPrices,
    CacheMetadata,
    Favorites,
  ],
  daos: [MarketDataDao, FavoriteDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  static const latestSchemaVersion = 2;

  @override
  int get schemaVersion => latestSchemaVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from >= to) {
          return;
        }
        // Version 2 adds local favorites. Cache tables stay in place.
        if (from < 2) {
          await migrator.createTable(favorites);
        }
      },
    );
  }
}
