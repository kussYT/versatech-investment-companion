import 'package:drift/drift.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/tables/portfolio_positions.dart';

part 'portfolio_position_dao.g.dart';

@DriftAccessor(tables: [PortfolioPositions])
class PortfolioPositionDao extends DatabaseAccessor<AppDatabase>
    with _$PortfolioPositionDaoMixin {
  PortfolioPositionDao(super.db);

  Future<int> insertPosition({
    required String symbol,
    required double quantity,
    required double purchasePrice,
    required DateTime purchaseDate,
    required DateTime createdAt,
  }) {
    return into(portfolioPositions).insert(
      PortfolioPositionsCompanion.insert(
        symbol: symbol,
        quantity: quantity,
        purchasePrice: purchasePrice,
        purchaseDate: purchaseDate,
        createdAt: createdAt,
      ),
    );
  }

  /// Deletes [id] when it exists. An absent id deletes nothing.
  Future<int> deleteById(int id) {
    return (delete(portfolioPositions)..where((row) => row.id.equals(id))).go();
  }

  Future<bool> updatePosition({
    required int id,
    required String symbol,
    required double quantity,
    required double purchasePrice,
    required DateTime purchaseDate,
  }) async {
    final updated = await (update(portfolioPositions)
          ..where((row) => row.id.equals(id)))
        .write(
      PortfolioPositionsCompanion(
        symbol: Value(symbol),
        quantity: Value(quantity),
        purchasePrice: Value(purchasePrice),
        purchaseDate: Value(purchaseDate),
      ),
    );
    return updated > 0;
  }

  Future<PortfolioPositionRow?> findById(int id) {
    return (select(portfolioPositions)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<PortfolioPositionRow>> getAll() => _ordered().get();

  Stream<List<PortfolioPositionRow>> watchAll() => _ordered().watch();

  Future<List<PortfolioPositionRow>> findBySymbol(String symbol) {
    return (_ordered()..where((row) => row.symbol.equals(symbol))).get();
  }

  SimpleSelectStatement<PortfolioPositions, PortfolioPositionRow> _ordered() {
    return select(portfolioPositions)
      ..orderBy([
        (row) => OrderingTerm.asc(row.symbol),
        (row) => OrderingTerm.asc(row.purchaseDate),
        (row) => OrderingTerm.asc(row.id),
      ]);
  }
}
