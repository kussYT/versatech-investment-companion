import 'package:drift/drift.dart';

@DataClassName('CachedAssetProfileRow')
class CachedAssetProfiles extends Table {
  TextColumn get symbol => text()();
  TextColumn get companyName => text().named('company_name')();
  TextColumn get description => text()();
  TextColumn get sector => text().nullable()();
  TextColumn get industry => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get imageUrl => text().named('image_url').nullable()();
  TextColumn get currency => text()();
  TextColumn get exchange => text()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  String get tableName => 'cached_asset_profiles';

  @override
  Set<Column> get primaryKey => {symbol};
}
