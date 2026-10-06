import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/app/app.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_messages.dart';

import 'support/memory_database.dart';

void main() {
  testWidgets(
    'application starts and exposes four navigation destinations',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [emptyFavoritesOverride()],
          child: const VersaTechApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accueil'), findsWidgets);
      expect(find.text('Explorer'), findsOneWidget);
      expect(find.text('Portefeuille'), findsOneWidget);
      expect(find.text('Simulateur'), findsOneWidget);
      expect(find.text(favoriteEmptyTitle), findsOneWidget);
      expect(find.text(favoriteEmptyExplanation), findsOneWidget);

      await tester.tap(find.text('Explorer'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Parcourez des actions et des ETF afin d\'en comprendre les caractéristiques.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Portefeuille'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Composez un portefeuille fictif et observez sa répartition.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Simulateur'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Simulez un investissement pour visualiser son évolution dans le temps.',
        ),
        findsOneWidget,
      );
    },
  );
}
