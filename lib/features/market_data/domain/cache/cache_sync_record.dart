class CacheSyncRecord {
  const CacheSyncRecord({
    required this.resourceKey,
    required this.lastSyncedAt,
    this.newestDataAt,
    this.oldestDataAt,
    this.status = 'synced',
    this.detail,
  });

  final String resourceKey;
  final DateTime lastSyncedAt;
  final DateTime? newestDataAt;
  final DateTime? oldestDataAt;
  final String status;
  final String? detail;
}

abstract final class CacheResourceKeys {
  static String search(String query) => 'search:${query.trim().toLowerCase()}';

  static String profile(String symbol) => 'profile:$symbol';

  static String quote(String symbol) => 'quote:$symbol';

  static String history(String symbol) => 'history:$symbol';
}
