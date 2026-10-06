import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/config/app_config.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/network/dio_provider.dart';
import 'package:versatech_investment_companion/features/market_data/data/datasources/fmp_market_data_source.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

void main() {
  const fakeKey = 'test-key';

  test('refuses a remote call when the API key is missing', () async {
    final dio = createFmpDio(const AppConfig(apiKey: '   '));
    dio.httpClientAdapter = _FailingAdapter();
    final source = FmpMarketDataSource(
      dio: dio,
      config: const AppConfig(apiKey: '   '),
    );

    expect(
      () => source.getQuote('AAPL'),
      throwsA(isA<MissingApiKeyException>()),
    );
  });

  test('builds the historical request parameters', () async {
    final config = const AppConfig(apiKey: fakeKey);
    final dio = createFmpDio(config);
    final adapter = _ScriptedFmpAdapter(['[]']);
    dio.httpClientAdapter = adapter;
    final source = FmpMarketDataSource(dio: dio, config: config);

    final prices = await source.getHistoricalPrices(
      symbol: 'AAPL',
      from: DateTime(2024, 1, 2),
      to: DateTime(2024, 3, 15),
    );

    expect(prices, isEmpty);
    final request = adapter.requests.single;
    expect(request.uri.path, '/stable/historical-price-eod/full');
    expect(request.queryParameters['symbol'], 'AAPL');
    expect(request.queryParameters['from'], '2024-01-02');
    expect(request.queryParameters['to'], '2024-03-15');
    expect(request.queryParameters['apikey'], fakeKey);
  });

  test('reads an ETF type from the profile when search omits it', () async {
    final config = const AppConfig(apiKey: fakeKey);
    final dio = createFmpDio(config);
    final adapter = _ScriptedFmpAdapter([
      '''
      [
        {
          "symbol": "SPY",
          "name": "SPDR S&P 500 ETF Trust",
          "currency": "USD",
          "exchange": "NYSE"
        }
      ]
      ''',
      '''
      [
        {
          "symbol": "SPY",
          "isEtf": true,
          "isFund": false
        }
      ]
      ''',
    ]);
    dio.httpClientAdapter = adapter;
    final source = FmpMarketDataSource(dio: dio, config: config);

    final assets = await source.searchAssets('SPY');

    expect(adapter.requests.map((request) => request.uri.path), [
      '/stable/search-symbol',
      '/stable/profile',
    ]);
    expect(assets.single.type, AssetType.etf);
    expect(assets.single.symbol, 'SPY');
  });

  test('caps untyped profile lookups at five results', () async {
    const symbols = ['AAA', 'BBB', 'CCC', 'DDD', 'EEE', 'FFF'];
    final config = const AppConfig(apiKey: fakeKey);
    final dio = createFmpDio(config);
    final adapter = _ScriptedFmpAdapter([
      '[${symbols.map(_searchRow).join(',')}]',
      for (final symbol in symbols.take(5)) _profileTypeRow(symbol),
    ]);
    dio.httpClientAdapter = adapter;
    final source = FmpMarketDataSource(dio: dio, config: config);

    final assets = await source.searchAssets('A');

    expect(adapter.requests, hasLength(6));
    expect(adapter.requests.first.uri.path, '/stable/search-symbol');
    expect(
      adapter.requests.skip(1).map((request) => request.uri.path),
      everyElement('/stable/profile'),
    );
    expect(assets.map((asset) => asset.symbol),
        ['AAA', 'BBB', 'CCC', 'DDD', 'EEE']);
    expect(assets.every((asset) => asset.type == AssetType.stock), isTrue);
  });

  test('returns an empty quote lookup as not found', () async {
    final config = const AppConfig(apiKey: fakeKey);
    final dio = createFmpDio(config);
    dio.httpClientAdapter = _ScriptedFmpAdapter(['[]']);
    final source = FmpMarketDataSource(dio: dio, config: config);

    expect(
      () => source.getQuote('MISSING'),
      throwsA(isA<MarketDataNotFoundException>()),
    );
  });
}

class _ScriptedFmpAdapter implements HttpClientAdapter {
  _ScriptedFmpAdapter(this._bodies);

  final List<String> _bodies;
  final requests = <RequestOptions>[];
  var _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = _bodies[_index];
    _index += 1;
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

String _searchRow(String symbol) {
  return '''
{"symbol":"$symbol","name":"$symbol Corp","currency":"USD","exchange":"NYSE"}
''';
}

String _profileTypeRow(String symbol) {
  return '''
[{"symbol":"$symbol","isEtf":false,"isFund":false}]
''';
}

class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw StateError('The HTTP adapter must not be called.');
  }

  @override
  void close({bool force = false}) {}
}
