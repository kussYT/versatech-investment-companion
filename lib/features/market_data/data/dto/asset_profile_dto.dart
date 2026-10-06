import 'package:versatech_investment_companion/features/market_data/data/parsing/json_values.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';

class AssetProfileDto {
  const AssetProfileDto({
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

  factory AssetProfileDto.fromJson(Map<String, dynamic> json) {
    return AssetProfileDto(
      symbol: requireText(json, 'symbol'),
      companyName: requireText(json, 'companyName'),
      description: requireText(json, 'description'),
      sector: optionalText(json, 'sector'),
      industry: optionalText(json, 'industry'),
      website: optionalText(json, 'website'),
      imageUrl: optionalText(json, 'image'),
      currency: requireText(json, 'currency'),
      exchange: requireFirstText(
        json,
        const ['exchangeShortName', 'exchange'],
      ),
    );
  }

  static List<AssetProfileDto> fromJsonList(Object? data) {
    return [
      for (final item in asJsonList(data))
        AssetProfileDto.fromJson(asJsonMap(item, 'profile')),
    ];
  }

  AssetProfile toDomain() {
    return AssetProfile(
      symbol: symbol,
      companyName: companyName,
      description: description,
      sector: sector,
      industry: industry,
      website: website,
      imageUrl: imageUrl,
      currency: currency,
      exchange: exchange,
    );
  }
}
