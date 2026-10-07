import 'package:drift/drift.dart';

@DataClassName('PortfolioPositionRow')
class PortfolioPositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get symbol => text()();
  RealColumn get quantity => real()();
  RealColumn get purchasePrice => real().named('purchase_price')();
  DateTimeColumn get purchaseDate => dateTime().named('purchase_date')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  String get tableName => 'portfolio_positions';
}
