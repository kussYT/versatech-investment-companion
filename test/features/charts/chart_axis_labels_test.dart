import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/features/asset_detail/presentation/asset_price_chart.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_models.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/dca_chart.dart';

void main() {
  testWidgets('keeps the asset chart end date inside a narrow chart',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssetPriceChart(
            prices: [
              _price(DateTime.utc(2024, 1, 1), 100),
              _price(DateTime.utc(2024, 1, 31), 110),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectInsideChart(
      tester,
      label: '31/01/2024',
      chartKey: const Key('close-price-chart'),
    );
  });

  testWidgets('keeps the DCA chart end date inside a narrow chart',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DcaChart(
            points: [
              _point(DateTime.utc(2024, 1, 1), 100),
              _point(DateTime.utc(2024, 1, 31), 110),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectInsideChart(
      tester,
      label: '31/01/2024',
      chartKey: const Key('dca-chart'),
    );
  });
}

void _expectInsideChart(
  WidgetTester tester, {
  required String label,
  required Key chartKey,
}) {
  final chart = tester.getRect(find.byKey(chartKey));
  final date = tester.getRect(find.text(label));

  expect(date.left, greaterThanOrEqualTo(chart.left));
  expect(date.right, lessThanOrEqualTo(chart.right));
}

HistoricalPrice _price(DateTime date, double close) {
  return HistoricalPrice(
    symbol: 'AAPL',
    date: date,
    open: close,
    high: close,
    low: close,
    close: close,
    volume: 1,
  );
}

SimulationPoint _point(DateTime date, double value) {
  return SimulationPoint(
    date: date,
    investedAmount: value,
    simulatedValue: value,
  );
}
