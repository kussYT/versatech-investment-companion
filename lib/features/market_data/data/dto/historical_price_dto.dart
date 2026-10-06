import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/parsing/json_values.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';

class HistoricalPriceDto {
  const HistoricalPriceDto({
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

  factory HistoricalPriceDto.fromJson(Map<String, dynamic> json) {
    final high = requireDouble(json['high'], 'high');
    final low = requireDouble(json['low'], 'low');
    if (high < low) {
      throw InvalidMarketDataException('High is lower than low.');
    }

    return HistoricalPriceDto(
      symbol: requireText(json, 'symbol'),
      date: requireCalendarDate(json['date'], 'date'),
      open: requireDouble(json['open'], 'open'),
      high: high,
      low: low,
      close: requireDouble(json['close'], 'close'),
      volume: requireWholeNumber(json['volume'], 'volume'),
    );
  }

  static List<HistoricalPriceDto> fromJsonList(Object? data) {
    return [
      for (final item in asJsonList(data))
        HistoricalPriceDto.fromJson(asJsonMap(item, 'historical price')),
    ];
  }

  HistoricalPrice toDomain() {
    return HistoricalPrice(
      symbol: symbol,
      date: date,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}
