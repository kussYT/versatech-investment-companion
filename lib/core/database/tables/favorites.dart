import 'package:drift/drift.dart';

@DataClassName('FavoriteRow')
class Favorites extends Table {
  TextColumn get symbol => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  String get tableName => 'favorites';

  @override
  Set<Column> get primaryKey => {symbol};
}
