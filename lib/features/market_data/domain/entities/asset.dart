enum AssetType { stock, etf }

class Asset {
  const Asset({
    required this.symbol,
    required this.name,
    required this.type,
    required this.exchange,
    required this.currency,
  });

  final String symbol;
  final String name;
  final AssetType type;
  final String exchange;
  final String currency;

  @override
  bool operator ==(Object other) {
    return other is Asset &&
        other.symbol == symbol &&
        other.name == name &&
        other.type == type &&
        other.exchange == exchange &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(symbol, name, type, exchange, currency);
}
