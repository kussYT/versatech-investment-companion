import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/features/dashboard/presentation/dashboard_entrance.dart';

void main() {
  testWidgets('starts hidden, moves, then settles', (tester) async {
    await _pump(tester, disableAnimations: false);

    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
    await tester.pump(const Duration(milliseconds: 240));
    final midway = tester.widget<Opacity>(find.byType(Opacity)).opacity;
    expect(midway, greaterThan(0));
    expect(midway, lessThan(1));
    await tester.pump(const Duration(milliseconds: 240));

    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    expect(find.text('Synthèse'), findsOneWidget);
  });

  testWidgets('is already visible when animations are disabled',
      (tester) async {
    await _pump(tester, disableAnimations: true);

    expect(find.byType(Opacity), findsNothing);
    expect(find.text('Synthèse'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required bool disableAnimations,
}) {
  return tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: DashboardEntrance(
          index: 0,
          child: Text('Synthèse'),
        ),
      ),
    ),
  );
}
