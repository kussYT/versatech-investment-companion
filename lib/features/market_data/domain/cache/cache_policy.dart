import 'package:versatech_investment_companion/core/errors/app_exception.dart';

abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

final class FixedClock implements Clock {
  FixedClock(DateTime instant) : _instant = instant.toUtc();

  DateTime _instant;

  void set(DateTime instant) {
    _instant = instant.toUtc();
  }

  @override
  DateTime now() => _instant;
}

class CachePolicy {
  const CachePolicy({
    this.searchMaxAge = const Duration(hours: 24),
    this.profileMaxAge = const Duration(days: 7),
    this.quoteMaxAge = const Duration(minutes: 15),
    this.historyMaxAge = const Duration(hours: 24),
  });

  final Duration searchMaxAge;
  final Duration profileMaxAge;
  final Duration quoteMaxAge;
  final Duration historyMaxAge;

  bool isFresh({
    required DateTime? lastSyncedAt,
    required Duration maxAge,
    required DateTime now,
  }) {
    if (lastSyncedAt == null) {
      return false;
    }
    return now.difference(lastSyncedAt.toUtc()) < maxAge;
  }
}

DateTime calendarDate(DateTime value) {
  return DateTime.utc(value.year, value.month, value.day);
}

String normalizeSymbol(String value) {
  return value.trim().toUpperCase();
}

String requiredSymbol(String value) {
  final symbol = normalizeSymbol(value);
  if (symbol.isEmpty) {
    throw InvalidMarketDataException('Symbol is empty.');
  }
  return symbol;
}

String requiredSearchQuery(String value) {
  final query = value.trim();
  if (query.isEmpty) {
    throw InvalidMarketDataException('Search query is empty.');
  }
  return query;
}
