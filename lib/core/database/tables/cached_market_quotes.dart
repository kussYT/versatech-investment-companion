import 'package:drift/drift.dart';

@DataClassName('CachedMarketQuoteRow')
class CachedMarketQuotes extends Table {
  TextColumn get symbol => text()();
  RealColumn get price => real()();
  RealColumn get priceChange => real().named('price_change')();
  RealColumn get changePercent => real().named('change_percent')();
  RealColumn get previousClose => real().named('previous_close').nullable()();
  DateTimeColumn get quotedAt => dateTime().named('quoted_at')();
  DateTimeColumn get fetchedAt => dateTime().named('fetched_at')();

  @override
  String get tableName => 'cached_market_quotes';

  @override
  Set<Column> get primaryKey => {symbol};
}
