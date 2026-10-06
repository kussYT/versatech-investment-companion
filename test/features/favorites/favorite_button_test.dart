import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/app/theme/app_theme.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_button.dart';

import '../../support/memory_database.dart';

void main() {
  testWidgets('scales up while a favorite is added, then returns to rest',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byTooltip('Ajouter AAPL aux favoris'), findsOneWidget);
    expect(_scale(tester), 1);

    await tester.tap(find.byKey(const ValueKey('favorite-AAPL')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    expect(_scale(tester), greaterThan(1));
    expect(_scale(tester), lessThanOrEqualTo(FavoriteButton.addedPeakScale));

    await tester.pump(FavoriteButton.addDuration);
    expect(_scale(tester), closeTo(1, 0.001));
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(find.byTooltip('Retirer AAPL des favoris'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.bookmark));
    expect(icon.color, AppColors.violet);
    await settleDriftStreams(tester);
  });

  testWidgets('uses a shorter shrink when a favorite is removed',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorite-AAPL')));
    await tester.pump();
    await tester.pump(FavoriteButton.addDuration);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('favorite-AAPL')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    expect(_scale(tester), lessThan(1));
    expect(_scale(tester),
        greaterThanOrEqualTo(FavoriteButton.removedValleyScale));

    await tester.pump(FavoriteButton.removeDuration);
    expect(_scale(tester), closeTo(1, 0.001));
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byTooltip('Ajouter AAPL aux favoris'), findsOneWidget);
    await settleDriftStreams(tester);
  });
}

Widget _host() {
  return ProviderScope(
    overrides: [memoryDatabaseOverride()],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(
        body: Center(
          child: FavoriteButton(symbol: 'aapl'),
        ),
      ),
    ),
  );
}

double _scale(WidgetTester tester) {
  final transform =
      tester.widget<Transform>(find.byKey(const Key('favorite-scale')));
  return transform.transform.storage[0];
}
