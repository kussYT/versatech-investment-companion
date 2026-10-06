import 'package:drift/drift.dart';

@DataClassName('CachedHistoricalPriceRow')
class CachedHistoricalPrices extends Table {
  TextColumn get symbol => text()();
  DateTimeColumn get quoteDate => dateTime().named('quote_date')();
  RealColumn get open => real()();
  RealColumn get high => real()();
  RealColumn get low => real()();
  RealColumn get close => real()();
  IntColumn get volume => integer()();
  DateTimeColumn get fetchedAt => dateTime().named('fetched_at')();

  @override
  String get tableName => 'cached_historical_prices';

  @override
  Set<Column> get primaryKey => {symbol, quoteDate};
}
