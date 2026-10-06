import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/dto/historical_price_dto.dart';

void main() {
  test('converts a historical bar from numeric values', () {
    final price = HistoricalPriceDto.fromJson({
      'symbol': 'AAPL',
      'date': '2024-01-02',
      'open': 187.15,
      'high': 188.44,
      'low': 183.89,
      'close': 185.64,
      'volume': 82488700,
    }).toDomain();

    expect(price.symbol, 'AAPL');
    expect(price.date, DateTime.utc(2024, 1, 2));
    expect(price.open, 187.15);
    expect(price.high, 188.44);
    expect(price.low, 183.89);
    expect(price.close, 185.64);
    expect(price.volume, 82488700);
  });

  test('converts historical numbers provided as strings', () {
    final price = HistoricalPriceDto.fromJson({
      'symbol': 'SPY',
      'date': '2024-03-15',
      'open': '510.25',
      'high': '512.10',
      'low': '508.40',
      'close': '511.80',
      'volume': '73451234',
    }).toDomain();

    expect(price.open, 510.25);
    expect(price.close, 511.80);
    expect(price.volume, 73451234);
  });

  test('rejects an invalid historical date', () {
    expect(
      () => HistoricalPriceDto.fromJson({
        'symbol': 'AAPL',
        'date': '2024-02-31',
        'open': 1,
        'high': 1,
        'low': 1,
        'close': 1,
        'volume': 1,
      }),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('rejects a missing close', () {
    expect(
      () => HistoricalPriceDto.fromJson({
        'symbol': 'AAPL',
        'date': '2024-01-02',
        'open': 1,
        'high': 1,
        'low': 1,
        'volume': 1,
      }),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('parses an empty historical list', () {
    expect(HistoricalPriceDto.fromJsonList([]), isEmpty);
  });
}
