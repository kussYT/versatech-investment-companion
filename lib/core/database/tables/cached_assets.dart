import 'package:drift/drift.dart';

@DataClassName('CachedAssetRow')
class CachedAssets extends Table {
  TextColumn get symbol => text()();
  TextColumn get name => text()();
  TextColumn get assetType => text().named('asset_type')();
  TextColumn get exchange => text()();
  TextColumn get currency => text()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  String get tableName => 'cached_assets';

  @override
  Set<Column> get primaryKey => {symbol};
}
