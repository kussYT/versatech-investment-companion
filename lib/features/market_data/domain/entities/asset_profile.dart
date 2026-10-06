class AssetProfile {
  const AssetProfile({
    required this.symbol,
    required this.companyName,
    required this.description,
    required this.currency,
    required this.exchange,
    this.sector,
    this.industry,
    this.website,
    this.imageUrl,
  });

  final String symbol;
  final String companyName;
  final String description;
  final String? sector;
  final String? industry;
  final String? website;
  final String? imageUrl;
  final String currency;
  final String exchange;

  @override
  bool operator ==(Object other) {
    return other is AssetProfile &&
        other.symbol == symbol &&
        other.companyName == companyName &&
        other.description == description &&
        other.sector == sector &&
        other.industry == industry &&
        other.website == website &&
        other.imageUrl == imageUrl &&
        other.currency == currency &&
        other.exchange == exchange;
  }

  @override
  int get hashCode => Object.hash(
        symbol,
        companyName,
        description,
        sector,
        industry,
        website,
        imageUrl,
        currency,
        exchange,
      );
}
