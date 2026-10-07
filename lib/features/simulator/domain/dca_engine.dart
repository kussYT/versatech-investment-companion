import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_models.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_rules.dart';

/// Monthly DCA on historical closes.
///
/// Convention:
/// - The initial amount, when strictly positive, is scheduled on the start
///   date. Monthly contributions start one month later, then every month, so
///   the start date is never bought twice.
/// - The scheduled day stays the start date's day of month. When that day does
///   not exist, the purchase is scheduled on the last calendar day of the month
///   (31 January → 28 or 29 February, then 31 March).
/// - A session without a close uses the next strictly positive close, on or
///   before the end date. A close before the scheduled date is never used.
///   Weekends and holidays do not receive an invented price.
/// - Quantity bought is amount / close. The final value is the accumulated
///   quantity times the last strictly positive close in the requested range.
/// - A trailing gap of at most [acceptedTrailingGap] is treated as a market
///   closure. A longer gap refuses the simulation instead of inventing the
///   missing sessions.
class DcaEngine {
  const DcaEngine();

  static const acceptedTrailingGap = Duration(days: 10);

  DcaSimulationResult simulate({
    required DcaSimulationInput input,
    required List<HistoricalPrice> history,
    required DateTime today,
  }) {
    requireValidDcaInput(input, today);
    final symbol = requiredSymbol(input.symbol);
    final start = calendarDate(input.startDate);
    final end = calendarDate(input.endDate);
    final bars = _usableBars(history, symbol, start, end);
    if (bars.isEmpty) {
      throw _emptyHistory(history, symbol, start, end);
    }
    final tail = end.difference(bars.last.date);
    if (tail > acceptedTrailingGap) {
      throw const DcaSimulationException(
        dcaUncoveredMessage,
        DcaFailure.uncoveredPeriod,
      );
    }

    final purchases = _purchases(
      input: input,
      start: start,
      end: end,
      bars: bars,
    );
    if (purchases.isEmpty) {
      throw const DcaSimulationException(
        dcaNoPurchaseMessage,
        DcaFailure.noPurchase,
      );
    }

    final timeline = _timeline(bars, purchases);
    final totalInvested = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.amount,
    );
    final totalQuantity = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.quantity,
    );
    final finalValue = totalQuantity * bars.last.close;
    final gainLoss = finalValue - totalInvested;
    final performance =
        totalInvested == 0 ? null : gainLoss / totalInvested * 100;

    return DcaSimulationResult(
      symbol: symbol,
      totalInvested: totalInvested,
      totalQuantity: totalQuantity,
      finalValue: finalValue,
      gainLoss: gainLoss,
      performancePercent: performance,
      purchases: purchases,
      timeline: timeline,
      firstMarketDate: bars.first.date,
      lastMarketDate: bars.last.date,
      purchaseMovedToNextSession:
          purchases.any((purchase) => purchase.movedToNextSession),
      historyBeginsAfterStart: bars.first.date.isAfter(start),
      valuedOnEarlierSession: bars.last.date.isBefore(end),
    );
  }
}

/// Same day-of-month, [monthOffset] months after [start].
///
/// Day 31 in a shorter month becomes that month's last calendar day.
DateTime dcaScheduledDate(DateTime start, int monthOffset) {
  final anchor = calendarDate(start);
  final monthIndex = anchor.month - 1 + monthOffset;
  final year = anchor.year + monthIndex ~/ 12;
  final month = monthIndex % 12 + 1;
  final lastDay = DateTime.utc(year, month + 1, 0).day;
  final day = anchor.day > lastDay ? lastDay : anchor.day;
  return DateTime.utc(year, month, day);
}

class _Bar {
  const _Bar(this.date, this.close);

  final DateTime date;
  final double close;
}

List<_Bar> _usableBars(
  List<HistoricalPrice> history,
  String symbol,
  DateTime start,
  DateTime end,
) {
  final closes = <DateTime, double>{};
  for (final price in history) {
    if (normalizeSymbol(price.symbol) != symbol) {
      continue;
    }
    final date = calendarDate(price.date);
    if (date.isBefore(start) || date.isAfter(end)) {
      continue;
    }
    final close = price.close;
    if (!close.isFinite || close <= 0) {
      continue;
    }
    closes[date] = close;
  }
  final dates = closes.keys.toList()..sort();
  return [for (final date in dates) _Bar(date, closes[date]!)];
}

DcaSimulationException _emptyHistory(
  List<HistoricalPrice> history,
  String symbol,
  DateTime start,
  DateTime end,
) {
  final inRange = history.where((price) {
    if (normalizeSymbol(price.symbol) != symbol) {
      return false;
    }
    final date = calendarDate(price.date);
    return !date.isBefore(start) && !date.isAfter(end);
  });
  if (inRange.isEmpty) {
    return DcaSimulationException(
      history.isEmpty ? dcaEmptyHistoryMessage : dcaUncoveredMessage,
      history.isEmpty ? DcaFailure.emptyHistory : DcaFailure.uncoveredPeriod,
    );
  }
  return const DcaSimulationException(
    dcaUnusablePricesMessage,
    DcaFailure.unusablePrices,
  );
}

List<DcaPurchase> _purchases({
  required DcaSimulationInput input,
  required DateTime start,
  required DateTime end,
  required List<_Bar> bars,
}) {
  final purchases = <DcaPurchase>[];
  if (input.initialAmount > 0) {
    final initial = _execute(
      scheduled: start,
      amount: input.initialAmount,
      end: end,
      bars: bars,
    );
    if (initial != null) {
      purchases.add(initial);
    }
  }
  if (input.monthlyAmount <= 0) {
    return purchases;
  }
  for (var offset = 1; offset <= 1200; offset++) {
    final scheduled = dcaScheduledDate(start, offset);
    if (scheduled.isAfter(end)) {
      break;
    }
    final purchase = _execute(
      scheduled: scheduled,
      amount: input.monthlyAmount,
      end: end,
      bars: bars,
    );
    if (purchase != null) {
      purchases.add(purchase);
    }
  }
  return purchases;
}

DcaPurchase? _execute({
  required DateTime scheduled,
  required double amount,
  required DateTime end,
  required List<_Bar> bars,
}) {
  for (final bar in bars) {
    if (bar.date.isBefore(scheduled)) {
      continue;
    }
    if (bar.date.isAfter(end)) {
      return null;
    }
    return DcaPurchase(
      scheduledDate: scheduled,
      executionDate: bar.date,
      amount: amount,
      price: bar.close,
      quantity: amount / bar.close,
    );
  }
  return null;
}

List<SimulationPoint> _timeline(List<_Bar> bars, List<DcaPurchase> purchases) {
  final points = <SimulationPoint>[];
  var invested = 0.0;
  var quantity = 0.0;
  var index = 0;
  for (final bar in bars) {
    while (index < purchases.length &&
        !purchases[index].executionDate.isAfter(bar.date)) {
      invested += purchases[index].amount;
      quantity += purchases[index].quantity;
      index++;
    }
    points.add(
      SimulationPoint(
        date: bar.date,
        investedAmount: invested,
        simulatedValue: quantity * bar.close,
      ),
    );
  }
  return points;
}
