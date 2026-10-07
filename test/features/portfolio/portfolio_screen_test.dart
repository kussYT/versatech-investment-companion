import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/app/app.dart';
import 'package:versatech_investment_companion/app/router/app_router.dart';
import 'package:versatech_investment_companion/app/theme/app_theme.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/app_database_provider.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
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
import 'package:versatech_investment_companion/features/portfolio/presentation/position_form_screen.dart';

import '../../support/memory_database.dart';
import '../asset_detail/support/fake_market_data_repository.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  testWidgets('shows an empty portfolio', (tester) async {
    await _openPortfolio(tester, market: _Quotes());

    expect(find.text(portfolioEmptyTitle), findsOneWidget);
    expect(find.text(portfolioEmptyExplanation), findsOneWidget);
    expect(find.textContaining('SQL'), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('accepts a complete position form', (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes({'AAPL': _quote('AAPL', 110)}),
    );
    await tester.tap(find.byKey(const Key('portfolio-empty-add')));
    await tester.pumpAndSettle();
    await _fillValid(tester);
    await _submit(tester);

    expect(find.text(quantityPositiveMessage), findsNothing);
    expect(find.text(pricePositiveMessage), findsNothing);
    expect(find.text(dateFutureMessage), findsNothing);
    expect(find.text('Nouvelle position'), findsNothing);
    expect(find.text('AAPL'), findsWidgets);
    await settleDriftStreams(tester);
  });

  testWidgets('rejects a zero quantity', (tester) async {
    final database = await _openForm(tester);
    await _fillValid(tester, quantity: '0');
    await _submit(tester);

    expect(find.text(quantityPositiveMessage), findsOneWidget);
    expect(find.text('Nouvelle position'), findsOneWidget);
    expect(await database.portfolioPositionDao.getAll(), isEmpty);
    await settleDriftStreams(tester);
  });

  testWidgets('rejects a negative quantity', (tester) async {
    final database = await _openForm(tester);
    await _fillValid(tester, quantity: '-2');
    await _submit(tester);

    expect(find.text(quantityPositiveMessage), findsOneWidget);
    expect(await database.portfolioPositionDao.getAll(), isEmpty);
    await settleDriftStreams(tester);
  });

  testWidgets('rejects a zero purchase price', (tester) async {
    final database = await _openForm(tester);
    await _fillValid(tester, price: '0');
    await _submit(tester);

    expect(find.text(pricePositiveMessage), findsOneWidget);
    expect(await database.portfolioPositionDao.getAll(), isEmpty);
    await settleDriftStreams(tester);
  });

  testWidgets('rejects a negative purchase price', (tester) async {
    final database = await _openForm(tester);
    await _fillValid(tester, price: '-5');
    await _submit(tester);

    expect(find.text(pricePositiveMessage), findsOneWidget);
    expect(await database.portfolioPositionDao.getAll(), isEmpty);
    await settleDriftStreams(tester);
  });

  testWidgets('rejects a future purchase date', (tester) async {
    final database = await _openForm(tester);
    await _fillValid(tester, date: '04/06/2024');
    await _submit(tester);

    expect(find.text(dateFutureMessage), findsOneWidget);
    expect(await database.portfolioPositionDao.getAll(), isEmpty);
    await settleDriftStreams(tester);
  });

  testWidgets('saves a position from the form and shows it', (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes({'AAPL': _quote('AAPL', 150)}),
    );
    await tester.tap(find.byKey(const Key('portfolio-empty-add')));
    await tester.pumpAndSettle();
    await _fillValid(tester, quantity: '1', price: '100');
    await _submit(tester);

    expect(find.text('AAPL'), findsWidgets);
    expect(find.text('Quantité 1'), findsOneWidget);
    expect(find.textContaining('100.00'), findsWidgets);
    await settleDriftStreams(tester);
  });

  testWidgets('shows invested amount, current value and a gain',
      (tester) async {
    final market = _Quotes({'AAPL': _quote('AAPL', 150)});
    await _openPortfolio(
      tester,
      market: market,
      positions: [_draft(quantity: 1, purchasePrice: 100)],
    );

    expect(_text(tester, const Key('total-invested')), '100.00');
    expect(_text(tester, const Key('total-current')), '150.00');
    expect(_text(tester, const Key('total-gain')), '+50.00');
    expect(_text(tester, const Key('total-performance')), '+50.00 %');
    expect(find.text('Gain'), findsWidgets);
    expect(market.quoteCalls, ['AAPL']);

    await tester.pump();
    expect(market.quoteCalls, ['AAPL']);
    await settleDriftStreams(tester);
  });

  testWidgets('shows a loss with a sign, an amount and a percent',
      (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes({'AAPL': _quote('AAPL', 80)}),
      positions: [_draft(quantity: 1, purchasePrice: 100)],
    );

    expect(_text(tester, const Key('total-current')), '80.00');
    expect(_text(tester, const Key('total-gain')), '-20.00');
    expect(_text(tester, const Key('total-performance')), '-20.00 %');
    expect(find.text('Perte'), findsWidgets);
    await settleDriftStreams(tester);
  });

  testWidgets('shows the weighted quantity of two lots', (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes({'AAPL': _quote('AAPL', 180)}),
      positions: [
        _draft(quantity: 2, purchasePrice: 150),
        _draft(quantity: 1, purchasePrice: 170),
      ],
    );

    expect(find.text('Quantité 3'), findsOneWidget);
    expect(find.text('Prix moyen 156.67'), findsOneWidget);
    expect(_text(tester, const Key('total-invested')), '470.00');
    expect(_text(tester, const Key('total-current')), '540.00');
    expect(_text(tester, const Key('total-gain')), '+70.00');
    await settleDriftStreams(tester);
  });

  testWidgets('keeps a stale quote visible and labels it as stored data',
      (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes({
        'AAPL': _quote(
          'AAPL',
          150,
          stale: true,
          updated: DateTime.utc(2024, 6, 1, 15, 30),
        ),
      }),
      positions: [_draft(quantity: 1, purchasePrice: 100)],
    );

    expect(find.text(portfolioStaleMessage), findsOneWidget);
    expect(find.textContaining('01/06/2024 15:30 UTC'), findsOneWidget);
    expect(_text(tester, const Key('total-current')), '150.00');
    expect(find.textContaining('temps réel'), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('keeps the position when the quote is missing', (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes(),
      positions: [_draft(quantity: 1, purchasePrice: 100)],
    );

    expect(_text(tester, const Key('total-invested')), '100.00');
    expect(find.text(portfolioValueUnavailable), findsWidgets);
    expect(find.text(portfolioPerformanceUnavailable), findsOneWidget);
    expect(find.text(portfolioAllocationUnavailable), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);
    expect(find.text('0.00'), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('keeps the other holding when one quote fails', (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes.partial(
        {'AAPL': _quote('AAPL', 150)},
        {'MSFT': const NetworkUnavailableException()},
      ),
      positions: [
        _draft(quantity: 1, purchasePrice: 100),
        _draft(symbol: 'MSFT', quantity: 1, purchasePrice: 40),
      ],
    );

    expect(find.text('Valeur 150.00'), findsOneWidget);
    expect(find.text(portfolioValueUnavailable), findsOneWidget);
    expect(find.text(portfolioPartialPerformance), findsOneWidget);
    expect(find.textContaining('MSFT est exclu'), findsOneWidget);
    expect(find.text('Investi 40.00'), findsOneWidget);
    expect(find.textContaining('SQL'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.byType(PieChart), findsOneWidget);
    await settleDriftStreams(tester);
  });

  testWidgets('draws one slice per priced asset', (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes({
        'AAPL': _quote('AAPL', 150),
        'MSFT': _quote('MSFT', 50),
      }),
      positions: [
        _draft(quantity: 1, purchasePrice: 100),
        _draft(symbol: 'MSFT', quantity: 1, purchasePrice: 100),
      ],
    );

    expect(find.byType(PieChart), findsOneWidget);
    expect(find.byKey(const Key('portfolio-allocation-chart')), findsOneWidget);
    expect(find.text('75.00 %'), findsOneWidget);
    expect(find.text('25.00 %'), findsOneWidget);
    expect(find.text('AAPL'), findsWidgets);
    expect(find.text('MSFT'), findsWidgets);
    await settleDriftStreams(tester);
  });

  testWidgets('opens the prefilled form from the asset page', (tester) async {
    final repository = FakeMarketDataRepository(
      profileResult: detailResult(detailProfile()),
      quoteResult: detailResult(detailQuote()),
      historyResult: detailResult([
        detailBar(date: DateTime.utc(2024, 3, 1), close: 150),
      ]),
    );
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          emptyFavoritesOverride(),
          marketDataRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(FixedClock(DateTime.utc(2024, 6, 3))),
        ],
        child: const VersaTechApp(),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(VersaTechApp));
    ProviderScope.containerOf(context).read(appRouterProvider).go(
          '/explorer/AAPL',
        );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ajouter AAPL aux favoris'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('add-to-portfolio')));
    await tester.tap(find.byKey(const Key('add-to-portfolio')));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle position'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('position-symbol')))
          .controller
          ?.text,
      'AAPL',
    );
    await settleDriftStreams(tester);
  });

  testWidgets('recalculates totals after a position is deleted',
      (tester) async {
    await _openPortfolio(
      tester,
      market: _Quotes({
        'AAPL': _quote('AAPL', 150),
        'MSFT': _quote('MSFT', 50),
      }),
      positions: [
        _draft(quantity: 1, purchasePrice: 100),
        _draft(symbol: 'MSFT', quantity: 1, purchasePrice: 100),
      ],
    );
    expect(_text(tester, const Key('total-invested')), '200.00');
    expect(_text(tester, const Key('total-current')), '200.00');

    final deleteButton = find.byTooltip(
      'Supprimer la position MSFT du 03/06/2024',
    );
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();

    expect(find.text('MSFT'), findsNothing);
    expect(_text(tester, const Key('total-invested')), '100.00');
    expect(_text(tester, const Key('total-current')), '150.00');
    expect(_text(tester, const Key('total-gain')), '+50.00');
    await settleDriftStreams(tester);
  });
}

Future<void> _openPortfolio(
  WidgetTester tester, {
  required MarketDataRepository market,
  List<PortfolioPositionDraft> positions = const [],
}) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final clock = FixedClock(DateTime.utc(2024, 6, 3, 12));
  final seeder = DriftPortfolioRepository(
    database.portfolioPositionDao,
    clock: clock,
  );
  for (final draft in positions) {
    await seeder.addPosition(draft);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(clock),
        marketDataRepositoryProvider.overrideWithValue(market),
        emptyFavoritesOverride(),
      ],
      child: const VersaTechApp(),
    ),
  );
  await tester.pumpAndSettle();
  final context = tester.element(find.byType(VersaTechApp));
  ProviderScope.containerOf(context).read(appRouterProvider).go('/portfolio');
  await tester.pumpAndSettle();
}

Future<AppDatabase> _openForm(WidgetTester tester) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(FixedClock(DateTime.utc(2024, 6, 3))),
        marketDataRepositoryProvider.overrideWithValue(_Quotes()),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const PositionFormScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return database;
}

Future<void> _fillValid(
  WidgetTester tester, {
  String quantity = '1',
  String price = '10',
  String date = '03/06/2024',
}) async {
  await tester.enterText(find.byKey(const Key('position-symbol')), 'AAPL');
  await tester.enterText(find.byKey(const Key('position-quantity')), quantity);
  await tester.enterText(find.byKey(const Key('position-price')), price);
  await tester.enterText(find.byKey(const Key('position-date')), date);
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('position-submit')));
  await tester.tap(find.byKey(const Key('position-submit')));
  await tester.pumpAndSettle();
}

String _text(WidgetTester tester, Key key) {
  return tester.widget<Text>(find.byKey(key)).data!;
}

PortfolioPositionDraft _draft({
  String symbol = 'AAPL',
  double quantity = 1,
  double purchasePrice = 100,
}) {
  return PortfolioPositionDraft(
    symbol: symbol,
    quantity: quantity,
    purchasePrice: purchasePrice,
    purchaseDate: DateTime.utc(2024, 6, 3),
  );
}

CachedResult<MarketQuote> _quote(
  String symbol,
  double price, {
  bool stale = false,
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
    origin: stale ? DataOrigin.cache : DataOrigin.remote,
    lastUpdatedAt: at,
    isStale: stale,
  );
}

class _Quotes implements MarketDataRepository {
  _Quotes([
    Map<String, CachedResult<MarketQuote>> quotes = const {},
  ])  : _quotes = quotes,
        _errors = const {};

  _Quotes.partial(
    Map<String, CachedResult<MarketQuote>> quotes,
    Map<String, AppException> errors,
  )   : _quotes = quotes,
        _errors = errors;

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
    final quote = _quotes[symbol];
    if (quote == null) {
      throw const MarketDataNotFoundException();
    }
    return quote;
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
