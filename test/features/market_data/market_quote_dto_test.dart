import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/dto/market_quote_dto.dart';

void main() {
  test('converts numeric quote fields', () {
    final quote = MarketQuoteDto.fromJson({
      'symbol': 'AAPL',
      'price': 268.47,
      'change': -1.3,
      'changePercentage': -0.48189,
      'previousClose': 269.77,
      'timestamp': 1762549202,
    }).toDomain();

    expect(quote.symbol, 'AAPL');
    expect(quote.price, 268.47);
    expect(quote.change, -1.3);
    expect(quote.changePercent, -0.48189);
    expect(quote.previousClose, 269.77);
    expect(quote.timestamp, DateTime.utc(2025, 11, 7, 21, 0, 2));
  });

  test('converts numeric quote fields provided as strings', () {
    final quote = MarketQuoteDto.fromJson({
      'symbol': 'AAPL',
      'price': '268.47',
      'change': '-1.3',
      'changePercentage': '-0.48189',
      'timestamp': '1762549202',
    }).toDomain();

    expect(quote.price, 268.47);
    expect(quote.change, -1.3);
    expect(quote.changePercent, -0.48189);
    expect(quote.previousClose, isNull);
    expect(quote.timestamp, DateTime.utc(2025, 11, 7, 21, 0, 2));
  });

  test('rejects a quote without a price', () {
    expect(
      () => MarketQuoteDto.fromJson({
        'symbol': 'AAPL',
        'change': -1.3,
        'changePercentage': -0.4,
        'timestamp': 1762549202,
      }),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('parses an empty quote list', () {
    expect(MarketQuoteDto.fromJsonList([]), isEmpty);
  });
}
