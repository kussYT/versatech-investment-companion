import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/asset_detail/application/asset_detail_controller.dart';
import 'package:versatech_investment_companion/features/asset_detail/application/asset_detail_state.dart';
import 'package:versatech_investment_companion/features/asset_detail/application/asset_symbol.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';

import 'support/fake_market_data_repository.dart';

void main() {
  const fixedNow = '2024-06-15T10:00:00.000Z';

  test('decodes and normalizes a route symbol', () {
    expect(assetSymbolFromRoute('%61apl'), 'AAPL');
    expect(assetSymbolFromRoute(' brk.b '), 'BRK.B');
    expect(assetSymbolFromRoute(''), isNull);
    expect(assetSymbolFromRoute('%'), isNull);
  });

  test('loads profile, quote and one year of history in parallel', () async {
    final clock = FixedClock(DateTime.parse(fixedNow));
    final repository = _readyRepository();
    final harness = _listen(' aapl ', repository, clock);

    expect(harness.state.symbol, 'AAPL');
    expect(harness.state.profile.phase, SectionPhase.loading);
    expect(harness.state.quote.phase, SectionPhase.loading);
    expect(harness.state.history.phase, SectionPhase.loading);

    await harness.notifier.load();

    expect(harness.state.profile.data?.companyName, 'Apple Inc.');
    expect(harness.state.quote.data?.price, 189.25);
    expect(harness.state.history.data, hasLength(2));
    expect(repository.profileCalls.single.symbol, 'AAPL');
    expect(repository.quoteCalls.single.symbol, 'AAPL');
    expect(repository.quoteCalls.single.forceRefresh, isFalse);

    final end = calendarDate(clock.now());
    expect(repository.historyCalls.single.from,
        end.subtract(const Duration(days: 365)));
    expect(repository.historyCalls.single.to, end);
    expect(repository.historyCalls.single.forceRefresh, isFalse);

    harness.dispose();
  });

  test('keeps the other sections when the profile fails', () async {
    final repository = _readyRepository()
      ..profileError = const NetworkUnavailableException();
    final harness =
        _listen('AAPL', repository, FixedClock(DateTime.parse(fixedNow)));

    await harness.notifier.load();

    expect(harness.state.profile.phase, SectionPhase.failure);
    expect(harness.state.profile.data, isNull);
    expect(harness.state.quote.data?.price, 189.25);
    expect(harness.state.history.data, isNotEmpty);

    harness.dispose();
  });

  test('keeps the other sections when the history fails', () async {
    final repository = _readyRepository()
      ..historyError = const MarketDataNotFoundException();
    final harness =
        _listen('AAPL', repository, FixedClock(DateTime.parse(fixedNow)));

    await harness.notifier.load();

    expect(harness.state.history.phase, SectionPhase.failure);
    expect(harness.state.history.data, isNull);
    expect(harness.state.profile.data?.description, isNotEmpty);
    expect(harness.state.quote.data, isNotNull);

    harness.dispose();
  });

  test('keeps a cached quote and exposes its freshness', () async {
    final updatedAt = DateTime.utc(2024, 6, 3, 12);
    final repository = _readyRepository()
      ..quoteResult = detailResult(
        detailQuote(),
        origin: DataOrigin.cache,
        lastUpdatedAt: updatedAt,
        isStale: false,
      );
    final harness =
        _listen('AAPL', repository, FixedClock(DateTime.parse(fixedNow)));

    await harness.notifier.load();

    expect(harness.state.quote.origin, DataOrigin.cache);
    expect(harness.state.quote.lastUpdatedAt, updatedAt);
    expect(harness.state.quote.isStale, isFalse);

    harness.dispose();
  });

  test('keeps a stale history instead of hiding it', () async {
    final updatedAt = DateTime.utc(2024, 1, 2, 8, 30);
    final repository = _readyRepository()
      ..historyResult = detailResult(
        [
          detailBar(date: DateTime.utc(2024, 6, 10), close: 180),
        ],
        origin: DataOrigin.cache,
        lastUpdatedAt: updatedAt,
        isStale: true,
        remoteFailure: const NetworkUnavailableException().failure,
      );
    final harness =
        _listen('AAPL', repository, FixedClock(DateTime.parse(fixedNow)));

    await harness.notifier.load();

    expect(harness.state.history.isStale, isTrue);
    expect(harness.state.history.lastUpdatedAt, updatedAt);
    expect(harness.state.history.data, isNotEmpty);
    expect(harness.state.visibleHistory, isNotEmpty);

    harness.dispose();
  });

  test('forceRefresh reloads every section without a second history range',
      () async {
    final repository = _readyRepository();
    final harness =
        _listen('AAPL', repository, FixedClock(DateTime.parse(fixedNow)));
    await harness.notifier.load();

    repository.quoteGate = Completer<void>();
    final refresh = harness.notifier.refresh();
    await Future<void>.delayed(Duration.zero);

    expect(harness.state.quote.data?.price, 189.25);
    expect(harness.state.quote.isRefreshing, isTrue);
    expect(repository.quoteCalls.last.forceRefresh, isTrue);
    expect(repository.profileCalls.last.forceRefresh, isTrue);
    expect(repository.historyCalls.last.forceRefresh, isTrue);
    expect(repository.historyCalls, hasLength(2));
    expect(
      repository.historyCalls.last.from,
      repository.historyCalls.first.from,
    );

    repository.quoteGate!.complete();
    repository.quoteGate = null;
    await refresh;
    expect(harness.state.quote.isRefreshing, isFalse);

    harness.dispose();
  });

  test('changing the period filters the loaded history locally', () async {
    final repository = _readyRepository();
    final harness =
        _listen('AAPL', repository, FixedClock(DateTime.parse(fixedNow)));
    await harness.notifier.load();

    expect(harness.state.visibleHistory, hasLength(2));
    harness.notifier.selectWindow(HistoryWindow.month);
    expect(harness.state.visibleHistory, hasLength(1));
    expect(harness.state.visibleHistory.single.close, 190);
    expect(repository.historyCalls, hasLength(1));

    await harness.notifier.load();
    expect(repository.historyCalls, hasLength(1));

    harness.dispose();
  });

  test('does not call the repository for an invalid symbol', () async {
    final repository = _readyRepository();
    final harness =
        _listen('   ', repository, FixedClock(DateTime.parse(fixedNow)));

    expect(harness.state.invalid, isTrue);
    await harness.notifier.load();
    expect(repository.profileCalls, isEmpty);
    expect(repository.quoteCalls, isEmpty);
    expect(repository.historyCalls, isEmpty);

    harness.dispose();
  });
}

FakeMarketDataRepository _readyRepository() {
  return FakeMarketDataRepository(
    profileResult: detailResult(detailProfile()),
    quoteResult: detailResult(detailQuote()),
    historyResult: detailResult([
      detailBar(date: DateTime.utc(2024, 3, 1), close: 150),
      detailBar(date: DateTime.utc(2024, 6, 10), close: 190),
    ]),
  );
}

class _Harness {
  _Harness(this.container, this.subscription, this.rawSymbol);

  final ProviderContainer container;
  final ProviderSubscription<AssetDetailState> subscription;
  final String rawSymbol;

  AssetDetailState get state => subscription.read();

  AssetDetailController get notifier {
    return container.read(assetDetailControllerProvider(rawSymbol).notifier);
  }

  void dispose() {
    subscription.close();
    container.dispose();
  }
}

_Harness _listen(
  String rawSymbol,
  FakeMarketDataRepository repository,
  Clock clock,
) {
  final container = ProviderContainer(
    overrides: [
      marketDataRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(clock),
    ],
  );
  final subscription = container.listen(
    assetDetailControllerProvider(rawSymbol),
    (_, __) {},
    fireImmediately: true,
  );
  return _Harness(container, subscription, rawSymbol);
}
