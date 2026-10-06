import 'package:versatech_investment_companion/features/market_data/data/parsing/json_values.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

class MarketQuoteDto {
  const MarketQuoteDto({
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

  factory MarketQuoteDto.fromJson(Map<String, dynamic> json) {
    return MarketQuoteDto(
      symbol: requireText(json, 'symbol'),
      price: requireDouble(json['price'], 'price'),
      change: requireDouble(json['change'], 'change', allowNegative: true),
      changePercent: requireFirstDouble(
        json,
        const ['changePercentage', 'changesPercentage'],
        allowNegative: true,
      ),
      previousClose: optionalDouble(json, 'previousClose'),
      timestamp: requireQuoteTimestamp(json),
    );
  }

  static List<MarketQuoteDto> fromJsonList(Object? data) {
    return [
      for (final item in asJsonList(data))
        MarketQuoteDto.fromJson(asJsonMap(item, 'quote')),
    ];
  }

  MarketQuote toDomain() {
    return MarketQuote(
      symbol: symbol,
      price: price,
      change: change,
      changePercent: changePercent,
      previousClose: previousClose,
      timestamp: timestamp,
    );
  }
}
