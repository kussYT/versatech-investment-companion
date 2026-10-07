import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/app/app.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_messages.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/dca_messages.dart';

import 'support/memory_database.dart';

void main() {
  testWidgets(
    'application starts and exposes four navigation destinations',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memoryDatabaseOverride(),
            emptyFavoritesOverride(),
          ],
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
      expect(find.text(portfolioEmptyTitle), findsOneWidget);
      expect(find.text(portfolioEmptyExplanation), findsOneWidget);

      await tester.tap(find.text('Simulateur'));
      await tester.pumpAndSettle();
      expect(find.text(dcaEducationRegular), findsOneWidget);
      expect(find.text(dcaEmptyChartMessage), findsOneWidget);
      await settleDriftStreams(tester);
    },
  );
}
