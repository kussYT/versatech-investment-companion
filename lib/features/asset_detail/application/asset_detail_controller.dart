import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/asset_detail/application/asset_detail_state.dart';
import 'package:versatech_investment_companion/features/asset_detail/application/asset_symbol.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';

final assetDetailControllerProvider = NotifierProvider.autoDispose
    .family<AssetDetailController, AssetDetailState, String>(
  AssetDetailController.new,
);

class AssetDetailController
    extends AutoDisposeFamilyNotifier<AssetDetailState, String> {
  static const historyLookback = Duration(days: 365);

  var _requestId = 0;
  var _inFlight = false;
  var _loaded = false;
  var _disposed = false;

  @override
  AssetDetailState build(String arg) {
    ref.onDispose(() {
      _disposed = true;
      _requestId++;
    });
    final symbol = assetSymbolFromRoute(arg);
    if (symbol == null) {
      return AssetDetailState.invalid();
    }
    return AssetDetailState.loading(symbol);
  }

  void selectWindow(HistoryWindow window) {
    if (state.invalid || state.window == window) {
      return;
    }
    state = state.copyWith(window: window);
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (state.invalid || _inFlight || _disposed) {
      return;
    }
    if (!forceRefresh && _loaded) {
      return;
    }
    final symbol = state.symbol;
    final requestId = ++_requestId;
    _inFlight = true;
    if (forceRefresh) {
      state = state.startRefresh();
    }

    try {
      await Future.wait([
        _loadProfile(symbol, requestId, forceRefresh: forceRefresh),
        _loadQuote(symbol, requestId, forceRefresh: forceRefresh),
        _loadHistory(symbol, requestId, forceRefresh: forceRefresh),
      ]);
    } finally {
      if (requestId == _requestId) {
        _inFlight = false;
        _loaded = true;
      }
    }
  }

  Future<void> refresh() {
    return load(forceRefresh: true);
  }

  Future<void> _loadProfile(
    String symbol,
    int requestId, {
    required bool forceRefresh,
  }) async {
    try {
      final result = await ref.read(marketDataRepositoryProvider).getProfile(
            symbol,
            forceRefresh: forceRefresh,
          );
      if (!_current(requestId)) {
        return;
      }
      state = state.copyWith(profile: state.profile.readyFrom(result));
    } on AppException catch (error) {
      if (!_current(requestId)) {
        return;
      }
      state = state.copyWith(profile: state.profile.failed(error.failure));
    }
  }

  Future<void> _loadQuote(
    String symbol,
    int requestId, {
    required bool forceRefresh,
  }) async {
    try {
      final result = await ref.read(marketDataRepositoryProvider).getQuote(
            symbol,
            forceRefresh: forceRefresh,
          );
      if (!_current(requestId)) {
        return;
      }
      state = state.copyWith(quote: state.quote.readyFrom(result));
    } on AppException catch (error) {
      if (!_current(requestId)) {
        return;
      }
      state = state.copyWith(quote: state.quote.failed(error.failure));
    }
  }

  Future<void> _loadHistory(
    String symbol,
    int requestId, {
    required bool forceRefresh,
  }) async {
    final end = calendarDate(ref.read(clockProvider).now());
    final start = end.subtract(historyLookback);
    try {
      final result =
          await ref.read(marketDataRepositoryProvider).getHistoricalPrices(
                symbol: symbol,
                from: start,
                to: end,
                forceRefresh: forceRefresh,
              );
      if (!_current(requestId)) {
        return;
      }
      state = state.copyWith(
        history: state.history.readyFrom(result),
        historyEnd: end,
      );
    } on AppException catch (error) {
      if (!_current(requestId)) {
        return;
      }
      state = state.copyWith(history: state.history.failed(error.failure));
    }
  }

  bool _current(int requestId) {
    return !_disposed && requestId == _requestId;
  }
}
