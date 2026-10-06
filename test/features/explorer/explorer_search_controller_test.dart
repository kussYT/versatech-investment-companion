import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/errors/failure.dart';
import 'package:versatech_investment_companion/features/explorer/application/explorer_search_controller.dart';
import 'package:versatech_investment_companion/features/explorer/application/explorer_search_state.dart';
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
  late ProviderContainer container;
  late ManualSearchDebounce debounce;
  late _FakeMarketDataRepository repository;

  setUp(() {
    debounce = ManualSearchDebounce();
    repository = _FakeMarketDataRepository();
    container = ProviderContainer(
      overrides: [
        marketDataRepositoryProvider.overrideWithValue(repository),
        searchDebounceProvider.overrideWithValue(debounce),
      ],
    );
  });

  tearDown(() => container.dispose());

  ExplorerSearchState readState() {
    return container.read(explorerSearchControllerProvider);
  }

  ExplorerSearchController readController() {
    return container.read(explorerSearchControllerProvider.notifier);
  }

  test('starts without searching', () {
    expect(readState(), isA<ExplorerInitial>());
    expect(repository.searches, isEmpty);
  });

  test('does not search a blank query', () async {
    readController().onQueryChanged('   ');

    expect(readState(), isA<ExplorerInitial>());
    expect(debounce.pending, isNull);
    await debounce.flush();
    expect(repository.searches, isEmpty);
  });

  test('debounces keystrokes and keeps only the latest query', () async {
    repository.result = _result([_asset()]);
    final controller = readController();

    controller.onQueryChanged('AA');
    controller.onQueryChanged('AAPL');

    expect(repository.searches, isEmpty);
    expect(debounce.lastDelay, ExplorerSearchController.debounceDelay);
    expect(readState(), const ExplorerLoading('AAPL'));

    await debounce.flush();

    expect(repository.searches, [
      (query: 'AAPL', forceRefresh: false),
    ]);
    expect((readState() as ExplorerReady).assets.single.symbol, 'AAPL');
  });

  test('cancels a pending search when the field is cleared', () async {
    readController().onQueryChanged('AAPL');
    readController().onQueryChanged('   ');

    expect(readState(), isA<ExplorerInitial>());
    await debounce.flush();
    expect(repository.searches, isEmpty);
  });

  test('trims the query before calling the repository', () async {
    repository.result = _result([_asset()]);

    readController().onQueryChanged('  aapl  ');
    await debounce.flush();

    expect(repository.searches.single.query, 'aapl');
  });

  test('shows loading until the repository answers', () async {
    repository.result = _result([_asset()]);
    repository.gate = Completer<void>();
    readController().onQueryChanged('AAPL');

    final pending = debounce.flush();
    await Future<void>.delayed(Duration.zero);

    expect(readState(), const ExplorerLoading('AAPL'));
    expect(repository.searches, hasLength(1));

    repository.gate!.complete();
    await pending;
    expect(readState(), isA<ExplorerReady>());
  });

  test('returns matching assets', () async {
    repository.result =
        _result([_asset(), _asset(symbol: 'MSFT', name: 'Microsoft')]);

    readController().onQueryChanged('apple');
    await debounce.flush();

    final state = readState() as ExplorerReady;
    expect(state.assets.map((asset) => asset.symbol), ['AAPL', 'MSFT']);
    expect(state.isEmpty, isFalse);
    expect(state.origin, DataOrigin.remote);
    expect(state.isStale, isFalse);
  });

  test('reports an empty result without turning it into an error', () async {
    repository.result = _result(const []);

    readController().onQueryChanged('zzzz');
    await debounce.flush();

    final state = readState() as ExplorerReady;
    expect(state.isEmpty, isTrue);
    expect(state, isNot(isA<ExplorerFailureState>()));
  });

  test('exposes a remote failure when no cache exists', () async {
    repository.error = const NetworkUnavailableException();

    readController().onQueryChanged('AAPL');
    await debounce.flush();

    final state = readState() as ExplorerFailureState;
    expect(state.failure.code, FailureCode.networkUnavailable);
    expect(
      explorerFailureMessage(state.failure),
      contains('Connexion indisponible'),
    );
  });

  test('exposes a fresh cache and its synchronization time', () async {
    final updatedAt = DateTime.utc(2024, 6, 3, 12);
    repository.result = _result(
      [_asset()],
      origin: DataOrigin.cache,
      lastUpdatedAt: updatedAt,
    );

    readController().onQueryChanged('apple');
    await debounce.flush();

    final state = readState() as ExplorerReady;
    expect(state.origin, DataOrigin.cache);
    expect(state.isStale, isFalse);
    expect(state.lastUpdatedAt, updatedAt);
    expect(
      explorerSyncStatus(state),
      'Données enregistrées — dernière mise à jour : 03/06/2024 12:00 UTC',
    );
  });

  test('exposes a stale offline cache', () async {
    final updatedAt = DateTime.utc(2024, 6, 3, 12);
    repository.result = _result(
      [_asset()],
      origin: DataOrigin.cache,
      lastUpdatedAt: updatedAt,
      isStale: true,
      remoteFailure: const Failure(FailureCode.networkUnavailable),
    );

    readController().onQueryChanged('apple');
    await debounce.flush();

    final state = readState() as ExplorerReady;
    expect(state.isStale, isTrue);
    expect(state.showsStoredData, isTrue);
    expect(
      explorerSyncStatus(state),
      'Hors connexion — données du 03/06/2024 12:00 UTC',
    );
  });

  test('forceRefresh calls the repository once and keeps visible assets',
      () async {
    repository.result = _result([_asset(name: 'Apple')]);
    readController().onQueryChanged('apple');
    await debounce.flush();

    repository.gate = Completer<void>();
    repository.result = _result([_asset(name: 'Apple Inc.')]);
    final pending = readController().refresh();
    await Future<void>.delayed(Duration.zero);

    final refreshing = readState() as ExplorerReady;
    expect(refreshing.isRefreshing, isTrue);
    expect(refreshing.assets.single.name, 'Apple');
    expect(
      repository.searches.where((call) => call.forceRefresh),
      hasLength(1),
    );

    await readController().refresh();
    expect(
      repository.searches.where((call) => call.forceRefresh),
      hasLength(1),
    );

    repository.gate!.complete();
    await pending;
    final refreshed = readState() as ExplorerReady;
    expect(refreshed.isRefreshing, isFalse);
    expect(refreshed.assets.single.name, 'Apple Inc.');
    expect(repository.searches.last.forceRefresh, isTrue);
  });
}

class _FakeMarketDataRepository implements MarketDataRepository {
  CachedResult<List<Asset>>? result;
  AppException? error;
  Completer<void>? gate;
  final searches = <({String query, bool forceRefresh})>[];

  @override
  Future<CachedResult<List<Asset>>> searchAssets(
    String query, {
    bool forceRefresh = false,
  }) async {
    searches.add((query: query, forceRefresh: forceRefresh));
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

CachedResult<List<Asset>> _result(
  List<Asset> assets, {
  DataOrigin origin = DataOrigin.remote,
  DateTime? lastUpdatedAt,
  bool isStale = false,
  Failure? remoteFailure,
}) {
  return CachedResult(
    data: assets,
    origin: origin,
    lastUpdatedAt: lastUpdatedAt,
    isStale: isStale,
    remoteFailure: remoteFailure,
  );
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
