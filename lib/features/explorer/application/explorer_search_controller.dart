import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/explorer/application/explorer_search_state.dart';
import 'package:versatech_investment_companion/features/explorer/application/search_debounce.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';

final searchDebounceProvider = Provider<SearchDebounce>((ref) {
  final debounce = TimerSearchDebounce();
  ref.onDispose(debounce.cancel);
  return debounce;
});

final explorerSearchControllerProvider =
    NotifierProvider<ExplorerSearchController, ExplorerSearchState>(
  ExplorerSearchController.new,
);

class ExplorerSearchController extends Notifier<ExplorerSearchState> {
  static const debounceDelay = Duration(milliseconds: 400);

  var _requestId = 0;
  var _refreshInFlight = false;
  var _disposed = false;

  @override
  ExplorerSearchState build() {
    ref.onDispose(() {
      _disposed = true;
      _requestId++;
    });
    return const ExplorerInitial();
  }

  void onQueryChanged(String raw) {
    final query = raw.trim();
    final debounce = ref.read(searchDebounceProvider);
    if (query.isEmpty) {
      debounce.cancel();
      _requestId++;
      _refreshInFlight = false;
      state = const ExplorerInitial();
      return;
    }

    final requestId = ++_requestId;
    _refreshInFlight = false;
    state = ExplorerLoading(query);
    debounce.schedule(debounceDelay, () {
      return _search(query, requestId, forceRefresh: false);
    });
  }

  /// Manual refresh. Ignored while a search or another refresh is running.
  Future<void> refresh() {
    if (_refreshInFlight || state is ExplorerLoading) {
      return Future<void>.value();
    }
    final current = state;
    final query = switch (current) {
      ExplorerReady(:final query) => query,
      ExplorerFailureState(:final query) => query,
      _ => null,
    };
    if (query == null || query.isEmpty) {
      return Future<void>.value();
    }
    return _search(query, _requestId, forceRefresh: true);
  }

  Future<void> _search(
    String query,
    int requestId, {
    required bool forceRefresh,
  }) async {
    if (requestId != _requestId || _disposed) {
      return;
    }

    final previous = state;
    if (forceRefresh) {
      _refreshInFlight = true;
      if (previous is ExplorerReady) {
        state = previous.copyWith(
          isRefreshing: true,
          clearRefreshFailure: true,
        );
      } else {
        state = ExplorerLoading(query);
      }
    }

    try {
      final result = await ref.read(marketDataRepositoryProvider).searchAssets(
            query,
            forceRefresh: forceRefresh,
          );
      if (requestId != _requestId || _disposed) {
        return;
      }
      state = ExplorerReady(
        query: query,
        assets: result.data,
        origin: result.origin,
        lastUpdatedAt: result.lastUpdatedAt,
        isStale: result.isStale,
        remoteFailure: result.remoteFailure,
      );
    } on AppException catch (error) {
      if (requestId != _requestId || _disposed) {
        return;
      }
      if (forceRefresh && previous is ExplorerReady) {
        state = previous.copyWith(
          isRefreshing: false,
          refreshFailure: error.failure,
        );
        return;
      }
      state = ExplorerFailureState(query: query, failure: error.failure);
    } finally {
      if (forceRefresh && requestId == _requestId) {
        _refreshInFlight = false;
      }
    }
  }
}
