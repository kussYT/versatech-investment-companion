import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/widgets/animated_financial_value.dart';

void main() {
  testWidgets('starts at zero', (tester) async {
    await _pump(tester, 100);

    expect(_text(tester), '0.00');
  });

  testWidgets('shows an intermediate value before the end', (tester) async {
    await _pump(tester, 100);
    await tester.pump(const Duration(milliseconds: 400));

    final value = _text(tester);
    expect(value, isNot('0.00'));
    expect(value, isNot('100.00'));
  });

  testWidgets('reaches the exact value', (tester) async {
    await _pump(tester, 100);
    await tester.pump(const Duration(milliseconds: 800));

    expect(_text(tester), '100.00');
  });

  testWidgets('moves from the current value to the next one', (tester) async {
    await _pump(tester, 100);
    await tester.pump(const Duration(milliseconds: 800));
    await _pump(tester, 40);
    await tester.pump();

    expect(_text(tester), '100.00');
    await tester.pump(const Duration(milliseconds: 800));
    expect(_text(tester), '40.00');
  });

  testWidgets('does not replay when rebuilt with the same value',
      (tester) async {
    await _pump(tester, 100);
    await tester.pump(const Duration(milliseconds: 800));
    await _pump(tester, 100);
    await tester.pump(const Duration(milliseconds: 100));

    expect(_text(tester), '100.00');
  });
}

Future<void> _pump(WidgetTester tester, double value) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AnimatedFinancialValue(
          value: value,
          formatter: (number) => number.toStringAsFixed(2),
          duration: const Duration(milliseconds: 800),
          textKey: const Key('animated-value'),
        ),
      ),
    ),
  );
}

String _text(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('animated-value'))).data!;
}
