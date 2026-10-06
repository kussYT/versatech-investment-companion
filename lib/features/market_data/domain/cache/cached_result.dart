import 'package:versatech_investment_companion/core/errors/failure.dart';

enum DataOrigin {
  remote,
  cache,
}

class CachedResult<T> {
  const CachedResult({
    required this.data,
    required this.origin,
    required this.lastUpdatedAt,
    required this.isStale,
    this.remoteFailure,
  });

  final T data;
  final DataOrigin origin;
  final DateTime? lastUpdatedAt;
  final bool isStale;

  /// Set when a recoverable remote failure was served from cache.
  /// The detail never contains the API key.
  final Failure? remoteFailure;
}
