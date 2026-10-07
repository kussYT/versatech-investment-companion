import 'dart:async';

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
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/dca_messages.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/simulator_screen.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_rules.dart';

import '../../support/memory_database.dart';
import '../asset_detail/support/fake_market_data_repository.dart';

void main() {
  testWidgets('shows the form, the explanation and an empty chart',
      (tester) async {
    await _open(tester);

    expect(find.text('Investissement périodique'), findsOneWidget);
    expect(find.text(dcaEducationRegular), findsOneWidget);
    expect(find.text(dcaEducationPast), findsOneWidget);
    expect(find.text(dcaEducationNoGuarantee), findsOneWidget);
    expect(find.text(dcaEmptyChartMessage), findsOneWidget);
    expect(find.byKey(const Key('dca-chart')), findsNothing);
    expect(find.byKey(const Key('dca-final-value')), findsNothing);
  });

  testWidgets('requires a symbol', (tester) async {
    final history = await _open(tester);
    await _fill(tester, symbol: '');
    await _submit(tester);

    expect(find.text(dcaSymbolRequiredMessage), findsOneWidget);
    expect(history.calls, isEmpty);
  });

  testWidgets('rejects an invalid initial amount', (tester) async {
    await _open(tester);
    await _fill(tester, initial: '-1');
    await _submit(tester);

    expect(find.text(dcaInitialAmountMessage), findsOneWidget);
    expect(find.byKey(const Key('dca-final-value')), findsNothing);
  });

  testWidgets('rejects an invalid monthly amount', (tester) async {
    await _open(tester);
    await _fill(tester, monthly: '-5');
    await _submit(tester);

    expect(find.text(dcaMonthlyNegativeMessage), findsOneWidget);
  });

  testWidgets('rejects an initial amount and a monthly amount of zero',
      (tester) async {
    await _open(tester);
    await _fill(tester, initial: '0', monthly: '0');
    await _submit(tester);

    expect(find.text(dcaBothAmountsZeroMessage), findsOneWidget);
  });

  testWidgets('rejects a start date after the end date', (tester) async {
    await _open(tester);
    await _fill(tester, start: '01/06/2024', end: '01/01/2024');
    await _submit(tester);

    expect(find.text(dcaDateOrderMessage), findsOneWidget);
  });

  testWidgets('rejects an end date after today', (tester) async {
    await _open(tester);
    await _fill(tester, end: '16/06/2024');
    await _submit(tester);

    expect(find.text(dcaFutureMessage), findsOneWidget);
  });

  testWidgets('accepts a complete form', (tester) async {
    await _open(tester);
    await _fill(tester);
    await _submit(tester);

    expect(find.text(dcaSymbolRequiredMessage), findsNothing);
    expect(find.text(dcaInitialAmountMessage), findsNothing);
    expect(find.text(dcaBothAmountsZeroMessage), findsNothing);
    expect(find.byKey(const Key('dca-invested')), findsOneWidget);
  });

  testWidgets('shows a loading state until history returns', (tester) async {
    final gate = Completer<void>();
    final history = await _open(tester, gate: gate);
    await _fill(tester);
    await tester.ensureVisible(find.byKey(const Key('dca-submit')));
    await tester.tap(find.byKey(const Key('dca-submit')));
    await tester.pump();

    expect(find.text(dcaLoadingMessage), findsOneWidget);
    expect(history.calls, hasLength(1));
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text(dcaLoadingMessage), findsNothing);
  });

  testWidgets('shows invested capital, final value, gain and performance',
      (tester) async {
    final history = await _open(tester);
    await _fill(tester);
    await _submit(tester);

    expect(_text(tester, const Key('dca-invested')), '100.00');
    expect(_text(tester, const Key('dca-quantity')), '2');
    expect(_text(tester, const Key('dca-final-value')), '160.00');
    expect(find.text('Gain'), findsOneWidget);
    expect(_text(tester, const Key('dca-gain')), '+60.00');
    expect(_text(tester, const Key('dca-performance')), '+60.00 %');
    await tester.pump();
    expect(history.calls, hasLength(1));
  });

  testWidgets('shows a loss with a sign, an amount and a percent',
      (tester) async {
    await _open(tester, history: _lossHistory());
    await _fill(tester);
    await _submit(tester);

    expect(find.text('Perte'), findsOneWidget);
    expect(_text(tester, const Key('dca-final-value')), '80.00');
    expect(_text(tester, const Key('dca-gain')), '-20.00');
    expect(_text(tester, const Key('dca-performance')), '-20.00 %');
    expect(find.byIcon(Icons.trending_down), findsOneWidget);
  });

  testWidgets('draws invested capital and simulated value', (tester) async {
    await _open(tester);
    await _fill(tester);
    await _submit(tester);

    final chart = tester.widget<LineChart>(
      find.descendant(
        of: find.byKey(const Key('dca-chart')),
        matching: find.byType(LineChart),
      ),
    );
    expect(chart.data.lineBarsData, hasLength(2));
    expect(find.text(dcaInvestedSeries), findsWidgets);
    expect(find.text(dcaValueSeries), findsOneWidget);
    expect(find.byKey(const Key('dca-chart-empty')), findsNothing);
  });

  testWidgets('keeps a stale history visible and names it as stored data',
      (tester) async {
    await _open(tester, history: _gainHistory(stale: true));
    await _fill(tester);
    await _submit(tester);

    expect(find.text(dcaStaleMessage), findsOneWidget);
    expect(find.text('01/06/2024 15:30 UTC'), findsOneWidget);
    expect(_text(tester, const Key('dca-final-value')), '160.00');
    expect(find.textContaining('temps réel'), findsNothing);
  });

  testWidgets('opens the simulator from the asset page with the symbol',
      (tester) async {
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
    ProviderScope.containerOf(context)
        .read(appRouterProvider)
        .go('/explorer/AAPL');
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ajouter AAPL aux favoris'), findsOneWidget);
    expect(find.byKey(const Key('add-to-portfolio')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('simulate-investment')));
    await tester.tap(find.byKey(const Key('simulate-investment')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('dca-symbol')))
          .controller
          ?.text,
      'AAPL',
    );
    expect(find.text(dcaEducationRegular), findsOneWidget);
    await settleDriftStreams(tester);
  });

  testWidgets('counts the final value up and then stays exact', (tester) async {
    await _open(tester);
    await _fill(tester);
    await tester.ensureVisible(find.byKey(const Key('dca-submit')));
    await tester.tap(find.byKey(const Key('dca-submit')));
    await tester.pump();
    await tester.pump();

    expect(_text(tester, const Key('dca-final-value')), '0.00');
    await tester.pump(const Duration(milliseconds: 400));
    final midway = _text(tester, const Key('dca-final-value'));
    expect(midway, isNot('0.00'));
    expect(midway, isNot('160.00'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_text(tester, const Key('dca-final-value')), '160.00');
    await tester.pump();
    expect(_text(tester, const Key('dca-final-value')), '160.00');
  });
}

Future<_History> _open(
  WidgetTester tester, {
  CachedResult<List<HistoricalPrice>>? history,
  Completer<void>? gate,
}) async {
  final repository = _History(history ?? _gainHistory(), gate: gate);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        marketDataRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(FixedClock(DateTime.utc(2024, 6, 15))),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const SimulatorScreen(),
      ),
    ),
  );
  await tester.pump();
  return repository;
}

Future<void> _fill(
  WidgetTester tester, {
  String symbol = 'AAPL',
  String initial = '100',
  String monthly = '0',
  String start = '02/01/2024',
  String end = '14/06/2024',
}) async {
  await tester.enterText(find.byKey(const Key('dca-symbol')), symbol);
  await tester.enterText(find.byKey(const Key('dca-initial')), initial);
  await tester.enterText(find.byKey(const Key('dca-monthly')), monthly);
  await tester.enterText(find.byKey(const Key('dca-start')), start);
  await tester.enterText(find.byKey(const Key('dca-end')), end);
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('dca-submit')));
  await tester.tap(find.byKey(const Key('dca-submit')));
  await tester.pumpAndSettle();
}

String _text(WidgetTester tester, Key key) {
  return tester.widget<Text>(find.byKey(key)).data!;
}

CachedResult<List<HistoricalPrice>> _gainHistory({bool stale = false}) {
  return CachedResult(
    data: [
      _close(DateTime.utc(2024, 1, 2), 50),
      _close(DateTime.utc(2024, 6, 14), 80),
    ],
    origin: stale ? DataOrigin.cache : DataOrigin.remote,
    lastUpdatedAt: DateTime.utc(2024, 6, 1, 15, 30),
    isStale: stale,
  );
}

CachedResult<List<HistoricalPrice>> _lossHistory() {
  return CachedResult(
    data: [
      _close(DateTime.utc(2024, 1, 2), 100),
      _close(DateTime.utc(2024, 6, 14), 80),
    ],
    origin: DataOrigin.remote,
    lastUpdatedAt: DateTime.utc(2024, 6, 1, 15, 30),
    isStale: false,
  );
}

HistoricalPrice _close(DateTime date, double price) {
  return HistoricalPrice(
    symbol: 'AAPL',
    date: date,
    open: price,
    high: price,
    low: price,
    close: price,
    volume: 1,
  );
}

class _History implements MarketDataRepository {
  _History(this.result, {this.gate});

  final CachedResult<List<HistoricalPrice>> result;
  final Completer<void>? gate;
  final calls = <bool>[];

  @override
  Future<CachedResult<List<HistoricalPrice>>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
    bool forceRefresh = false,
  }) async {
    calls.add(forceRefresh);
    final pending = gate;
    if (pending != null) {
      await pending.future;
    }
    return result;
  }

  @override
  Future<CachedResult<AssetProfile>> getProfile(
    String symbol, {
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CachedResult<MarketQuote>> getQuote(
    String symbol, {
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CachedResult<List<Asset>>> searchAssets(
    String query, {
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }
}
