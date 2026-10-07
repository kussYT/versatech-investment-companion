/// Why a simulation was refused. The message shown to the user is separate.
enum DcaFailure {
  emptyHistory,
  uncoveredPeriod,
  unusablePrices,
  noPurchase,
}

/// A rejected simulation input. [userMessage] is safe to show as-is.
final class InvalidDcaInput implements Exception {
  const InvalidDcaInput(this.userMessage);

  final String userMessage;

  @override
  String toString() => 'InvalidDcaInput';
}

/// A simulation that cannot be computed from the supplied history.
final class DcaSimulationException implements Exception {
  const DcaSimulationException(this.userMessage, this.failure);

  final String userMessage;
  final DcaFailure failure;

  @override
  String toString() => 'DcaSimulationException';
}

/// Parameters of one monthly DCA simulation.
///
/// [startDate] and [endDate] are calendar days. Monthly contributions begin
/// one month after [startDate], so the initial amount is not counted twice.
class DcaSimulationInput {
  const DcaSimulationInput({
    required this.symbol,
    required this.initialAmount,
    required this.monthlyAmount,
    required this.startDate,
    required this.endDate,
  });

  final String symbol;
  final double initialAmount;
  final double monthlyAmount;
  final DateTime startDate;
  final DateTime endDate;
}

/// One executed contribution. A skipped date is absent, never invented.
class DcaPurchase {
  const DcaPurchase({
    required this.scheduledDate,
    required this.executionDate,
    required this.amount,
    required this.price,
    required this.quantity,
  });

  final DateTime scheduledDate;
  final DateTime executionDate;
  final double amount;
  final double price;
  final double quantity;

  bool get movedToNextSession => executionDate != scheduledDate;
}

/// Invested capital and simulated market value on one session.
class SimulationPoint {
  const SimulationPoint({
    required this.date,
    required this.investedAmount,
    required this.simulatedValue,
  });

  final DateTime date;
  final double investedAmount;
  final double simulatedValue;
}

class DcaSimulationResult {
  const DcaSimulationResult({
    required this.symbol,
    required this.totalInvested,
    required this.totalQuantity,
    required this.finalValue,
    required this.gainLoss,
    required this.performancePercent,
    required this.purchases,
    required this.timeline,
    required this.firstMarketDate,
    required this.lastMarketDate,
    required this.purchaseMovedToNextSession,
    required this.historyBeginsAfterStart,
    required this.valuedOnEarlierSession,
  });

  final String symbol;
  final double totalInvested;
  final double totalQuantity;
  final double finalValue;
  final double gainLoss;

  /// Null when [totalInvested] is 0. That case is refused before a result.
  final double? performancePercent;
  final List<DcaPurchase> purchases;
  final List<SimulationPoint> timeline;
  final DateTime firstMarketDate;
  final DateTime lastMarketDate;

  /// At least one contribution used the next quoted session.
  final bool purchaseMovedToNextSession;

  /// The first close in range is after the requested start.
  final bool historyBeginsAfterStart;

  /// The last close is before the requested end, within the accepted gap.
  final bool valuedOnEarlierSession;
}
