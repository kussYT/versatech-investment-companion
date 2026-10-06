import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/parsing/json_values.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

class AssetDto {
  const AssetDto({
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

  factory AssetDto.fromJson(Map<String, dynamic> json) {
    return AssetDto(
      symbol: requireText(json, 'symbol'),
      name: requireText(json, 'name'),
      type: _assetType(json),
      exchange: requireFirstText(json, const ['exchange', 'exchangeFullName']),
      currency: requireText(json, 'currency'),
    );
  }

  static List<AssetDto> fromJsonList(Object? data) {
    return [
      for (final item in asJsonList(data))
        AssetDto.fromJson(asJsonMap(item, 'asset')),
    ];
  }

  Asset toDomain() {
    return Asset(
      symbol: symbol,
      name: name,
      type: type,
      exchange: exchange,
      currency: currency,
    );
  }

  static AssetType _assetType(Map<String, dynamic> json) {
    final isEtf = json['isEtf'];
    final isFund = json['isFund'];
    if (isEtf is! bool || (isFund != null && isFund is! bool)) {
      throw InvalidMarketDataException('Unsupported instrument type.');
    }
    if (isEtf) {
      return AssetType.etf;
    }
    if (isFund == true) {
      throw const UnsupportedAssetTypeException();
    }
    return AssetType.stock;
  }
}
