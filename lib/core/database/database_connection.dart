import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

const marketCacheFileName = 'versatech_market_cache.sqlite';

/// Opens the on-device cache database.
///
/// The file lives in the application support directory, so it survives a
/// full process restart. Tests use [NativeDatabase.memory] or a temporary
/// file instead of this connection.
QueryExecutor openPersistentConnection() {
  return LazyDatabase(() async {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, marketCacheFileName));
    return NativeDatabase.createInBackground(file);
  });
}
