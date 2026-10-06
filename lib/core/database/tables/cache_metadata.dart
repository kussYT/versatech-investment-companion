import 'package:drift/drift.dart';

@DataClassName('CacheMetadataRow')
class CacheMetadata extends Table {
  TextColumn get resourceKey => text().named('resource_key')();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at')();
  DateTimeColumn get newestDataAt =>
      dateTime().named('newest_data_at').nullable()();
  DateTimeColumn get oldestDataAt =>
      dateTime().named('oldest_data_at').nullable()();
  TextColumn get status => text()();
  TextColumn get detail => text().nullable()();

  @override
  String get tableName => 'cache_metadata';

  @override
  Set<Column> get primaryKey => {resourceKey};
}
