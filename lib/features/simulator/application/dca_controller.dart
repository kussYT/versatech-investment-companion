import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_engine.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_models.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_rules.dart';

enum DcaRunStatus {
  idle,
  loading,
  ready,
  refreshing,
  error,
}

class DcaState {
  const DcaState({
    required this.status,
    this.result,
    this.errorMessage,
    this.isStale = false,
    this.historyUpdatedAt,
    this.origin,
  });

  const DcaState.idle()
      : status = DcaRunStatus.idle,
        result = null,
        errorMessage = null,
        isStale = false,
        historyUpdatedAt = null,
        origin = null;

  final DcaRunStatus status;
  final DcaSimulationResult? result;
  final String? errorMessage;
  final bool isStale;
  final DateTime? historyUpdatedAt;
  final DataOrigin? origin;

  DcaState copyWith({
    required DcaRunStatus status,
    DcaSimulationResult? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
    bool? isStale,
    DateTime? historyUpdatedAt,
    DataOrigin? origin,
    bool clearHistory = false,
  }) {
    return DcaState(
      status: status,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isStale: isStale ?? this.isStale,
      historyUpdatedAt:
          clearHistory ? null : historyUpdatedAt ?? this.historyUpdatedAt,
      origin: clearHistory ? null : origin ?? this.origin,
    );
  }
}

/// Symbol requested from another screen. Empty until the user asks for it.
final dcaRequestedSymbolProvider = StateProvider<String>((ref) => '');

final dcaControllerProvider =
    NotifierProvider<DcaController, DcaState>(DcaController.new);

class DcaController extends Notifier<DcaState> {
  var _alive = true;
  var _token = 0;
  DcaSimulationInput? _lastInput;

  @override
  DcaState build() {
    _alive = true;
    ref.onDispose(() => _alive = false);
    return const DcaState.idle();
  }

  /// Runs only when the user validates the form. A rebuild does not call this.
  Future<void> simulate(DcaSimulationInput input) {
    if (state.status == DcaRunStatus.loading) {
      return Future.value();
    }
    return _run(input, forceRefresh: false);
  }

  Future<void> refresh() {
    final input = _lastInput;
    if (input == null ||
        state.status == DcaRunStatus.loading ||
        state.status == DcaRunStatus.refreshing) {
      return Future.value();
    }
    return _run(input, forceRefresh: true);
  }

  Future<void> _run(
    DcaSimulationInput input, {
    required bool forceRefresh,
  }) async {
    final today = calendarDay(ref.read(clockProvider).now());
    try {
      requireValidDcaInput(input, today);
    } on InvalidDcaInput catch (error) {
      state = state.copyWith(
        status: DcaRunStatus.error,
        errorMessage: error.userMessage,
        clearResult: state.result == null || !forceRefresh,
      );
      return;
    }
    final token = ++_token;
    final keepResult = forceRefresh && state.result != null;
    state = state.copyWith(
      status: keepResult ? DcaRunStatus.refreshing : DcaRunStatus.loading,
      clearResult: !keepResult,
      clearError: true,
      isStale: keepResult ? null : false,
      clearHistory: !keepResult,
    );
    _lastInput = input;
    try {
      final history =
          await ref.read(marketDataRepositoryProvider).getHistoricalPrices(
                symbol: input.symbol,
                from: input.startDate,
                to: input.endDate,
                forceRefresh: forceRefresh,
              );
      if (!_alive || token != _token) {
        return;
      }
      final DcaSimulationResult result;
      try {
        result = const DcaEngine().simulate(
          input: input,
          history: history.data,
          today: today,
        );
      } on DcaSimulationException catch (error) {
        final message =
            history.isStale && error.failure == DcaFailure.uncoveredPeriod
                ? dcaIncompleteCacheMessage
                : error.userMessage;
        _fail(token, message, keepResult: keepResult);
        return;
      }
      state = state.copyWith(
        status: DcaRunStatus.ready,
        result: result,
        clearError: true,
        isStale: history.isStale,
        historyUpdatedAt: history.lastUpdatedAt,
        origin: history.origin,
      );
    } on InvalidDcaInput catch (error) {
      _fail(token, error.userMessage, keepResult: keepResult);
    } on DcaSimulationException catch (error) {
      _fail(token, error.userMessage, keepResult: keepResult);
    } on NetworkUnavailableException {
      _fail(token, dcaOfflineMessage, keepResult: keepResult);
    } on AppException {
      _fail(token, dcaRemoteErrorMessage, keepResult: keepResult);
    }
  }

  void _fail(int token, String message, {required bool keepResult}) {
    if (!_alive || token != _token) {
      return;
    }
    state = state.copyWith(
      status: DcaRunStatus.error,
      errorMessage: message,
      clearResult: !keepResult,
    );
  }
}
