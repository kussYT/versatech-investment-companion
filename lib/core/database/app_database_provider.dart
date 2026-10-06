import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/daos/favorite_dao.dart';
import 'package:versatech_investment_companion/core/database/daos/market_data_dao.dart';
import 'package:versatech_investment_companion/core/database/database_connection.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase(openPersistentConnection());
  ref.onDispose(database.close);
  return database;
});

final marketDataDaoProvider = Provider<MarketDataDao>((ref) {
  return ref.watch(appDatabaseProvider).marketDataDao;
});

final favoriteDaoProvider = Provider<FavoriteDao>((ref) {
  return ref.watch(appDatabaseProvider).favoriteDao;
});
