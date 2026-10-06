import 'package:versatech_investment_companion/core/errors/failure.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

enum HistoryWindow {
  month,
  quarter,
  year;

  String get label => switch (this) {
        HistoryWindow.month => '1 mois',
        HistoryWindow.quarter => '3 mois',
        HistoryWindow.year => '1 an',
      };

  Duration get lookback => switch (this) {
        HistoryWindow.month => const Duration(days: 31),
        HistoryWindow.quarter => const Duration(days: 92),
        HistoryWindow.year => const Duration(days: 365),
      };
}

enum SectionPhase { loading, ready, failure }

class AssetSection<T> {
  const AssetSection({
    required this.phase,
    this.data,
    this.origin,
    this.lastUpdatedAt,
    this.isStale = false,
    this.remoteFailure,
    this.failure,
    this.isRefreshing = false,
  });

  const AssetSection.loading()
      : phase = SectionPhase.loading,
        data = null,
        origin = null,
        lastUpdatedAt = null,
        isStale = false,
        remoteFailure = null,
        failure = null,
        isRefreshing = false;

  final SectionPhase phase;
  final T? data;
  final DataOrigin? origin;
  final DateTime? lastUpdatedAt;
  final bool isStale;
  final Failure? remoteFailure;
  final Failure? failure;
  final bool isRefreshing;

  bool get hasData => data != null;

  AssetSection<T> startRefresh() {
    if (data == null) {
      return const AssetSection.loading();
    }
    return AssetSection(
      phase: SectionPhase.ready,
      data: data,
      origin: origin,
      lastUpdatedAt: lastUpdatedAt,
      isStale: isStale,
      remoteFailure: remoteFailure,
      isRefreshing: true,
    );
  }

  AssetSection<T> readyFrom(CachedResult<T> result) {
    return AssetSection(
      phase: SectionPhase.ready,
      data: result.data,
      origin: result.origin,
      lastUpdatedAt: result.lastUpdatedAt,
      isStale: result.isStale,
      remoteFailure: result.remoteFailure,
    );
  }

  AssetSection<T> failed(Failure failure) {
    if (data == null) {
      return AssetSection(
        phase: SectionPhase.failure,
        failure: failure,
      );
    }
    return AssetSection(
      phase: SectionPhase.ready,
      data: data,
      origin: origin,
      lastUpdatedAt: lastUpdatedAt,
      isStale: true,
      remoteFailure: remoteFailure,
      failure: failure,
    );
  }
}

class AssetDetailState {
  const AssetDetailState({
    required this.symbol,
    required this.profile,
    required this.quote,
    required this.history,
    required this.window,
    this.historyEnd,
    this.invalid = false,
  });

  factory AssetDetailState.loading(String symbol) {
    return AssetDetailState(
      symbol: symbol,
      profile: const AssetSection.loading(),
      quote: const AssetSection.loading(),
      history: const AssetSection.loading(),
      window: HistoryWindow.year,
    );
  }

  factory AssetDetailState.invalid() {
    return const AssetDetailState(
      symbol: '',
      profile: AssetSection.loading(),
      quote: AssetSection.loading(),
      history: AssetSection.loading(),
      window: HistoryWindow.year,
      invalid: true,
    );
  }

  final String symbol;
  final AssetSection<AssetProfile> profile;
  final AssetSection<MarketQuote> quote;
  final AssetSection<List<HistoricalPrice>> history;
  final HistoryWindow window;
  final DateTime? historyEnd;
  final bool invalid;

  bool get isBusy {
    bool busy<T>(AssetSection<T> section) {
      return section.isRefreshing || section.phase == SectionPhase.loading;
    }

    return busy(profile) || busy(quote) || busy(history);
  }

  List<HistoricalPrice> get visibleHistory {
    final bars = history.data;
    final end = historyEnd;
    if (bars == null || end == null) {
      return const [];
    }
    return closesInWindow(prices: bars, end: end, window: window);
  }

  AssetDetailState startRefresh() {
    return copyWith(
      profile: profile.startRefresh(),
      quote: quote.startRefresh(),
      history: history.startRefresh(),
    );
  }

  AssetDetailState copyWith({
    AssetSection<AssetProfile>? profile,
    AssetSection<MarketQuote>? quote,
    AssetSection<List<HistoricalPrice>>? history,
    HistoryWindow? window,
    DateTime? historyEnd,
    bool clearHistoryEnd = false,
  }) {
    return AssetDetailState(
      symbol: symbol,
      profile: profile ?? this.profile,
      quote: quote ?? this.quote,
      history: history ?? this.history,
      window: window ?? this.window,
      historyEnd: clearHistoryEnd ? null : historyEnd ?? this.historyEnd,
      invalid: invalid,
    );
  }
}

List<HistoricalPrice> closesInWindow({
  required List<HistoricalPrice> prices,
  required DateTime end,
  required HistoryWindow window,
}) {
  final lastDay = calendarDate(end);
  final firstDay = lastDay.subtract(window.lookback);
  return [
    for (final price in prices)
      if (!calendarDate(price.date).isBefore(firstDay) &&
          !calendarDate(price.date).isAfter(lastDay))
        price,
  ];
}
