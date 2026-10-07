import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/app/app.dart';
import 'package:versatech_investment_companion/app/router/app_router.dart';
import 'package:versatech_investment_companion/app/theme/app_theme.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/asset_detail/presentation/asset_detail_messages.dart';
import 'package:versatech_investment_companion/features/asset_detail/presentation/asset_detail_screen.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';

import 'support/fake_market_data_repository.dart';
import '../../support/memory_database.dart';

void main() {
  final clock = FixedClock(DateTime.utc(2024, 6, 15, 10));

  testWidgets('shows the decoded route symbol and the ETF type',
      (tester) async {
    final repository = _ready();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          emptyFavoritesOverride(),
          marketDataRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(clock),
        ],
        child: const VersaTechApp(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(VersaTechApp));
    final router = ProviderScope.containerOf(context).read(appRouterProvider);
    router.go('/explorer/%61apl?type=etf');
    await tester.pumpAndSettle();

    expect(find.text('AAPL'), findsWidgets);
    expect(find.text('ETF'), findsOneWidget);
    expect(repository.profileCalls.single.symbol, 'AAPL');
    expect(find.text('Action'), findsNothing);
  });

  testWidgets('shows the initial loading state before data arrives',
      (tester) async {
    final repository = _ready()
      ..profileGate = CompleterGate.pending()
      ..quoteGate = CompleterGate.pending()
      ..historyGate = CompleterGate.pending();

    await _open(tester, repository: repository, clock: clock);

    expect(find.text('Chargement de la cotation'), findsOneWidget);
    expect(find.text('Chargement de l’historique'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Chargement du profil'), 200);
    expect(find.text('Chargement du profil'), findsOneWidget);
    expect(find.text('189.25'), findsNothing);

    CompleterGate.release(repository);
    await tester.pumpAndSettle();
    expect(find.textContaining('189.25'), findsWidgets);
  });

  testWidgets('shows the profile fields that exist', (tester) async {
    await _open(tester, repository: _ready(), clock: clock);

    expect(find.text('Apple Inc.'), findsOneWidget);
    expect(find.textContaining('NASDAQ'), findsOneWidget);
    expect(find.textContaining('USD'), findsWidgets);
    await tester.scrollUntilVisible(
      find.textContaining('Conçoit des appareils'),
      300,
    );
    expect(find.textContaining('Conçoit des appareils'), findsOneWidget);
    expect(find.textContaining('Secteur'), findsOneWidget);
    expect(find.textContaining('Technology'), findsOneWidget);
    expect(find.textContaining('Industrie'), findsOneWidget);
    expect(find.textContaining('Consumer Electronics'), findsOneWidget);
    expect(find.textContaining('https://apple.com'), findsOneWidget);
  });

  testWidgets('shows a positive variation with a label and a sign',
      (tester) async {
    await _open(tester, repository: _ready(), clock: clock);

    expect(find.textContaining('Hausse'), findsOneWidget);
    expect(find.textContaining('+1.50'), findsOneWidget);
    expect(find.textContaining('+0.80 %'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });

  testWidgets('shows a negative variation with a label and a sign',
      (tester) async {
    final repository = _ready()
      ..quoteResult = detailResult(
        detailQuote(price: 170, change: -2, changePercent: -1.1),
      );
    await _open(tester, repository: repository, clock: clock);

    expect(find.textContaining('Baisse'), findsOneWidget);
    expect(find.textContaining('-2.00'), findsOneWidget);
    expect(find.textContaining('-1.10 %'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
  });

  testWidgets('shows the close-price history and its chart', (tester) async {
    await _open(tester, repository: _ready(), clock: clock);

    await tester.scrollUntilVisible(
      find.text('Historique des clôtures'),
      200,
    );
    expect(find.text('Historique des clôtures'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('close-price-chart')),
      200,
    );
    expect(find.byKey(const Key('close-price-chart')), findsOneWidget);
    expect(find.text('01/03/2024'), findsOneWidget);
    expect(find.text('10/06/2024'), findsOneWidget);
    await tester.scrollUntilVisible(find.text(historyExplanation), 300);
    expect(find.text(historyExplanation), findsOneWidget);
  });

  testWidgets('shows an empty chart without inventing prices', (tester) async {
    final repository = _ready()
      ..historyResult = detailResult(<HistoricalPrice>[]);
    await _open(tester, repository: repository, clock: clock);

    expect(
        find.text('Aucun cours de clôture sur cette période.'), findsOneWidget);
    expect(find.byKey(const Key('close-price-chart')), findsNothing);
    expect(find.textContaining('189.25'), findsWidgets);
  });

  testWidgets('keeps the page usable when only the profile fails',
      (tester) async {
    final repository = _ready()
      ..profileError = const NetworkUnavailableException();
    await _open(tester, repository: repository, clock: clock);

    expect(find.text('Apple Inc.'), findsNothing);
    expect(find.textContaining('Hausse'), findsOneWidget);
    expect(find.byKey(const Key('close-price-chart')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Le profil n’est pas disponible'),
      300,
    );
    expect(
      find.textContaining('Le profil n’est pas disponible'),
      findsOneWidget,
    );
    expect(find.text('Apple Inc.'), findsNothing);
    expect(find.textContaining('Secteur'), findsNothing);
  });

  testWidgets('keeps the page usable when only the history fails',
      (tester) async {
    final repository = _ready()
      ..historyError = const MarketDataNotFoundException();
    await _open(tester, repository: repository, clock: clock);

    expect(find.textContaining('L’historique n’est pas disponible'),
        findsOneWidget);
    expect(find.byKey(const Key('close-price-chart')), findsNothing);
    expect(find.text('Apple Inc.'), findsOneWidget);
    expect(find.textContaining('Hausse'), findsOneWidget);
  });

  testWidgets('shows a quote served from the local cache', (tester) async {
    final repository = _ready()
      ..quoteResult = detailResult(
        detailQuote(),
        origin: DataOrigin.cache,
        lastUpdatedAt: DateTime.utc(2024, 6, 3, 12),
      );
    await _open(tester, repository: repository, clock: clock);

    expect(
      find.text('Données enregistrées — mise à jour le 03/06/2024 12:00 UTC'),
      findsOneWidget,
    );
    expect(find.textContaining('189.25'), findsWidgets);
  });

  testWidgets('shows a stale history and its last synchronization',
      (tester) async {
    final repository = _ready()
      ..historyResult = detailResult(
        [detailBar(date: DateTime.utc(2024, 6, 10), close: 190)],
        origin: DataOrigin.cache,
        lastUpdatedAt: DateTime.utc(2024, 1, 2, 8, 30),
        isStale: true,
        remoteFailure: const NetworkUnavailableException().failure,
      );
    await _open(tester, repository: repository, clock: clock);

    expect(
      find.text('Hors connexion — données du 02/01/2024 08:30 UTC'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('close-price-chart')), findsOneWidget);
  });

  testWidgets('refreshes with forceRefresh and keeps the visible price',
      (tester) async {
    final repository = _ready();
    await _open(tester, repository: repository, clock: clock);
    expect(repository.quoteCalls.single.forceRefresh, isFalse);

    repository.quoteGate = CompleterGate.pending();
    await tester.tap(find.byKey(const Key('asset-detail-refresh')));
    await tester.pump();

    expect(find.textContaining('189.25'), findsWidgets);
    expect(repository.quoteCalls.last.forceRefresh, isTrue);
    expect(repository.profileCalls.last.forceRefresh, isTrue);
    expect(repository.historyCalls.last.forceRefresh, isTrue);

    CompleterGate.release(repository);
    await tester.pumpAndSettle();
  });

  testWidgets('does not invent missing profile, type or price fields',
      (tester) async {
    final repository = _ready()
      ..profileResult = detailResult(
        detailProfile(
          companyName: '   ',
          description: ' ',
          sector: null,
          industry: '',
          website: null,
          currency: '',
          exchange: ' ',
        ),
      )
      ..quoteError = const MarketDataNotFoundException();
    await _open(
      tester,
      repository: repository,
      clock: clock,
      symbol: 'msft',
    );

    expect(find.text('MSFT'), findsWidgets);
    expect(find.text('Action'), findsNothing);
    expect(find.text('ETF'), findsNothing);
    expect(find.textContaining('Secteur'), findsNothing);
    expect(find.textContaining('Industrie'), findsNothing);
    expect(find.textContaining('Site'), findsNothing);
    expect(find.textContaining('NASDAQ'), findsNothing);
    expect(find.textContaining('La cotation n’est pas disponible'),
        findsOneWidget);
    expect(find.textContaining('189.25'), findsNothing);
  });

  testWidgets('labels a stock when the route provides that type',
      (tester) async {
    await _open(
      tester,
      repository: _ready(),
      clock: clock,
      assetType: 'stock',
    );

    expect(find.text('Action'), findsOneWidget);
    expect(find.byIcon(Icons.show_chart), findsOneWidget);
    expect(find.text('ETF'), findsNothing);
  });

  testWidgets('explains the percentage variation without advice',
      (tester) async {
    await _open(tester, repository: _ready(), clock: clock);

    expect(find.text(variationExplanation), findsOneWidget);
    await tester.scrollUntilVisible(find.text(detailDisclaimer), 300);
    expect(find.text(detailDisclaimer), findsOneWidget);
    expect(find.textContaining('conseil personnalisé'), findsNothing);
  });
}

class CompleterGate {
  static Completer<void> pending() => Completer<void>();

  static void release(FakeMarketDataRepository repository) {
    repository.profileGate?.complete();
    repository.quoteGate?.complete();
    repository.historyGate?.complete();
    repository.profileGate = null;
    repository.quoteGate = null;
    repository.historyGate = null;
  }
}

FakeMarketDataRepository _ready() {
  return FakeMarketDataRepository(
    profileResult: detailResult(detailProfile()),
    quoteResult: detailResult(detailQuote()),
    historyResult: detailResult([
      detailBar(date: DateTime.utc(2024, 3, 1), close: 150),
      detailBar(date: DateTime.utc(2024, 6, 10), close: 190),
    ]),
  );
}

Future<void> _open(
  WidgetTester tester, {
  required FakeMarketDataRepository repository,
  required Clock clock,
  String symbol = 'aapl',
  String? assetType,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        emptyFavoritesOverride(),
        marketDataRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(clock),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: AssetDetailScreen(symbol: symbol, assetType: assetType),
      ),
    ),
  );
  if (repository.isWaiting) {
    await tester.pump();
    return;
  }
  await tester.pumpAndSettle();
}
