import 'package:drift/drift.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/tables/favorites.dart';

part 'favorite_dao.g.dart';

@DriftAccessor(tables: [Favorites])
class FavoriteDao extends DatabaseAccessor<AppDatabase>
    with _$FavoriteDaoMixin {
  FavoriteDao(super.db);

  Future<FavoriteRow?> findBySymbol(String symbol) {
    return (select(favorites)..where((row) => row.symbol.equals(symbol)))
        .getSingleOrNull();
  }

  Future<List<FavoriteRow>> getAll() {
    return _ordered().get();
  }

  Stream<List<FavoriteRow>> watchAll() {
    return _ordered().watch();
  }

  /// Inserts [symbol] once. A second insert leaves the original row unchanged.
  Future<void> insertFavorite({
    required String symbol,
    required DateTime createdAt,
  }) {
    return into(favorites).insert(
      FavoritesCompanion.insert(
        symbol: symbol,
        createdAt: createdAt,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Deletes [symbol] when it exists. An absent symbol deletes nothing.
  Future<int> deleteBySymbol(String symbol) {
    return (delete(favorites)..where((row) => row.symbol.equals(symbol))).go();
  }

  SimpleSelectStatement<Favorites, FavoriteRow> _ordered() {
    return select(favorites)
      ..orderBy([
        (row) => OrderingTerm.desc(row.createdAt),
        (row) => OrderingTerm.asc(row.symbol),
      ]);
  }
}
