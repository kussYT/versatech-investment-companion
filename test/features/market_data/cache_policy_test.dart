import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';

void main() {
  const policy = CachePolicy();

  test('treats a quote as fresh until the maximum age', () {
    final syncedAt = DateTime.utc(2024, 6, 3, 12);
    final clock = FixedClock(syncedAt);

    expect(
      policy.isFresh(
        lastSyncedAt: syncedAt,
        maxAge: policy.quoteMaxAge,
        now: clock.now(),
      ),
      isTrue,
    );

    clock.set(syncedAt.add(const Duration(minutes: 14, seconds: 59)));
    expect(
      policy.isFresh(
        lastSyncedAt: syncedAt,
        maxAge: policy.quoteMaxAge,
        now: clock.now(),
      ),
      isTrue,
    );

    clock.set(syncedAt.add(policy.quoteMaxAge));
    expect(
      policy.isFresh(
        lastSyncedAt: syncedAt,
        maxAge: policy.quoteMaxAge,
        now: clock.now(),
      ),
      isFalse,
    );
  });

  test('uses the configured durations', () {
    expect(policy.searchMaxAge, const Duration(hours: 24));
    expect(policy.profileMaxAge, const Duration(days: 7));
    expect(policy.quoteMaxAge, const Duration(minutes: 15));
    expect(policy.historyMaxAge, const Duration(hours: 24));
  });

  test('normalizes symbols and calendar dates', () {
    expect(normalizeSymbol(' aapl '), 'AAPL');
    expect(
        calendarDate(DateTime(2024, 6, 3, 22, 15)), DateTime.utc(2024, 6, 3));
    expect(requiredSymbol(' msft '), 'MSFT');
  });
}
