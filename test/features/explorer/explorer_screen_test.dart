import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/app/app.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/errors/failure.dart';
import 'package:versatech_investment_companion/features/explorer/application/explorer_search_controller.dart';
import 'package:versatech_investment_companion/features/explorer/application/search_debounce.dart';
import 'package:versatech_investment_companion/features/explorer/presentation/explorer_messages.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';

void main() {
  test('translates failures without exposing technical details', () {
    expect(
      explorerFailureMessage(const NetworkUnavailableException().failure),
      'Connexion indisponible. Les données distantes ne peuvent pas être récupérées.',
    );
    expect(
      explorerFailureMessage(const RateLimitException().failure),
      'Le quota de l’API est atteint. Patientez avant une nouvelle recherche.',
    );
    expect(
      explorerFailureMessage(const RequestTimeoutException().failure),
      contains('délai de réponse'),
    );
    expect(
      explorerFailureMessage(const UnauthorizedException().failure),
      contains('refusé'),
    );
    expect(
      explorerFailureMessage(const MissingApiKeyException().failure),
      contains('clé API'),
    );
    expect(
      explorerFailureMessage(const MissingApiKeyException().failure),
      isNot(contains('FMP_API_KEY')),
    );
    expect(
      explorerFailureMessage(const UnknownRemoteException().failure),
      contains('momentanément indisponible'),
    );
  });

  testWidgets('shows the initial prompt before a search', (tester) async {
    await _openExplorer(tester, repository: _ScriptedRepository());

    expect(find.text('Explorer'), findsWidgets);
    expect(find.text('Recherchez une action ou un ETF'), findsOneWidget);
    expect(find.text('Aucun actif trouvé'), findsNothing);
  });

  testWidgets('shows stocks and ETFs as distinct results', (tester) async {
    final repository = _ScriptedRepository(
      result: CachedResult(
        data: [
          _asset(),
          _asset(
            symbol: 'SPY',
            name: 'SPDR S&P 500 ETF Trust',
            type: AssetType.etf,
            exchange: 'NYSE',
          ),
          _asset(
            symbol: 'BRK.B',
            name: 'Berkshire Hathaway',
            exchange: '',
            currency: '',
          ),
        ],
        origin: DataOrigin.remote,
        lastUpdatedAt: DateTime.utc(2024, 6, 3, 12),
        isStale: false,
      ),
    );

    await _openExplorer(tester, repository: repository);
    await tester.enterText(find.byType(TextField), 'market');
    await tester.pumpAndSettle();

    expect(find.text('Action'), findsNWidgets(2));
    expect(find.text('ETF'), findsOneWidget);
    expect(find.text('AAPL'), findsOneWidget);
    expect(find.text('NASDAQ · USD'), findsOneWidget);
    expect(find.text('NYSE · USD'), findsOneWidget);
    expect(find.text('Berkshire Hathaway'), findsOneWidget);
    expect(find.textContaining('N/A'), findsNothing);
    expect(find.text('Données enregistrées'), findsNothing);
  });

  testWidgets('shows an empty result separately from the initial state',
      (tester) async {
    await _openExplorer(
      tester,
      repository: _ScriptedRepository(
        result: const CachedResult(
          data: [],
          origin: DataOrigin.remote,
          lastUpdatedAt: null,
          isStale: false,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('Aucun actif trouvé'), findsOneWidget);
    expect(find.text('Recherchez une action ou un ETF'), findsNothing);
  });

  testWidgets('shows a stored stale result and its synchronization time',
      (tester) async {
    await _openExplorer(
      tester,
      repository: _ScriptedRepository(
        result: CachedResult(
          data: [_asset()],
          origin: DataOrigin.cache,
          lastUpdatedAt: DateTime.utc(2024, 6, 3, 12),
          isStale: true,
          remoteFailure: const Failure(FailureCode.networkUnavailable),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pumpAndSettle();

    expect(find.text('AAPL'), findsOneWidget);
    expect(
      find.text('Hors connexion — données du 03/06/2024 12:00 UTC'),
      findsOneWidget,
    );
  });

  testWidgets('shows the network message when nothing is cached',
      (tester) async {
    await _openExplorer(
      tester,
      repository: _ScriptedRepository(
        error: const NetworkUnavailableException(),
      ),
    );
    await tester.enterText(find.byType(TextField), 'AAPL');
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Connexion indisponible. Les données distantes ne peuvent pas être récupérées.',
      ),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.byKey(const ValueKey('asset-AAPL')), findsNothing);
  });

  testWidgets('shows the quota message', (tester) async {
    await _openExplorer(
      tester,
      repository: _ScriptedRepository(error: const RateLimitException()),
    );
    await tester.enterText(find.byType(TextField), 'AAPL');
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Le quota de l’API est atteint. Patientez avant une nouvelle recherche.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a loading indicator while the search is running',
      (tester) async {
    final repository = _ScriptedRepository(result: _remote([_asset()]));
    repository.gate = Completer<void>();
    await _openExplorer(tester, repository: repository);

    await tester.enterText(find.byType(TextField), 'AAPL');
    await tester.pump();

    expect(find.text('Recherche en cours'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('asset-AAPL')), findsOneWidget);
  });

  testWidgets('opens the temporary asset page for the selected symbol',
      (tester) async {
    await _openExplorer(
      tester,
      repository:
          _ScriptedRepository(result: _remote([_asset(symbol: 'BRK.B')])),
    );
    await tester.enterText(find.byType(TextField), 'berkshire');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('asset-BRK.B')));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de BRK.B'), findsOneWidget);
    expect(find.text('BRK.B'), findsWidgets);
  });
}

Future<void> _openExplorer(
  WidgetTester tester, {
  required MarketDataRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        marketDataRepositoryProvider.overrideWithValue(repository),
        searchDebounceProvider.overrideWithValue(ImmediateSearchDebounce()),
      ],
      child: const VersaTechApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Explorer'));
  await tester.pumpAndSettle();
}

class _ScriptedRepository implements MarketDataRepository {
  _ScriptedRepository({this.result, this.error});

  CachedResult<List<Asset>>? result;
  AppException? error;
  Completer<void>? gate;

  @override
  Future<CachedResult<List<Asset>>> searchAssets(
    String query, {
    bool forceRefresh = false,
  }) async {
    final pending = gate;
    if (pending != null) {
      await pending.future;
    }
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return result!;
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
  Future<CachedResult<List<HistoricalPrice>>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }
}

CachedResult<List<Asset>> _remote(List<Asset> assets) {
  return CachedResult(
    data: assets,
    origin: DataOrigin.remote,
    lastUpdatedAt: DateTime.utc(2024, 6, 3, 12),
    isStale: false,
  );
}

Asset _asset({
  String symbol = 'AAPL',
  String name = 'Apple Inc.',
  AssetType type = AssetType.stock,
  String exchange = 'NASDAQ',
  String currency = 'USD',
}) {
  return Asset(
    symbol: symbol,
    name: name,
    type: type,
    exchange: exchange,
    currency: currency,
  );
}
