import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/config/app_config.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/network/dio_provider.dart';
import 'package:versatech_investment_companion/features/market_data/data/datasources/fmp_market_data_source.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

void main() {
  const fakeKey = _fakeKey;

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

  test('keeps every asset when each profile is valid', () async {
    final adapter = _ScriptedFmpAdapter([
      '[${_row('AAPL')},${_row('MSFT')}]',
      _profile('AAPL'),
      _profile('MSFT', etf: true),
    ]);
    final assets = await _source(adapter).searchAssets('aa');

    expect(adapter.requests.first.queryParameters['limit'], 5);
    expect(
      adapter.requests.map((request) => request.uri.path),
      [
        '/stable/search-symbol',
        '/stable/profile',
        '/stable/profile',
      ],
    );
    expect(assets.map((asset) => asset.symbol), ['AAPL', 'MSFT']);
    expect(assets.map((asset) => asset.type), [AssetType.stock, AssetType.etf]);
  });

  test('keeps the other assets when a secondary profile fails', () async {
    final adapter = _ScriptedFmpAdapter([
      '[${_row('AAPL')},${_row('AAPB')}]',
      _profile('AAPL'),
      '{"Error Message":"unavailable"}',
    ]);

    final assets = await _source(adapter).searchAssets('AAPL');

    expect(assets.map((asset) => asset.symbol), ['AAPL']);
    expect(adapter.requests, hasLength(3));
  });

  test('skips an empty profile and keeps the resolved asset', () async {
    final adapter = _ScriptedFmpAdapter([
      '[${_row('AAPL')},${_row('AAPB')}]',
      _profile('AAPL'),
      '[]',
    ]);

    final assets = await _source(adapter).searchAssets('AAPL');

    expect(assets.map((asset) => asset.symbol), ['AAPL']);
  });

  test('skips a profile that does not publish isEtf', () async {
    final adapter = _ScriptedFmpAdapter([
      '[${_row('AAPL')},${_row('AAPB')}]',
      _profile('AAPL'),
      '[{"symbol":"AAPB","isFund":false}]',
    ]);

    final assets = await _source(adapter).searchAssets('AAPL');

    expect(assets.single.symbol, 'AAPL');
    expect(assets.single.type, AssetType.stock);
  });

  test('skips a profile whose JSON is invalid', () async {
    final adapter = _ScriptedFmpAdapter([
      '[${_row('AAPL')},${_row('AAPB')}]',
      _profile('AAPL'),
      '{',
    ]);

    final assets = await _source(adapter).searchAssets('AAPL');

    expect(assets.single.symbol, 'AAPL');
  });

  test('propagates a search-symbol failure without reading profiles', () async {
    final adapter = _ScriptedFmpAdapter([
      '{"Error Message":"unavailable"}',
    ]);

    await expectLater(
      _source(adapter).searchAssets('AAPL'),
      throwsA(isA<UnknownRemoteException>()),
    );
    expect(adapter.requests.single.uri.path, '/stable/search-symbol');
  });

  test('returns an empty search as an empty list', () async {
    final adapter = _ScriptedFmpAdapter(['[]']);

    final assets = await _source(adapter).searchAssets('ZZZZ');

    expect(assets, isEmpty);
    expect(adapter.requests.single.uri.path, '/stable/search-symbol');
  });

  test('reports an error when every profile fails', () async {
    final adapter = _ScriptedFmpAdapter([
      '[${_row('AAPL')},${_row('AAPB')}]',
      '{"Error Message":"unavailable"}',
      '{"Error Message":"unavailable"}',
    ]);

    await expectLater(
      _source(adapter).searchAssets('AAPL'),
      throwsA(isA<UnknownRemoteException>()),
    );
    expect(
      adapter.requests
          .where((request) => request.uri.path == '/stable/profile'),
      hasLength(2),
    );
  });

  test('reports the quota when no profile can be resolved', () async {
    final adapter = _ScriptedFmpAdapter(
      [
        '[${_row('AAPL')},${_row('AAPB')}]',
        '{}',
        _profile('AAPB'),
      ],
      statusCodes: const [200, 429, 200],
    );

    await expectLater(
      _source(adapter).searchAssets('AAPL'),
      throwsA(isA<RateLimitException>()),
    );
    expect(adapter.requests, hasLength(2));
  });

  test('keeps resolved assets when a later profile hits the quota', () async {
    final adapter = _ScriptedFmpAdapter(
      [
        '[${_row('AAPL')},${_row('MSFT')},${_row('NVDA')}]',
        _profile('AAPL'),
        '{}',
        _profile('NVDA'),
      ],
      statusCodes: const [200, 200, 429, 200],
    );

    final assets = await _source(adapter).searchAssets('AAPL');

    expect(assets.single.symbol, 'AAPL');
    expect(adapter.requests, hasLength(3));
  });

  test('resolves at most five profiles', () async {
    final symbols = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8'];
    final adapter = _ScriptedFmpAdapter([
      '[${symbols.map(_row).join(',')}]',
      for (final symbol in symbols.take(5)) _profile(symbol),
    ]);

    final assets = await _source(adapter).searchAssets('S');

    expect(adapter.requests.first.queryParameters['limit'], 5);
    expect(assets.map((asset) => asset.symbol), symbols.take(5));
    expect(
      adapter.requests
          .where((request) => request.uri.path == '/stable/profile')
          .map((request) => request.queryParameters['symbol']),
      symbols.take(5),
    );
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

const _fakeKey = 'test-key';

FmpMarketDataSource _source(_ScriptedFmpAdapter adapter) {
  final config = const AppConfig(apiKey: _fakeKey);
  final dio = createFmpDio(config);
  dio.httpClientAdapter = adapter;
  return FmpMarketDataSource(dio: dio, config: config);
}

String _row(String symbol) {
  return '{"symbol":"$symbol","name":"$symbol Inc.","currency":"USD","exchange":"NASDAQ"}';
}

String _profile(String symbol, {bool etf = false}) {
  return '[{"symbol":"$symbol","isEtf":$etf,"isFund":false}]';
}

class _ScriptedFmpAdapter implements HttpClientAdapter {
  _ScriptedFmpAdapter(this._bodies, {this.statusCodes = const []});

  final List<String> _bodies;
  final List<int> statusCodes;
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
    final status = _index < statusCodes.length ? statusCodes[_index] : 200;
    _index += 1;
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
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
