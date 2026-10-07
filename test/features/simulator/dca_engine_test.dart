import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_engine.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_models.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_rules.dart';

void main() {
  final today = DateTime.utc(2024, 6, 15);

  DcaSimulationResult run(
    DcaSimulationInput input,
    List<HistoricalPrice> history,
  ) {
    return const DcaEngine().simulate(
      input: input,
      history: history,
      today: today,
    );
  }

  test('invests the initial amount once', () {
    final result = run(
      _input(initial: 500, monthly: 0),
      [
        _close(DateTime.utc(2024, 1, 2), 50),
        _close(DateTime.utc(2024, 3, 2), 80),
      ],
    );

    expect(result.purchases, hasLength(1));
    expect(result.purchases.single.amount, 500);
    expect(result.totalInvested, 500);
  });

  test('invests monthly amounts without an initial purchase', () {
    final result = run(
      _input(initial: 0, monthly: 50),
      [
        _close(DateTime.utc(2024, 1, 2), 10),
        _close(DateTime.utc(2024, 2, 2), 20),
        _close(DateTime.utc(2024, 3, 2), 40),
      ],
    );

    expect(result.purchases, hasLength(2));
    expect(result.purchases.first.scheduledDate, DateTime.utc(2024, 2, 2));
    expect(result.purchases.last.scheduledDate, DateTime.utc(2024, 3, 2));
    expect(result.totalInvested, 100);
  });

  test('adds the initial purchase and later monthly purchases', () {
    final result = run(
      _input(initial: 100, monthly: 50),
      [
        _close(DateTime.utc(2024, 1, 2), 10),
        _close(DateTime.utc(2024, 2, 2), 20),
        _close(DateTime.utc(2024, 3, 2), 40),
      ],
    );

    expect(result.purchases.map((purchase) => purchase.amount), [100, 50, 50]);
    expect(result.totalInvested, 200);
  });

  test('buys quantity equal to amount divided by the close', () {
    final result = run(
      _input(initial: 200, monthly: 0, end: DateTime.utc(2024, 1, 12)),
      [
        _close(DateTime.utc(2024, 1, 2), 40),
        _close(DateTime.utc(2024, 1, 12), 40),
      ],
    );

    expect(result.purchases.single.quantity, 5);
    expect(result.totalQuantity, 5);
  });

  test('sums the executed contributions into the invested capital', () {
    final result = run(
      _input(initial: 100, monthly: 25),
      [
        _close(DateTime.utc(2024, 1, 2), 10),
        _close(DateTime.utc(2024, 2, 2), 10),
        _close(DateTime.utc(2024, 3, 2), 10),
      ],
    );

    expect(result.totalInvested, 150);
  });

  test('sums the quantities bought at each close', () {
    final result = run(
      _input(initial: 100, monthly: 100, end: DateTime.utc(2024, 2, 2)),
      [
        _close(DateTime.utc(2024, 1, 2), 50),
        _close(DateTime.utc(2024, 2, 2), 25),
      ],
    );

    expect(result.totalQuantity, 6);
  });

  test('values the accumulated quantity at the last close', () {
    final result = run(
      _input(initial: 100, monthly: 0),
      [
        _close(DateTime.utc(2024, 1, 2), 50),
        _close(DateTime.utc(2024, 3, 2), 80),
      ],
    );

    expect(result.finalValue, 160);
  });

  test('reports a positive gain', () {
    final result = run(
      _input(initial: 100, monthly: 0),
      [
        _close(DateTime.utc(2024, 1, 2), 50),
        _close(DateTime.utc(2024, 3, 2), 80),
      ],
    );

    expect(result.gainLoss, 60);
    expect(result.performancePercent, 60);
  });

  test('reports a loss', () {
    final result = run(
      _input(initial: 100, monthly: 0),
      [
        _close(DateTime.utc(2024, 1, 2), 100),
        _close(DateTime.utc(2024, 3, 2), 80),
      ],
    );

    expect(result.gainLoss, -20);
    expect(result.performancePercent, -20);
  });

  test('executes on the scheduled session when it is quoted', () {
    final result = run(
      _input(
        initial: 100,
        monthly: 0,
        start: DateTime.utc(2024, 1, 8),
        end: DateTime.utc(2024, 1, 12),
      ),
      [
        _close(DateTime.utc(2024, 1, 8), 10),
        _close(DateTime.utc(2024, 1, 12), 11),
      ],
    );

    expect(result.purchases.single.scheduledDate, DateTime.utc(2024, 1, 8));
    expect(result.purchases.single.executionDate, DateTime.utc(2024, 1, 8));
    expect(result.purchaseMovedToNextSession, isFalse);
  });

  test('does not buy on a weekend and uses the next session', () {
    final result = run(
      _input(
        initial: 100,
        monthly: 0,
        start: DateTime.utc(2024, 1, 6),
        end: DateTime.utc(2024, 1, 12),
      ),
      [
        _close(DateTime.utc(2024, 1, 5), 1),
        _close(DateTime.utc(2024, 1, 8), 10),
        _close(DateTime.utc(2024, 1, 12), 12),
      ],
    );

    expect(result.purchases.single.scheduledDate, DateTime.utc(2024, 1, 6));
    expect(result.purchases.single.executionDate, DateTime.utc(2024, 1, 8));
    expect(result.purchases.single.price, 10);
    expect(result.purchaseMovedToNextSession, isTrue);
  });

  test('uses the next quoted session when the scheduled day has no close', () {
    final result = run(
      _input(
        initial: 80,
        monthly: 0,
        start: DateTime.utc(2024, 1, 10),
        end: DateTime.utc(2024, 1, 16),
      ),
      [
        _close(DateTime.utc(2024, 1, 11), 20),
        _close(DateTime.utc(2024, 1, 16), 20),
      ],
    );

    expect(result.purchases.single.executionDate, DateTime.utc(2024, 1, 11));
    expect(result.purchases.single.quantity, 4);
  });

  test('schedules the last calendar day when the month has no such day', () {
    final result = run(
      _input(
        initial: 30,
        monthly: 10,
        start: DateTime.utc(2023, 1, 31),
        end: DateTime.utc(2023, 4, 10),
      ),
      [
        _close(DateTime.utc(2023, 1, 31), 10),
        _close(DateTime.utc(2023, 2, 28), 10),
        _close(DateTime.utc(2023, 3, 31), 10),
        _close(DateTime.utc(2023, 4, 10), 10),
      ],
    );

    expect(
      result.purchases.map((purchase) => purchase.scheduledDate),
      [
        DateTime.utc(2023, 1, 31),
        DateTime.utc(2023, 2, 28),
        DateTime.utc(2023, 3, 31),
      ],
    );
  });

  test('does not count a second contribution on the start date', () {
    final result = run(
      _input(initial: 100, monthly: 50),
      [
        _close(DateTime.utc(2024, 1, 2), 10),
        _close(DateTime.utc(2024, 2, 2), 10),
        _close(DateTime.utc(2024, 3, 2), 10),
      ],
    );

    final onStart = result.purchases.where(
      (purchase) => purchase.scheduledDate == DateTime.utc(2024, 1, 2),
    );
    expect(onStart, hasLength(1));
    expect(onStart.single.amount, 100);
    expect(result.purchases[1].scheduledDate, DateTime.utc(2024, 2, 2));
  });

  test('refuses an empty history', () {
    expect(
      () => run(_input(), const []),
      throwsA(
        isA<DcaSimulationException>()
            .having(
                (error) => error.failure, 'failure', DcaFailure.emptyHistory)
            .having(
              (error) => error.userMessage,
              'message',
              dcaEmptyHistoryMessage,
            ),
      ),
    );
  });

  test('shifts the first purchase when history starts later', () {
    final result = run(
      _input(),
      [
        _close(DateTime.utc(2023, 12, 1), 1),
        _close(DateTime.utc(2024, 1, 10), 50),
        _close(DateTime.utc(2024, 3, 2), 55),
      ],
    );

    expect(result.historyBeginsAfterStart, isTrue);
    expect(result.firstMarketDate, DateTime.utc(2024, 1, 10));
    expect(result.purchases.first.executionDate, DateTime.utc(2024, 1, 10));
    expect(result.purchases.first.price, 50);
  });

  test('refuses history that ends long before the requested end', () {
    expect(
      () => run(
        _input(end: DateTime.utc(2024, 6, 1)),
        [_close(DateTime.utc(2024, 2, 1), 20)],
      ),
      throwsA(
        isA<DcaSimulationException>().having(
          (error) => error.failure,
          'failure',
          DcaFailure.uncoveredPeriod,
        ),
      ),
    );
  });

  test('ignores a zero or negative close', () {
    expect(
      () => run(
        _input(end: DateTime.utc(2024, 1, 12)),
        [
          _close(DateTime.utc(2024, 1, 2), 0),
          _close(DateTime.utc(2024, 1, 12), -5),
        ],
      ),
      throwsA(
        isA<DcaSimulationException>().having(
          (error) => error.failure,
          'failure',
          DcaFailure.unusablePrices,
        ),
      ),
    );

    final result = run(
      _input(initial: 100, monthly: 0, end: DateTime.utc(2024, 1, 12)),
      [
        _close(DateTime.utc(2024, 1, 2), 0),
        _close(DateTime.utc(2024, 1, 9), 10),
        _close(DateTime.utc(2024, 1, 12), 10),
      ],
    );
    expect(result.purchases.single.executionDate, DateTime.utc(2024, 1, 9));
    expect(result.purchases.single.quantity, 10);
  });

  test('rejects a reversed period', () {
    expect(
      () => run(
        _input(
          start: DateTime.utc(2024, 3, 2),
          end: DateTime.utc(2024, 1, 2),
        ),
        [_close(DateTime.utc(2024, 1, 2), 10)],
      ),
      throwsA(
        isA<InvalidDcaInput>().having(
          (error) => error.userMessage,
          'message',
          dcaDateOrderMessage,
        ),
      ),
    );
  });

  test('rejects identical dates', () {
    expect(
      () => run(
        _input(
          start: DateTime.utc(2024, 1, 2),
          end: DateTime.utc(2024, 1, 2),
        ),
        [_close(DateTime.utc(2024, 1, 2), 10)],
      ),
      throwsA(isA<InvalidDcaInput>()),
    );
  });

  test('rejects an end date after today', () {
    expect(
      () => run(
        _input(
          start: DateTime.utc(2024, 6, 1),
          end: DateTime.utc(2024, 6, 16),
        ),
        [_close(DateTime.utc(2024, 6, 16), 10)],
      ),
      throwsA(
        isA<InvalidDcaInput>().having(
          (error) => error.userMessage,
          'message',
          dcaFutureMessage,
        ),
      ),
    );
  });

  test('rejects a simulation with no money to invest', () {
    expect(
      () => run(_input(initial: 0, monthly: 0), const []),
      throwsA(
        isA<InvalidDcaInput>().having(
          (error) => error.userMessage,
          'message',
          dcaBothAmountsZeroMessage,
        ),
      ),
    );
  });

  test('keeps invested capital flat between contributions', () {
    final result = _timeline(today);

    expect(
      result.timeline.map((point) => point.investedAmount),
      [0, 0, 100, 100, 100],
    );
  });

  test('revalues the same quantity when the close changes', () {
    final result = _timeline(today);

    expect(
      result.timeline.map((point) => point.simulatedValue),
      [0, 0, 100, 120, 120],
    );
  });

  test('uses the last close in the period for the final value', () {
    final result = _timeline(today);

    expect(result.purchases.single.price, 25);
    expect(result.lastMarketDate, DateTime.utc(2024, 3, 10));
    expect(result.finalValue, 120);
    expect(result.timeline.last.simulatedValue, result.finalValue);
  });

  test('normalizes the symbol from the form', () {
    final input = checkedDcaInput(
      symbol: ' aapl ',
      initialAmount: '100',
      monthlyAmount: '0',
      startDate: '02/01/2024',
      endDate: '02/03/2024',
      today: today,
    );

    expect(input.symbol, 'AAPL');
  });
}

DcaSimulationResult _timeline(DateTime today) {
  return const DcaEngine().simulate(
    input: DcaSimulationInput(
      symbol: 'AAPL',
      initialAmount: 0,
      monthlyAmount: 100,
      startDate: DateTime.utc(2024, 1, 15),
      endDate: DateTime.utc(2024, 3, 10),
    ),
    history: [
      _close(DateTime.utc(2024, 1, 15), 10),
      _close(DateTime.utc(2024, 2, 1), 20),
      _close(DateTime.utc(2024, 2, 15), 25),
      _close(DateTime.utc(2024, 3, 1), 30),
      _close(DateTime.utc(2024, 3, 10), 30),
    ],
    today: today,
  );
}

DcaSimulationInput _input({
  double initial = 100,
  double monthly = 0,
  DateTime? start,
  DateTime? end,
}) {
  return DcaSimulationInput(
    symbol: 'AAPL',
    initialAmount: initial,
    monthlyAmount: monthly,
    startDate: start ?? DateTime.utc(2024, 1, 2),
    endDate: end ?? DateTime.utc(2024, 3, 2),
  );
}

HistoricalPrice _close(DateTime date, double price) {
  return HistoricalPrice(
    symbol: 'AAPL',
    date: date,
    open: price,
    high: price,
    low: price,
    close: price,
    volume: 1,
  );
}
