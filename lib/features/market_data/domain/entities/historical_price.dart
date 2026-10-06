class HistoricalPrice {
  const HistoricalPrice({
    required this.symbol,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final String symbol;
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  @override
  bool operator ==(Object other) {
    return other is HistoricalPrice &&
        other.symbol == symbol &&
        other.date == date &&
        other.open == open &&
        other.high == high &&
        other.low == low &&
        other.close == close &&
        other.volume == volume;
  }

  @override
  int get hashCode => Object.hash(
        symbol,
        date,
        open,
        high,
        low,
        close,
        volume,
      );
}
