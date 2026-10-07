/// One fictitious purchase. Several rows may share the same symbol.
class PortfolioPosition {
  const PortfolioPosition({
    required this.id,
    required this.symbol,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.createdAt,
  });

  final int id;
  final String symbol;
  final double quantity;
  final double purchasePrice;
  final DateTime purchaseDate;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    return other is PortfolioPosition &&
        other.id == id &&
        other.symbol == symbol &&
        other.quantity == quantity &&
        other.purchasePrice == purchasePrice &&
        other.purchaseDate == purchaseDate &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        symbol,
        quantity,
        purchasePrice,
        purchaseDate,
        createdAt,
      );
}
