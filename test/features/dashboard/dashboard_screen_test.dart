import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/app/app.dart';
import 'package:versatech_investment_companion/app/router/app_router.dart';
import 'package:versatech_investment_companion/app/theme/app_theme.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/app_database_provider.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/dashboard/presentation/dashboard_messages.dart';
import 'package:versatech_investment_companion/features/dashboard/presentation/dashboard_screen.dart';
import 'package:versatech_investment_companion/features/favorites/data/drift_favorite_repository.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_messages.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';
import 'package:versatech_investment_companion/features/portfolio/data/drift_portfolio_repository.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/dca_messages.dart';

import '../../support/memory_database.dart';
import '../asset_detail/support/fake_market_data_repository.dart';

void main() {
  testWidgets('shows an empty portfolio as a starting point', (tester) async {
    await _open(tester);

    expect(find.text(dashboardGreeting), findsOneWidget);
    expect(find.text(dashboardSubtitle), findsOneWidget);
    expect(find.text(dashboardEmptyPortfolioTitle), findsOneWidget);
    expect(find.text(dashboardEmptyPortfolioBody), findsOneWidget);
    expect(find.text(favoriteEmptyTitle), findsOneWidget);
    expect(find.text(dashboardLessonTitle), findsOneWidget);
    expect(find.text(portfolioReadErrorMessage), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('shows invested amount, value, gain and performance',
      (tester) async {
    await _open(
      tester,
      positions: const [_Lot('AAPL', 2, 100)],
      quotes: {'AAPL': _quote('AAPL', 150)},
    );

    expect(_text(tester, const Key('dashboard-invested')), '200.00');
    expect(_text(tester, const Key('dashboard-current')), '300.00');
    expect(find.text('Gain'), findsOneWidget);
    expect(_text(tester, const Key('dashboard-gain')), '+100.00');
    expect(_text(tester, const Key('dashboard-performance')), '+50.00 %');
    expect(
        _text(tester, const Key('dashboard-counts')), '1 actif · 1 position');
    await settleDriftStreams(tester);
  });

  testWidgets('shows a loss with a sign, an amount and a percent',
      (tester) async {
    await _open(
      tester,
      positions: const [_Lot('AAPL', 1, 100)],
      quotes: {'AAPL': _quote('AAPL', 80)},
    );

    expect(find.text('Perte'), findsOneWidget);
    expect(_text(tester, const Key('dashboard-current')), '80.00');
    expect(_text(tester, const Key('dashboard-gain')), '-20.00');
    expect(_text(tester, const Key('dashboard-performance')), '-20.00 %');
    expect(find.byIcon(Icons.trending_down), findsOneWidget);
    await settleDriftStreams(tester);
  });

  testWidgets('keeps the invested amount when the quote is missing',
      (tester) async {
    await _open(
      tester,
      positions: const [_Lot('AAPL', 1, 100)],
      errors: {'AAPL': const MarketDataNotFoundException()},
    );

    expect(_text(tester, const Key('dashboard-invested')), '100.00');
    expect(find.text(portfolioValueUnavailable), findsOneWidget);
    expect(find.text(portfolioPerformanceUnavailable), findsOneWidget);
    expect(find.byKey(const Key('dashboard-gain')), findsNothing);
    expect(find.text('0.00'), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('keeps a stale valuation and names the stored data',
      (tester) async {
    await _open(
      tester,
      positions: const [_Lot('AAPL', 1, 100)],
      quotes: {
        'AAPL': _quote(
          'AAPL',
          150,
          stale: true,
          updated: DateTime.utc(2024, 6, 1, 15, 30),
        ),
      },
    );

    expect(find.text(portfolioStaleMessage), findsOneWidget);
    expect(
      find.text(dashboardRecordedAt('01/06/2024 15:30 UTC')),
      findsOneWidget,
    );
    expect(_text(tester, const Key('dashboard-current')), '150.00');
    expect(find.textContaining('temps réel'), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('lists a favorite and opens its asset page', (tester) async {
    final repository = FakeMarketDataRepository(
      profileResult: detailResult(detailProfile()),
      quoteResult: detailResult(detailQuote()),
      historyResult: detailResult([
        detailBar(date: DateTime.utc(2024, 3, 1), close: 150),
      ]),
    );
    await _open(
      tester,
      favorites: const ['AAPL'],
      market: repository,
      app: true,
    );

    expect(find.text(favoriteEmptyTitle), findsNothing);
    expect(find.byKey(const ValueKey('favorite-entry-AAPL')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('favorite-entry-AAPL')),
    );
    await tester.tap(find.byKey(const ValueKey('favorite-entry-AAPL')));
    await tester.pumpAndSettle();

    expect(_location(tester), '/explorer/AAPL');
    await settleDriftStreams(tester);
  });

  testWidgets('keeps the empty favorite explanation', (tester) async {
    await _open(tester);

    expect(find.text(favoriteEmptyTitle), findsOneWidget);
    expect(find.text(favoriteEmptyExplanation), findsOneWidget);
    await settleDriftStreams(tester);
  });

  testWidgets('opens Explorer from a shortcut', (tester) async {
    await _open(tester, app: true);
    await tester.ensureVisible(
      find.byKey(const Key('dashboard-shortcut-explorer')),
    );
    await tester.tap(find.byKey(const Key('dashboard-shortcut-explorer')));
    await tester.pumpAndSettle();

    expect(_location(tester), '/explorer');
    await settleDriftStreams(tester);
  });

  testWidgets('opens the portfolio from a shortcut', (tester) async {
    await _open(tester, app: true);
    await tester.ensureVisible(
      find.byKey(const Key('dashboard-shortcut-portfolio')),
    );
    await tester.tap(find.byKey(const Key('dashboard-shortcut-portfolio')));
    await tester.pumpAndSettle();

    expect(_location(tester), '/portfolio');
    expect(find.text(portfolioEmptyTitle), findsOneWidget);
    await settleDriftStreams(tester);
  });

  testWidgets('opens the simulator from a shortcut', (tester) async {
    await _open(tester, app: true);
    await tester.ensureVisible(
      find.byKey(const Key('dashboard-shortcut-simulator')),
    );
    await tester.tap(find.byKey(const Key('dashboard-shortcut-simulator')));
    await tester.pumpAndSettle();

    expect(_location(tester), '/simulator');
    expect(find.text(dcaEducationRegular), findsOneWidget);
    await settleDriftStreams(tester);
  });

  testWidgets('keeps favorites visible when one quote fails', (tester) async {
    await _open(
      tester,
      favorites: const ['AAPL'],
      positions: const [
        _Lot('AAPL', 1, 100),
        _Lot('MSFT', 1, 40),
      ],
      quotes: {'AAPL': _quote('AAPL', 150)},
      errors: {'MSFT': const NetworkUnavailableException()},
    );

    expect(find.byKey(const ValueKey('favorite-entry-AAPL')), findsOneWidget);
    expect(_text(tester, const Key('dashboard-invested')), '140.00');
    expect(find.text(portfolioKnownValueLabel), findsOneWidget);
    expect(_text(tester, const Key('dashboard-current')), '150.00');
    expect(find.text(portfolioPartialPerformance), findsOneWidget);
    expect(find.byKey(const Key('dashboard-gain')), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('shows a valuation served from cache', (tester) async {
    final market = _Quotes({
      'AAPL': _quote('AAPL', 150, origin: DataOrigin.cache),
    });
    await _open(
      tester,
      positions: const [_Lot('AAPL', 1, 100)],
      market: market,
    );

    expect(market.quoteCalls, ['AAPL']);
    expect(_text(tester, const Key('dashboard-current')), '150.00');
    expect(find.textContaining('Exception'), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('displays the summary figures rather than raw inputs',
      (tester) async {
    await _open(
      tester,
      positions: const [_Lot('AAPL', 3, 10)],
      quotes: {'AAPL': _quote('AAPL', 12)},
    );

    expect(_text(tester, const Key('dashboard-invested')), '30.00');
    expect(_text(tester, const Key('dashboard-current')), '36.00');
    expect(find.text('3'), findsNothing);
    expect(find.text('10.00'), findsNothing);
    await settleDriftStreams(tester);
  });
}

Future<void> _open(
  WidgetTester tester, {
  List<_Lot> positions = const [],
  List<String> favorites = const [],
  Map<String, CachedResult<MarketQuote>> quotes = const {},
  Map<String, AppException> errors = const {},
  MarketDataRepository? market,
  bool app = false,
}) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final clock = FixedClock(DateTime.utc(2024, 6, 15));
  final portfolio = DriftPortfolioRepository(
    database.portfolioPositionDao,
    clock: clock,
  );
  for (final lot in positions) {
    await portfolio.addPosition(
      PortfolioPositionDraft(
        symbol: lot.symbol,
        quantity: lot.quantity,
        purchasePrice: lot.purchasePrice,
        purchaseDate: DateTime.utc(2024, 1, 2),
      ),
    );
  }
  final favoriteRepository = DriftFavoriteRepository(
    database.favoriteDao,
    clock: clock,
  );
  for (final symbol in favorites) {
    await favoriteRepository.addFavorite(symbol);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        if (favorites.isEmpty) emptyFavoritesOverride(),
        marketDataRepositoryProvider.overrideWithValue(
          market ?? _Quotes(quotes, errors),
        ),
        clockProvider.overrideWithValue(clock),
      ],
      child: app
          ? const VersaTechApp()
          : MaterialApp(
              theme: AppTheme.dark,
              home: const DashboardScreen(),
            ),
    ),
  );
  await tester.pumpAndSettle();
}

String _text(WidgetTester tester, Key key) {
  return tester.widget<Text>(find.byKey(key)).data!;
}

String _location(WidgetTester tester) {
  final context = tester.element(find.byType(VersaTechApp));
  return ProviderScope.containerOf(context)
      .read(appRouterProvider)
      .state
      .uri
      .path;
}

CachedResult<MarketQuote> _quote(
  String symbol,
  double price, {
  bool stale = false,
  DataOrigin origin = DataOrigin.remote,
  DateTime? updated,
}) {
  final at = updated ?? DateTime.utc(2024, 6, 3, 12);
  return CachedResult(
    data: MarketQuote(
      symbol: symbol,
      price: price,
      change: price - 100,
      changePercent: 1,
      timestamp: at,
    ),
    origin: stale ? DataOrigin.cache : origin,
    lastUpdatedAt: at,
    isStale: stale,
  );
}

class _Lot {
  const _Lot(this.symbol, this.quantity, this.purchasePrice);

  final String symbol;
  final double quantity;
  final double purchasePrice;
}

class _Quotes implements MarketDataRepository {
  _Quotes(this._quotes, [this._errors = const {}]);

  final Map<String, CachedResult<MarketQuote>> _quotes;
  final Map<String, AppException> _errors;
  final quoteCalls = <String>[];

  @override
  Future<CachedResult<MarketQuote>> getQuote(
    String symbol, {
    bool forceRefresh = false,
  }) async {
    quoteCalls.add(symbol);
    final error = _errors[symbol];
    if (error != null) {
      throw error;
    }
    return _quotes[symbol]!;
  }

  @override
  Future<CachedResult<List<Asset>>> searchAssets(
    String query, {
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CachedResult<AssetProfile>> getProfile(
    String symbol, {
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CachedResult<List<HistoricalPrice>>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }
}
