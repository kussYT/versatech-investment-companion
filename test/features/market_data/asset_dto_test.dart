import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/dto/asset_dto.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

void main() {
  const stockJson = {
    'symbol': 'AAPL',
    'name': 'Apple Inc.',
    'currency': 'USD',
    'exchange': 'NASDAQ',
    'isEtf': false,
  };

  test('converts a stock payload', () {
    final asset = AssetDto.fromJson(stockJson).toDomain();

    expect(
      asset,
      const Asset(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        type: AssetType.stock,
        exchange: 'NASDAQ',
        currency: 'USD',
      ),
    );
  });

  test('converts an ETF payload', () {
    final asset = AssetDto.fromJson({
      ...stockJson,
      'symbol': 'SPY',
      'name': 'SPDR S&P 500 ETF Trust',
      'exchange': 'NYSE',
      'isEtf': true,
    }).toDomain();

    expect(asset.type, AssetType.etf);
    expect(asset.symbol, 'SPY');
  });

  test('rejects an unknown instrument type', () {
    expect(
      () => AssetDto.fromJson({
        ...stockJson,
        'isEtf': 'crypto',
      }).toDomain(),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('rejects a mutual fund instead of classifying it as a stock', () {
    expect(
      () => AssetDto.fromJson({
        ...stockJson,
        'isEtf': false,
        'isFund': true,
      }).toDomain(),
      throwsA(isA<UnsupportedAssetTypeException>()),
    );
  });

  test('rejects a payload without an instrument type', () {
    final json = Map<String, dynamic>.from(stockJson)..remove('isEtf');

    expect(
      () => AssetDto.fromJson(json).toDomain(),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('rejects a missing required field', () {
    final json = Map<String, dynamic>.from(stockJson)..remove('name');

    expect(
      () => AssetDto.fromJson(json),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('parses an empty search list', () {
    expect(AssetDto.fromJsonList([]), isEmpty);
  });
}
