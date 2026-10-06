/// Local choice to follow a symbol. Market fields stay in the cache.
class Favorite {
  const Favorite({
    required this.symbol,
    required this.createdAt,
  });

  final String symbol;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    return other is Favorite &&
        other.symbol == symbol &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(symbol, createdAt);
}
