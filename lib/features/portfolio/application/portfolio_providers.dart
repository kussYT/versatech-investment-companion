import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/database/app_database_provider.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';
import 'package:versatech_investment_companion/features/portfolio/data/drift_portfolio_repository.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/entities/portfolio_position.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_math.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/repositories/portfolio_repository.dart';

enum QuoteLookup { pending, available, unavailable }

enum PortfolioLoadStatus { loading, ready, error }

class SymbolValuation {
  const SymbolValuation.pending()
      : lookup = QuoteLookup.pending,
        price = null,
        isStale = false,
        asOf = null;

  const SymbolValuation.unavailable()
      : lookup = QuoteLookup.unavailable,
        price = null,
        isStale = false,
        asOf = null;

  const SymbolValuation.available({
    required this.price,
    required this.isStale,
    this.asOf,
  }) : lookup = QuoteLookup.available;

  final QuoteLookup lookup;
  final double? price;
  final bool isStale;
  final DateTime? asOf;
}

class PortfolioState {
  const PortfolioState({
    required this.status,
    required this.positions,
    required this.quotes,
    required this.refreshing,
  });

  const PortfolioState.loading()
      : status = PortfolioLoadStatus.loading,
        positions = const [],
        quotes = const {},
        refreshing = false;

  final PortfolioLoadStatus status;
  final List<PortfolioPosition> positions;
  final Map<String, SymbolValuation> quotes;
  final bool refreshing;

  bool get valuationsPending {
    if (positions.isEmpty) {
      return false;
    }
    final symbols = {for (final position in positions) position.symbol};
    for (final symbol in symbols) {
      final quote = quotes[symbol];
      if (quote == null || quote.lookup == QuoteLookup.pending) {
        return true;
      }
    }
    return false;
  }

  PortfolioSummary? get summary {
    if (status != PortfolioLoadStatus.ready || valuationsPending) {
      return null;
    }
    return PortfolioMath.summarize(
      positions: positions,
      prices: {
        for (final entry in quotes.entries) entry.key: _price(entry.value),
      },
    );
  }

  PortfolioState copyWith({
    PortfolioLoadStatus? status,
    List<PortfolioPosition>? positions,
    Map<String, SymbolValuation>? quotes,
    bool? refreshing,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      positions: positions ?? this.positions,
      quotes: quotes ?? this.quotes,
      refreshing: refreshing ?? this.refreshing,
    );
  }
}

SymbolPrice _price(SymbolValuation valuation) {
  if (valuation.lookup == QuoteLookup.available && valuation.price != null) {
    return AvailableSymbolPrice(
      price: valuation.price!,
      isStale: valuation.isStale,
      asOf: valuation.asOf,
    );
  }
  return const MissingSymbolPrice();
}

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return DriftPortfolioRepository(
    ref.watch(portfolioPositionDaoProvider),
    clock: ref.watch(clockProvider),
  );
});

final portfolioPositionsProvider = StreamProvider<List<PortfolioPosition>>((
  ref,
) {
  return ref.watch(portfolioRepositoryProvider).watchPositions();
});

final portfolioControllerProvider =
    NotifierProvider<PortfolioController, PortfolioState>(
  PortfolioController.new,
);

class PortfolioController extends Notifier<PortfolioState> {
  final Map<String, int> _tokens = {};
  var _activeLoads = 0;
  var _alive = true;

  @override
  PortfolioState build() {
    _tokens.clear();
    _activeLoads = 0;
    _alive = true;
    ref.onDispose(() => _alive = false);
    ref.listen(portfolioPositionsProvider, (previous, next) {
      next.when(
        data: _onPositions,
        error: (error, stackTrace) {
          state = state.copyWith(status: PortfolioLoadStatus.error);
        },
        loading: () {},
      );
    }, fireImmediately: true);
    return const PortfolioState.loading();
  }

  Future<void> refresh() async {
    final symbols = {
      for (final position in state.positions) position.symbol,
    }.toList();
    if (symbols.isEmpty) {
      return;
    }
    state = state.copyWith(refreshing: true);
    await _load(symbols, forceRefresh: true);
  }

  void _onPositions(List<PortfolioPosition> positions) {
    final symbols = {for (final position in positions) position.symbol};
    final next = <String, SymbolValuation>{};
    for (final symbol in symbols) {
      next[symbol] = state.quotes[symbol] ?? const SymbolValuation.pending();
    }
    state = state.copyWith(
      status: PortfolioLoadStatus.ready,
      positions: positions,
      quotes: next,
    );
    final pending = [
      for (final entry in next.entries)
        if (entry.value.lookup == QuoteLookup.pending) entry.key,
    ];
    if (pending.isEmpty) {
      return;
    }
    unawaited(_load(pending, forceRefresh: false));
  }

  Future<void> _load(
    List<String> symbols, {
    required bool forceRefresh,
  }) async {
    if (symbols.isEmpty) {
      return;
    }
    final batch = <String, int>{};
    for (final symbol in symbols) {
      final token = (_tokens[symbol] ?? 0) + 1;
      _tokens[symbol] = token;
      batch[symbol] = token;
    }
    _activeLoads += 1;
    final market = ref.read(marketDataRepositoryProvider);
    try {
      final results = await Future.wait(
        batch.keys.map(
          (symbol) => _one(market, symbol, forceRefresh: forceRefresh),
        ),
      );
      if (!_alive) {
        return;
      }
      final quotes = Map<String, SymbolValuation>.of(state.quotes);
      for (final entry in results) {
        if (_tokens[entry.key] != batch[entry.key]) {
          continue;
        }
        if (!quotes.containsKey(entry.key)) {
          continue;
        }
        quotes[entry.key] = entry.value;
      }
      _activeLoads -= 1;
      state = state.copyWith(
        quotes: quotes,
        refreshing: _activeLoads > 0 && state.refreshing,
      );
    } catch (_) {
      _activeLoads -= 1;
      if (!_alive) {
        return;
      }
      state = state.copyWith(refreshing: _activeLoads > 0 && state.refreshing);
    }
  }

  Future<MapEntry<String, SymbolValuation>> _one(
    MarketDataRepository market,
    String symbol, {
    required bool forceRefresh,
  }) async {
    try {
      final result = await market.getQuote(
        symbol,
        forceRefresh: forceRefresh,
      );
      return MapEntry(symbol, _available(result));
    } catch (_) {
      return MapEntry(symbol, const SymbolValuation.unavailable());
    }
  }

  SymbolValuation _available(CachedResult<MarketQuote> result) {
    final price = result.data.price;
    if (!price.isFinite || price < 0) {
      return const SymbolValuation.unavailable();
    }
    return SymbolValuation.available(
      price: price,
      isStale: result.isStale,
      asOf: result.lastUpdatedAt ?? result.data.timestamp,
    );
  }
}
