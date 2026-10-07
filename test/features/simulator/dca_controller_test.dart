import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';
import 'package:versatech_investment_companion/features/simulator/application/dca_controller.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_models.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_rules.dart';

void main() {
  test('does not load history until the user runs a simulation', () {
    final history = _History(_covered());
    final container = _container(history);

    expect(container.read(dcaControllerProvider).status, DcaRunStatus.idle);
    expect(history.calls, isEmpty);
  });

  test('loads history from the market repository for the requested range',
      () async {
    final history = _History(_covered());
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(_input());

    expect(history.calls, hasLength(1));
    expect(history.calls.single.symbol, 'AAPL');
    expect(history.calls.single.forceRefresh, isFalse);
    expect(history.calls.single.from, DateTime.utc(2024, 1, 2));
    expect(history.calls.single.to, DateTime.utc(2024, 3, 2));
    expect(container.read(dcaControllerProvider).status, DcaRunStatus.ready);
    expect(
      container.read(dcaControllerProvider).result?.totalInvested,
      100,
    );
  });

  test('simulates from cached history without another fetch', () async {
    final history = _History(
      _covered(origin: DataOrigin.cache),
    );
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(_input());
    container.read(dcaControllerProvider);

    expect(history.calls, hasLength(1));
    expect(history.calls.single.forceRefresh, isFalse);
    expect(
      container.read(dcaControllerProvider).origin,
      DataOrigin.cache,
    );
    expect(container.read(dcaControllerProvider).isStale, isFalse);
    expect(container.read(dcaControllerProvider).result, isNotNull);
  });

  test('keeps a result when the cached history is stale', () async {
    final history = _History(_covered(stale: true));
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(_input());

    final state = container.read(dcaControllerProvider);
    expect(state.status, DcaRunStatus.ready);
    expect(state.isStale, isTrue);
    expect(state.result?.finalValue, 160);
  });

  test('simulates offline when the cache already covers the period', () async {
    final history = _History(_covered(origin: DataOrigin.cache));
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(_input());

    expect(container.read(dcaControllerProvider).result, isNotNull);
    expect(container.read(dcaControllerProvider).errorMessage, isNull);
  });

  test('reports an incomplete cache without inventing prices', () async {
    final history = _History(
      CachedResult(
        data: [_close(DateTime.utc(2024, 1, 2), 50)],
        origin: DataOrigin.cache,
        lastUpdatedAt: DateTime.utc(2024, 1, 2),
        isStale: true,
      ),
    );
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(_input());

    final state = container.read(dcaControllerProvider);
    expect(state.status, DcaRunStatus.error);
    expect(state.result, isNull);
    expect(state.errorMessage, dcaIncompleteCacheMessage);
  });

  test('reports a remote failure when no cache is available', () async {
    final history = _History(_covered(), error: const UnknownRemoteException());
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(_input());

    final state = container.read(dcaControllerProvider);
    expect(state.result, isNull);
    expect(state.errorMessage, dcaRemoteErrorMessage);
    expect(state.errorMessage, isNot(contains('Exception')));
  });

  test('reports a missing history when the device is offline', () async {
    final history = _History(
      _covered(),
      error: const NetworkUnavailableException(),
    );
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(_input());

    expect(
      container.read(dcaControllerProvider).errorMessage,
      dcaOfflineMessage,
    );
  });

  test('refreshes the same history once when asked', () async {
    final history = _History(_covered());
    final container = _container(history);
    final notifier = container.read(dcaControllerProvider.notifier);

    await notifier.simulate(_input());
    await notifier.refresh();

    expect(history.calls.map((call) => call.forceRefresh), [false, true]);
    expect(container.read(dcaControllerProvider).status, DcaRunStatus.ready);
  });

  test('does not call the repository again when the state is read', () async {
    final history = _History(_covered());
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(_input());
    container.read(dcaControllerProvider);
    container.read(dcaControllerProvider);

    expect(history.calls, hasLength(1));
  });

  test('does not fetch when the input is rejected', () async {
    final history = _History(_covered());
    final container = _container(history);

    await container.read(dcaControllerProvider.notifier).simulate(
          DcaSimulationInput(
            symbol: 'AAPL',
            initialAmount: 0,
            monthlyAmount: 0,
            startDate: DateTime.utc(2024, 1, 2),
            endDate: DateTime.utc(2024, 3, 2),
          ),
        );

    expect(history.calls, isEmpty);
    expect(
      container.read(dcaControllerProvider).errorMessage,
      dcaBothAmountsZeroMessage,
    );
  });
}

ProviderContainer _container(_History history) {
  final container = ProviderContainer(
    overrides: [
      marketDataRepositoryProvider.overrideWithValue(history),
      clockProvider.overrideWithValue(FixedClock(DateTime.utc(2024, 6, 15))),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

DcaSimulationInput _input() {
  return DcaSimulationInput(
    symbol: 'AAPL',
    initialAmount: 100,
    monthlyAmount: 0,
    startDate: DateTime.utc(2024, 1, 2),
    endDate: DateTime.utc(2024, 3, 2),
  );
}

CachedResult<List<HistoricalPrice>> _covered({
  DataOrigin origin = DataOrigin.remote,
  bool stale = false,
}) {
  return CachedResult(
    data: [
      _close(DateTime.utc(2024, 1, 2), 50),
      _close(DateTime.utc(2024, 3, 2), 80),
    ],
    origin: origin,
    lastUpdatedAt: DateTime.utc(2024, 6, 1, 15, 30),
    isStale: stale,
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

class _Call {
  const _Call({
    required this.symbol,
    required this.from,
    required this.to,
    required this.forceRefresh,
  });

  final String symbol;
  final DateTime from;
  final DateTime to;
  final bool forceRefresh;
}

class _History implements MarketDataRepository {
  _History(this.result, {this.error});

  final CachedResult<List<HistoricalPrice>> result;
  final AppException? error;
  final calls = <_Call>[];

  @override
  Future<CachedResult<List<HistoricalPrice>>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
    bool forceRefresh = false,
  }) async {
    calls.add(
      _Call(
        symbol: symbol,
        from: from,
        to: to,
        forceRefresh: forceRefresh,
      ),
    );
    final failure = error;
    if (failure != null) {
      throw failure;
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
