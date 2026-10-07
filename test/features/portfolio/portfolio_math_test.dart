import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/entities/portfolio_position.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_math.dart';

void main() {
  test('invested amount is quantity times purchase price', () {
    expect(
      PortfolioMath.investedAmount(quantity: 2, purchasePrice: 150),
      300,
    );
  });

  test('current value is quantity times the market price', () {
    expect(
      PortfolioMath.currentValue(quantity: 2, currentPrice: 180),
      360,
    );
  });

  test('gain is the current value minus the invested amount', () {
    expect(
      PortfolioMath.gainLoss(currentValue: 360, investedAmount: 300),
      60,
    );
  });

  test('loss is negative when the current value is lower', () {
    expect(
      PortfolioMath.gainLoss(currentValue: 80, investedAmount: 100),
      -20,
    );
  });

  test('performance is positive when the position gained', () {
    expect(
      PortfolioMath.performancePercent(currentValue: 150, investedAmount: 100),
      50,
    );
  });

  test('performance is negative when the position lost', () {
    expect(
      PortfolioMath.performancePercent(currentValue: 80, investedAmount: 100),
      -20,
    );
  });

  test('total invested sums every position', () {
    expect(PortfolioMath.totalInvested([300, 170]), 470);
  });

  test('portfolio value sums only known current values', () {
    expect(PortfolioMath.totalCurrentValue([540, null, 80]), 620);
    expect(PortfolioMath.totalCurrentValue([null, null]), isNull);
  });

  test('an empty portfolio has no current value and no gain', () {
    final summary = PortfolioMath.summarize(
      positions: const [],
      prices: const {},
    );

    expect(summary.isEmpty, isTrue);
    expect(summary.totalInvested, 0);
    expect(summary.totalCurrentValue, isNull);
    expect(summary.globalGain, isNull);
    expect(summary.globalPerformancePercent, isNull);
    expect(summary.allocation, isEmpty);
  });

  test('allocation uses current value and the weights sum to 100', () {
    final summary = PortfolioMath.summarize(
      positions: [
        _position(id: 1, symbol: 'AAPL', quantity: 1, purchasePrice: 100),
        _position(id: 2, symbol: 'MSFT', quantity: 1, purchasePrice: 100),
      ],
      prices: {
        'AAPL': _price(150),
        'MSFT': _price(50),
      },
    );

    expect(summary.allocation, hasLength(2));
    expect(summary.allocation[0].symbol, 'AAPL');
    expect(summary.allocation[0].weightPercent, 75);
    expect(summary.allocation[1].weightPercent, 25);
    expect(
      summary.allocation.fold<double>(
        0,
        (sum, slice) => sum + slice.weightPercent,
      ),
      closeTo(100, 0.0001),
    );
    expect(summary.totalCurrentValue, 200);
    expect(summary.globalGain, 0);
  });

  test('a zero invested amount does not divide', () {
    expect(
      PortfolioMath.performancePercent(currentValue: 10, investedAmount: 0),
      isNull,
    );
    expect(
      PortfolioMath.weightedAveragePrice(investedAmount: 10, totalQuantity: 0),
      isNull,
    );
    expect(
      () => PortfolioMath.investedAmount(quantity: 0, purchasePrice: 10),
      throwsA(isA<InvalidPortfolioCalculation>()),
    );
    expect(
      () => PortfolioMath.investedAmount(quantity: -1, purchasePrice: 10),
      throwsA(isA<InvalidPortfolioCalculation>()),
    );
    expect(
      () => PortfolioMath.currentValue(quantity: 1, currentPrice: double.nan),
      throwsA(isA<InvalidPortfolioCalculation>()),
    );
  });

  test('two purchases of one symbol keep a weighted average', () {
    final holdings = PortfolioMath.aggregateAll([
      _position(id: 1, symbol: 'AAPL', quantity: 2, purchasePrice: 150),
      _position(id: 2, symbol: 'AAPL', quantity: 1, purchasePrice: 170),
    ]);

    expect(holdings, hasLength(1));
    expect(holdings.single.positions, hasLength(2));
    expect(holdings.single.totalQuantity, 3);
    expect(holdings.single.investedAmount, 470);
    expect(holdings.single.averagePurchasePrice, closeTo(470 / 3, 1e-9));
  });

  test('a missing quote keeps the cost and skips performance', () {
    final summary = PortfolioMath.summarize(
      positions: [
        _position(id: 1, symbol: 'AAPL', quantity: 2, purchasePrice: 100),
      ],
      prices: const {'AAPL': MissingSymbolPrice()},
    );

    final holding = summary.holdings.single;
    expect(holding.holding.investedAmount, 200);
    expect(holding.currentValue, isNull);
    expect(holding.gain, isNull);
    expect(holding.performancePercent, isNull);
    expect(summary.totalInvested, 200);
    expect(summary.totalCurrentValue, isNull);
    expect(summary.globalGain, isNull);
    expect(summary.globalPerformancePercent, isNull);
    expect(summary.allocation, isEmpty);
    expect(summary.unpricedSymbols, ['AAPL']);
    expect(summary.pricesComplete, isFalse);
  });

  test('global performance stays null while one quote is missing', () {
    final summary = PortfolioMath.summarize(
      positions: [
        _position(id: 1, symbol: 'AAPL', quantity: 1, purchasePrice: 100),
        _position(id: 2, symbol: 'MSFT', quantity: 1, purchasePrice: 100),
      ],
      prices: {
        'AAPL': _price(150),
        'MSFT': const MissingSymbolPrice(),
      },
    );

    expect(summary.totalInvested, 200);
    expect(summary.totalCurrentValue, 150);
    expect(summary.globalGain, isNull);
    expect(summary.globalPerformancePercent, isNull);
    expect(summary.allocation.single.symbol, 'AAPL');
    expect(summary.allocation.single.weightPercent, 100);
    expect(summary.unpricedSymbols, ['MSFT']);
  });
}

PortfolioPosition _position({
  required int id,
  required String symbol,
  required double quantity,
  required double purchasePrice,
}) {
  return PortfolioPosition(
    id: id,
    symbol: symbol,
    quantity: quantity,
    purchasePrice: purchasePrice,
    purchaseDate: DateTime.utc(2024, 6, 3),
    createdAt: DateTime.utc(2024, 6, 3, 12),
  );
}

AvailableSymbolPrice _price(double price) {
  return AvailableSymbolPrice(
    price: price,
    isStale: false,
    asOf: DateTime.utc(2024, 6, 3, 12),
  );
}
