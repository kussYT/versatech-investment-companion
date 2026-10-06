import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/data/dto/asset_profile_dto.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';

void main() {
  test('converts a profile and keeps optional fields empty', () {
    final profile = AssetProfileDto.fromJson({
      'symbol': 'AAPL',
      'companyName': 'Apple Inc.',
      'description': 'Designs consumer electronics.',
      'currency': 'USD',
      'exchangeShortName': 'NASDAQ',
      'sector': '',
      'industry': null,
    }).toDomain();

    expect(
      profile,
      const AssetProfile(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        description: 'Designs consumer electronics.',
        currency: 'USD',
        exchange: 'NASDAQ',
      ),
    );
    expect(profile.sector, isNull);
    expect(profile.industry, isNull);
    expect(profile.website, isNull);
    expect(profile.imageUrl, isNull);
  });

  test('reads optional profile links when they are present', () {
    final profile = AssetProfileDto.fromJson({
      'symbol': 'SPY',
      'companyName': 'SPDR S&P 500 ETF Trust',
      'description': 'Tracks the S&P 500.',
      'currency': 'USD',
      'exchange': 'NYSE Arca',
      'sector': 'Financial Services',
      'industry': 'Asset Management',
      'website': 'https://www.ssga.com',
      'image': 'https://images.financialmodelingprep.com/symbol/SPY.png',
    }).toDomain();

    expect(profile.sector, 'Financial Services');
    expect(profile.industry, 'Asset Management');
    expect(profile.website, 'https://www.ssga.com');
    expect(
      profile.imageUrl,
      'https://images.financialmodelingprep.com/symbol/SPY.png',
    );
    expect(profile.exchange, 'NYSE Arca');
  });

  test('rejects a profile without a description', () {
    expect(
      () => AssetProfileDto.fromJson({
        'symbol': 'AAPL',
        'companyName': 'Apple Inc.',
        'currency': 'USD',
        'exchange': 'NASDAQ',
      }),
      throwsA(isA<InvalidMarketDataException>()),
    );
  });

  test('parses an empty profile list', () {
    expect(AssetProfileDto.fromJsonList([]), isEmpty);
  });
}
