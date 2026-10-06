import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/config/app_config.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/network/dio_provider.dart';
import 'package:versatech_investment_companion/features/market_data/data/dto/asset_dto.dart';
import 'package:versatech_investment_companion/features/market_data/data/dto/asset_profile_dto.dart';
import 'package:versatech_investment_companion/features/market_data/data/dto/historical_price_dto.dart';
import 'package:versatech_investment_companion/features/market_data/data/dto/market_quote_dto.dart';
import 'package:versatech_investment_companion/features/market_data/data/parsing/json_values.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

/// Stable Financial Modeling Prep endpoints.
///
/// Search results from `search-symbol` do not include an instrument type.
/// Type is read from explicit `isEtf` / `isFund` fields when present, and
/// otherwise from `profile`, which publishes those flags. That lookup stays
/// in this source so another endpoint can replace it without touching the
/// domain.
class FmpMarketDataSource {
  FmpMarketDataSource({
    required Dio dio,
    required AppConfig config,
  })  : _dio = dio,
        _config = config;

  static const searchPath = 'search-symbol';
  static const profilePath = 'profile';
  static const quotePath = 'quote';
  static const historicalPath = 'historical-price-eod/full';
  static const searchLimit = 20;

  final Dio _dio;
  final AppConfig _config;

  Future<List<Asset>> searchAssets(String query) async {
    final rows = asJsonList(
      await _get(searchPath, {
        'query': _requiredText(query, 'Search query is empty.'),
        'limit': searchLimit,
      }),
    );

    final assets = <Asset>[];
    for (final row in rows) {
      final json = await _withInstrumentType(asJsonMap(row, 'asset'));
      try {
        assets.add(AssetDto.fromJson(json).toDomain());
      } on UnsupportedAssetTypeException {
        continue;
      }
    }
    return assets;
  }

  Future<AssetProfile> getProfile(String symbol) async {
    final profiles = AssetProfileDto.fromJsonList(
      await _get(profilePath, {
        'symbol': _requiredText(symbol, 'Symbol is empty.'),
      }),
    );
    if (profiles.isEmpty) {
      throw const MarketDataNotFoundException();
    }
    return profiles.first.toDomain();
  }

  Future<MarketQuote> getQuote(String symbol) async {
    final quotes = MarketQuoteDto.fromJsonList(
      await _get(quotePath, {
        'symbol': _requiredText(symbol, 'Symbol is empty.'),
      }),
    );
    if (quotes.isEmpty) {
      throw const MarketDataNotFoundException();
    }
    return quotes.first.toDomain();
  }

  Future<List<HistoricalPrice>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
  }) async {
    if (_calendarDate(from).isAfter(_calendarDate(to))) {
      throw InvalidMarketDataException(
        'The historical range is reversed.',
      );
    }

    final data = await _get(historicalPath, {
      'symbol': _requiredText(symbol, 'Symbol is empty.'),
      'from': _formatDate(from),
      'to': _formatDate(to),
    });

    return [
      for (final price
          in HistoricalPriceDto.fromJsonList(_historicalRows(data)))
        price.toDomain(),
    ];
  }

  Future<Object?> _get(
      String path, Map<String, dynamic> queryParameters) async {
    _ensureApiKey();
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  void _ensureApiKey() {
    if (!_config.hasApiKey) {
      throw const MissingApiKeyException();
    }
  }

  Future<Map<String, dynamic>> _withInstrumentType(
    Map<String, dynamic> row,
  ) async {
    if (row['isEtf'] is bool) {
      return row;
    }

    final profiles = asJsonList(
      await _get(profilePath, {'symbol': requireText(row, 'symbol')}),
    );
    if (profiles.isEmpty) {
      throw InvalidMarketDataException(
        'Instrument type is unavailable.',
      );
    }
    final profile = asJsonMap(profiles.first, 'profile');
    if (profile['isEtf'] is! bool) {
      throw InvalidMarketDataException('Instrument type is absent.');
    }

    return {
      ...row,
      'isEtf': profile['isEtf'],
      if (profile.containsKey('isFund')) 'isFund': profile['isFund'],
    };
  }

  String _requiredText(String value, String message) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw InvalidMarketDataException(message);
    }
    return trimmed;
  }

  DateTime _calendarDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  List<dynamic> _historicalRows(Object? data) {
    if (data is List) {
      return data;
    }
    if (data is Map && data['historical'] is List) {
      return data['historical'] as List;
    }
    return asJsonList(data);
  }
}

final fmpMarketDataSourceProvider = Provider<FmpMarketDataSource>((ref) {
  return FmpMarketDataSource(
    dio: ref.watch(dioProvider),
    config: ref.watch(appConfigProvider),
  );
});
