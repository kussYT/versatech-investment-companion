import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/app/app.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/app_database_provider.dart';
import 'package:versatech_investment_companion/features/explorer/application/explorer_search_controller.dart';
import 'package:versatech_investment_companion/features/explorer/application/search_debounce.dart';
import 'package:versatech_investment_companion/features/favorites/application/favorites_providers.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_messages.dart';
import 'package:versatech_investment_companion/features/market_data/data/datasources/local_market_data_source.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';

import '../../support/memory_database.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  testWidgets('shows an empty favorites list on the home screen',
      (tester) async {
    await _pumpApp(tester, repository: _QuietRepository());

    expect(find.text(favoriteEmptyTitle), findsOneWidget);
    expect(find.text(favoriteEmptyExplanation), findsOneWidget);
    expect(find.textContaining('SQL'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('adds and removes a favorite from Explorer without opening it',
      (tester) async {
    final repository = _QuietRepository(
      assets: [
        _asset(),
        _asset(symbol: 'SPY', name: 'SPDR', type: AssetType.etf)
      ],
    );
    await _pumpApp(tester, repository: repository);
    await _openExplorer(tester);
    await tester.enterText(find.byType(TextField), 'market');
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ajouter AAPL aux favoris'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsWidgets);
    final searchesBeforeFavorite = repository.searchCalls;

    await tester.tap(find.byKey(const ValueKey('favorite-AAPL')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(_scale(tester, 'AAPL'), greaterThan(1));
    await tester.pumpAndSettle();

    expect(find.text('Historique des clôtures'), findsNothing);
    expect(find.byTooltip('Retirer AAPL des favoris'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(repository.searchCalls, searchesBeforeFavorite);

    await tester.tap(find.byKey(const ValueKey('asset-AAPL')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Retirer AAPL des favoris'), findsWidgets);
    expect(find.byIcon(Icons.bookmark), findsWidgets);

    await tester.tap(find.byTooltip('Retirer AAPL des favoris').hitTestable());
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ajouter AAPL aux favoris'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ajouter AAPL aux favoris'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsNothing);
    await settleDriftStreams(tester);
  });

  testWidgets('a detail change is visible again in Explorer', (tester) async {
    final repository = _QuietRepository(assets: [_asset()]);
    await _pumpApp(tester, repository: repository);
    await _openExplorer(tester);
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('asset-AAPL')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('favorite-AAPL')).hitTestable());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.bookmark), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Retirer AAPL des favoris'), findsOneWidget);
    await settleDriftStreams(tester);
  });

  testWidgets('lists cached metadata and a symbol that has none',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final local = LocalMarketDataSource(database.marketDataDao);
    await local.saveAssets(
      assets: [_asset()],
      syncedAt: DateTime.utc(2024, 6, 3, 12),
      resourceKey: 'search:apple',
      symbolList: 'AAPL',
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        marketDataRepositoryProvider.overrideWithValue(_QuietRepository()),
        searchDebounceProvider.overrideWithValue(ImmediateSearchDebounce()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(favoriteRepositoryProvider).addFavorite('aapl');
    await container.read(favoriteRepositoryProvider).addFavorite('ZZZZ');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VersaTechApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AAPL'), findsOneWidget);
    expect(find.text('Apple Inc.'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('NASDAQ · USD'), findsOneWidget);
    expect(find.text('ZZZZ'), findsOneWidget);
    expect(find.text('N/A'), findsNothing);
    expect(find.textContaining('Inconnu'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('favorite-entry-AAPL')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Historique des clôtures'),
      200,
    );
    expect(find.text('Historique des clôtures'), findsOneWidget);
    expect(find.byTooltip('Retirer AAPL des favoris'), findsOneWidget);
    await settleDriftStreams(tester);
  });

  testWidgets('keeps the previous icon when a local write fails',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      try {
        await database.close();
      } on Object {
        // Closed on purpose before the failing tap.
      }
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          marketDataRepositoryProvider.overrideWithValue(
            _QuietRepository(assets: [_asset()]),
          ),
          searchDebounceProvider.overrideWithValue(ImmediateSearchDebounce()),
        ],
        child: const VersaTechApp(),
      ),
    );
    await tester.pumpAndSettle();
    await _openExplorer(tester);
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pumpAndSettle();
    await database.close();

    await tester.tap(find.byKey(const ValueKey('favorite-AAPL')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(favoriteWriteErrorMessage), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsNothing);
    expect(find.textContaining('SQL'), findsNothing);
    expect(find.textContaining('Sqlite'), findsNothing);
    expect(find.textContaining('closing'), findsNothing);
    await settleDriftStreams(tester);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required MarketDataRepository repository,
}) {
  return tester
      .pumpWidget(
        ProviderScope(
          overrides: [
            memoryDatabaseOverride(),
            marketDataRepositoryProvider.overrideWithValue(repository),
            searchDebounceProvider.overrideWithValue(ImmediateSearchDebounce()),
          ],
          child: const VersaTechApp(),
        ),
      )
      .then((_) => tester.pumpAndSettle());
}

Future<void> _openExplorer(WidgetTester tester) async {
  await tester.tap(find.text('Explorer'));
  await tester.pumpAndSettle();
}

double _scale(WidgetTester tester, String symbol) {
  final transform = tester.widget<Transform>(
    find.descendant(
      of: find.byKey(ValueKey('favorite-$symbol')),
      matching: find.byKey(const Key('favorite-scale')),
    ),
  );
  return transform.transform.storage[0];
}

class _QuietRepository implements MarketDataRepository {
  _QuietRepository({this.assets = const []});

  final List<Asset> assets;
  var searchCalls = 0;

  @override
  Future<CachedResult<List<Asset>>> searchAssets(
    String query, {
    bool forceRefresh = false,
  }) async {
    searchCalls += 1;
    return CachedResult(
      data: assets,
      origin: DataOrigin.cache,
      lastUpdatedAt: DateTime.utc(2024, 6, 3, 12),
      isStale: true,
    );
  }

  @override
  Future<CachedResult<AssetProfile>> getProfile(
    String symbol, {
    bool forceRefresh = false,
  }) async {
    return CachedResult(
      data: AssetProfile(
        symbol: symbol,
        companyName: 'Apple Inc.',
        description: 'Conçoit des appareils.',
        currency: 'USD',
        exchange: 'NASDAQ',
      ),
      origin: DataOrigin.cache,
      lastUpdatedAt: DateTime.utc(2024, 6, 3, 12),
      isStale: true,
    );
  }

  @override
  Future<CachedResult<MarketQuote>> getQuote(
    String symbol, {
    bool forceRefresh = false,
  }) async {
    return CachedResult(
      data: MarketQuote(
        symbol: symbol,
        price: 190,
        change: 1,
        changePercent: 0.5,
        timestamp: DateTime.utc(2024, 6, 3, 20),
      ),
      origin: DataOrigin.cache,
      lastUpdatedAt: DateTime.utc(2024, 6, 3, 12),
      isStale: true,
    );
  }

  @override
  Future<CachedResult<List<HistoricalPrice>>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
    bool forceRefresh = false,
  }) async {
    return CachedResult(
      data: [
        HistoricalPrice(
          symbol: symbol,
          date: to,
          open: 180,
          high: 191,
          low: 179,
          close: 190,
          volume: 10,
        ),
      ],
      origin: DataOrigin.cache,
      lastUpdatedAt: DateTime.utc(2024, 6, 3, 12),
      isStale: true,
    );
  }
}

Asset _asset({
  String symbol = 'AAPL',
  String name = 'Apple Inc.',
  AssetType type = AssetType.stock,
}) {
  return Asset(
    symbol: symbol,
    name: name,
    type: type,
    exchange: 'NASDAQ',
    currency: 'USD',
  );
}
