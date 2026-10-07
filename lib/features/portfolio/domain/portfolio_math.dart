import 'package:versatech_investment_companion/features/portfolio/domain/entities/portfolio_position.dart';

/// A number that cannot be used in a portfolio calculation.
final class InvalidPortfolioCalculation implements Exception {
  const InvalidPortfolioCalculation();

  @override
  String toString() => 'InvalidPortfolioCalculation';
}

/// Several purchases of one symbol. Individual positions stay on [positions].
class AggregatedHolding {
  const AggregatedHolding({
    required this.symbol,
    required this.positions,
    required this.totalQuantity,
    required this.investedAmount,
    required this.averagePurchasePrice,
  });

  final String symbol;
  final List<PortfolioPosition> positions;
  final double totalQuantity;
  final double investedAmount;

  /// Weighted average: invested amount / total quantity. Null when quantity is 0.
  final double? averagePurchasePrice;
}

class AllocationSlice {
  const AllocationSlice({
    required this.symbol,
    required this.currentValue,
    required this.weightPercent,
  });

  final String symbol;
  final double currentValue;
  final double weightPercent;
}

sealed class SymbolPrice {
  const SymbolPrice();
}

final class AvailableSymbolPrice extends SymbolPrice {
  const AvailableSymbolPrice({
    required this.price,
    required this.isStale,
    this.asOf,
  });

  final double price;
  final bool isStale;
  final DateTime? asOf;
}

final class MissingSymbolPrice extends SymbolPrice {
  const MissingSymbolPrice();
}

class HoldingSnapshot {
  const HoldingSnapshot({
    required this.holding,
    required this.currentPrice,
    required this.currentValue,
    required this.gain,
    required this.performancePercent,
    required this.isStale,
    required this.pricedAt,
  });

  final AggregatedHolding holding;
  final double? currentPrice;
  final double? currentValue;
  final double? gain;
  final double? performancePercent;
  final bool isStale;
  final DateTime? pricedAt;

  bool get hasPrice => currentValue != null;
}

class PortfolioSummary {
  const PortfolioSummary({
    required this.holdings,
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.globalGain,
    required this.globalPerformancePercent,
    required this.pricesComplete,
    required this.allocation,
    required this.unpricedSymbols,
  });

  final List<HoldingSnapshot> holdings;
  final double totalInvested;

  /// Sum of known current values. Null when none of the holdings has a price.
  final double? totalCurrentValue;

  /// Null when a price is missing or the portfolio is empty.
  /// A partial sum is never presented as the portfolio gain.
  final double? globalGain;

  /// Null when [globalGain] is null or the invested amount is zero.
  final double? globalPerformancePercent;

  final bool pricesComplete;
  final List<AllocationSlice> allocation;
  final List<String> unpricedSymbols;

  bool get isEmpty => holdings.isEmpty;

  static const empty = PortfolioSummary(
    holdings: [],
    totalInvested: 0,
    totalCurrentValue: null,
    globalGain: null,
    globalPerformancePercent: null,
    pricesComplete: true,
    allocation: [],
    unpricedSymbols: [],
  );
}

/// Pure portfolio arithmetic. No Flutter, Drift, Riverpod or network.
abstract final class PortfolioMath {
  /// quantity × purchasePrice
  static double investedAmount({
    required double quantity,
    required double purchasePrice,
  }) {
    _requirePositive(quantity);
    _requirePositive(purchasePrice);
    return quantity * purchasePrice;
  }

  /// quantity × currentPrice
  static double currentValue({
    required double quantity,
    required double currentPrice,
  }) {
    _requirePositive(quantity);
    _requireFinite(currentPrice);
    if (currentPrice < 0) {
      throw const InvalidPortfolioCalculation();
    }
    return quantity * currentPrice;
  }

  /// currentValue − investedAmount
  static double gainLoss({
    required double currentValue,
    required double investedAmount,
  }) {
    _requireFinite(currentValue);
    _requireFinite(investedAmount);
    return currentValue - investedAmount;
  }

  /// (currentValue − investedAmount) / investedAmount × 100.
  /// Returns null when [investedAmount] is zero so the caller does not divide.
  static double? performancePercent({
    required double currentValue,
    required double investedAmount,
  }) {
    _requireFinite(currentValue);
    _requireFinite(investedAmount);
    if (investedAmount == 0) {
      return null;
    }
    if (investedAmount < 0) {
      throw const InvalidPortfolioCalculation();
    }
    return (currentValue - investedAmount) / investedAmount * 100;
  }

  static double totalInvested(Iterable<double> amounts) {
    var total = 0.0;
    for (final amount in amounts) {
      _requireFinite(amount);
      if (amount < 0) {
        throw const InvalidPortfolioCalculation();
      }
      total += amount;
    }
    return total;
  }

  /// Sum of known values. Null when [values] contains no number.
  /// Null entries are missing prices and are skipped, not replaced by zero.
  static double? totalCurrentValue(Iterable<double?> values) {
    var total = 0.0;
    var known = 0;
    for (final value in values) {
      if (value == null) {
        continue;
      }
      _requireFinite(value);
      if (value < 0) {
        throw const InvalidPortfolioCalculation();
      }
      total += value;
      known += 1;
    }
    if (known == 0) {
      return null;
    }
    return total;
  }

  /// currentPortfolioValue − investedPortfolioAmount when every price is known.
  static double? globalGain({
    required double? currentPortfolioValue,
    required double investedPortfolioAmount,
    required bool pricesComplete,
  }) {
    if (!pricesComplete || currentPortfolioValue == null) {
      return null;
    }
    return gainLoss(
      currentValue: currentPortfolioValue,
      investedAmount: investedPortfolioAmount,
    );
  }

  /// globalGain / totalInvested × 100. Null when the gain is unknown or the
  /// invested amount is zero.
  static double? globalPerformancePercent({
    required double? globalGain,
    required double totalInvested,
  }) {
    if (globalGain == null) {
      return null;
    }
    return performancePercent(
      currentValue: totalInvested + globalGain,
      investedAmount: totalInvested,
    );
  }

  /// investedAmount / totalQuantity. Null when [totalQuantity] is zero.
  /// This is not the arithmetic mean of the purchase prices.
  static double? weightedAveragePrice({
    required double investedAmount,
    required double totalQuantity,
  }) {
    _requireFinite(investedAmount);
    _requireFinite(totalQuantity);
    if (totalQuantity == 0) {
      return null;
    }
    if (totalQuantity < 0 || investedAmount < 0) {
      throw const InvalidPortfolioCalculation();
    }
    return investedAmount / totalQuantity;
  }

  static List<AggregatedHolding> aggregateAll(
    List<PortfolioPosition> positions,
  ) {
    final groups = <String, List<PortfolioPosition>>{};
    for (final position in positions) {
      groups.putIfAbsent(position.symbol, () => []).add(position);
    }
    final symbols = groups.keys.toList()..sort();
    return [
      for (final symbol in symbols) _aggregate(symbol, groups[symbol]!),
    ];
  }

  /// Builds holdings, totals and the ring weights.
  ///
  /// Allocation uses current value, never quantity or cost.
  /// A holding without a current price is listed in [PortfolioSummary.unpricedSymbols]
  /// and left out of the denominator. It is not given a zero value, so it
  /// cannot create a slice or shrink the priced holdings.
  /// Global gain and performance stay null while any price is missing.
  static PortfolioSummary summarize({
    required List<PortfolioPosition> positions,
    required Map<String, SymbolPrice> prices,
  }) {
    if (positions.isEmpty) {
      return PortfolioSummary.empty;
    }
    final aggregated = aggregateAll(positions);
    final holdings = <HoldingSnapshot>[];
    for (final holding in aggregated) {
      holdings.add(_valueHolding(holding, prices[holding.symbol]));
    }
    final invested = totalInvested(
      holdings.map((holding) => holding.holding.investedAmount),
    );
    final currentValues = [
      for (final holding in holdings) holding.currentValue,
    ];
    final current = totalCurrentValue(currentValues);
    final complete = holdings.every((holding) => holding.hasPrice);
    final gain = globalGain(
      currentPortfolioValue: current,
      investedPortfolioAmount: invested,
      pricesComplete: complete,
    );
    return PortfolioSummary(
      holdings: holdings,
      totalInvested: invested,
      totalCurrentValue: current,
      globalGain: gain,
      globalPerformancePercent: globalPerformancePercent(
        globalGain: gain,
        totalInvested: invested,
      ),
      pricesComplete: complete,
      allocation: _allocation(holdings),
      unpricedSymbols: [
        for (final holding in holdings)
          if (!holding.hasPrice) holding.holding.symbol,
      ],
    );
  }

  static AggregatedHolding _aggregate(
    String symbol,
    List<PortfolioPosition> positions,
  ) {
    var quantity = 0.0;
    var invested = 0.0;
    for (final position in positions) {
      quantity += position.quantity;
      invested += investedAmount(
        quantity: position.quantity,
        purchasePrice: position.purchasePrice,
      );
    }
    return AggregatedHolding(
      symbol: symbol,
      positions: List.unmodifiable(positions),
      totalQuantity: quantity,
      investedAmount: invested,
      averagePurchasePrice: weightedAveragePrice(
        investedAmount: invested,
        totalQuantity: quantity,
      ),
    );
  }

  static HoldingSnapshot _valueHolding(
    AggregatedHolding holding,
    SymbolPrice? price,
  ) {
    if (price is! AvailableSymbolPrice ||
        !price.price.isFinite ||
        price.price < 0) {
      return HoldingSnapshot(
        holding: holding,
        currentPrice: null,
        currentValue: null,
        gain: null,
        performancePercent: null,
        isStale: false,
        pricedAt: null,
      );
    }
    final current = currentValue(
      quantity: holding.totalQuantity,
      currentPrice: price.price,
    );
    final gain = gainLoss(
      currentValue: current,
      investedAmount: holding.investedAmount,
    );
    return HoldingSnapshot(
      holding: holding,
      currentPrice: price.price,
      currentValue: current,
      gain: gain,
      performancePercent: performancePercent(
        currentValue: current,
        investedAmount: holding.investedAmount,
      ),
      isStale: price.isStale,
      pricedAt: price.asOf,
    );
  }

  static List<AllocationSlice> _allocation(List<HoldingSnapshot> holdings) {
    final valued = [
      for (final holding in holdings)
        if (holding.currentValue != null && holding.currentValue! > 0)
          (symbol: holding.holding.symbol, value: holding.currentValue!),
    ];
    final denominator = totalCurrentValue(
          valued.map((row) => row.value),
        ) ??
        0;
    if (denominator == 0) {
      return const [];
    }
    return [
      for (final row in valued)
        AllocationSlice(
          symbol: row.symbol,
          currentValue: row.value,
          weightPercent: row.value / denominator * 100,
        ),
    ];
  }

  static void _requirePositive(double value) {
    _requireFinite(value);
    if (value <= 0) {
      throw const InvalidPortfolioCalculation();
    }
  }

  static void _requireFinite(double value) {
    if (value.isNaN || value.isInfinite) {
      throw const InvalidPortfolioCalculation();
    }
  }
}
