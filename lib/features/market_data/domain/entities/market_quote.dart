class MarketQuote {
  const MarketQuote({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.timestamp,
    this.previousClose,
  });

  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final double? previousClose;
  final DateTime timestamp;

  @override
  bool operator ==(Object other) {
    return other is MarketQuote &&
        other.symbol == symbol &&
        other.price == price &&
        other.change == change &&
        other.changePercent == changePercent &&
        other.previousClose == previousClose &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(
        symbol,
        price,
        change,
        changePercent,
        previousClose,
        timestamp,
      );
}
