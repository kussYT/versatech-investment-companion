import 'dart:async';

import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/errors/failure.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';

class DetailCall {
  const DetailCall({
    required this.symbol,
    required this.forceRefresh,
    this.from,
    this.to,
  });

  final String symbol;
  final bool forceRefresh;
  final DateTime? from;
  final DateTime? to;
}

class FakeMarketDataRepository implements MarketDataRepository {
  FakeMarketDataRepository({
    this.profileResult,
    this.quoteResult,
    this.historyResult,
    this.profileError,
    this.quoteError,
    this.historyError,
  });

  CachedResult<AssetProfile>? profileResult;
  CachedResult<MarketQuote>? quoteResult;
  CachedResult<List<HistoricalPrice>>? historyResult;
  AppException? profileError;
  AppException? quoteError;
  AppException? historyError;
  Completer<void>? profileGate;
  Completer<void>? quoteGate;
  Completer<void>? historyGate;

  final profileCalls = <DetailCall>[];
  final quoteCalls = <DetailCall>[];
  final historyCalls = <DetailCall>[];

  bool get isWaiting {
    return profileGate != null || quoteGate != null || historyGate != null;
  }

  @override
  Future<CachedResult<List<Asset>>> searchAssets(
    String query, {
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CachedResult<AssetProfile>> getProfile(
    String symbol, {
    bool forceRefresh = false,
  }) async {
    profileCalls.add(
      DetailCall(symbol: symbol, forceRefresh: forceRefresh),
    );
    final gate = profileGate;
    if (gate != null) {
      await gate.future;
    }
    final error = profileError;
    if (error != null) {
      throw error;
    }
    return profileResult!;
  }

  @override
  Future<CachedResult<MarketQuote>> getQuote(
    String symbol, {
    bool forceRefresh = false,
  }) async {
    quoteCalls.add(DetailCall(symbol: symbol, forceRefresh: forceRefresh));
    final gate = quoteGate;
    if (gate != null) {
      await gate.future;
    }
    final error = quoteError;
    if (error != null) {
      throw error;
    }
    return quoteResult!;
  }

  @override
  Future<CachedResult<List<HistoricalPrice>>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
    bool forceRefresh = false,
  }) async {
    historyCalls.add(
      DetailCall(
        symbol: symbol,
        forceRefresh: forceRefresh,
        from: from,
        to: to,
      ),
    );
    final gate = historyGate;
    if (gate != null) {
      await gate.future;
    }
    final error = historyError;
    if (error != null) {
      throw error;
    }
    return historyResult!;
  }
}

CachedResult<T> detailResult<T>(
  T data, {
  DataOrigin origin = DataOrigin.remote,
  DateTime? lastUpdatedAt,
  bool isStale = false,
  Failure? remoteFailure,
}) {
  return CachedResult(
    data: data,
    origin: origin,
    lastUpdatedAt: lastUpdatedAt ?? DateTime.utc(2024, 6, 3, 12),
    isStale: isStale,
    remoteFailure: remoteFailure,
  );
}

AssetProfile detailProfile({
  String symbol = 'AAPL',
  String companyName = 'Apple Inc.',
  String description = 'Conçoit des appareils électroniques.',
  String? sector = 'Technology',
  String? industry = 'Consumer Electronics',
  String? website = 'https://apple.com',
  String currency = 'USD',
  String exchange = 'NASDAQ',
}) {
  return AssetProfile(
    symbol: symbol,
    companyName: companyName,
    description: description,
    sector: sector,
    industry: industry,
    website: website,
    currency: currency,
    exchange: exchange,
  );
}

MarketQuote detailQuote({
  String symbol = 'AAPL',
  double price = 189.25,
  double change = 1.5,
  double changePercent = 0.8,
  DateTime? timestamp,
}) {
  return MarketQuote(
    symbol: symbol,
    price: price,
    change: change,
    changePercent: changePercent,
    timestamp: timestamp ?? DateTime.utc(2024, 6, 14, 20),
  );
}

HistoricalPrice detailBar({
  String symbol = 'AAPL',
  required DateTime date,
  required double close,
}) {
  return HistoricalPrice(
    symbol: symbol,
    date: date,
    open: close,
    high: close,
    low: close,
    close: close,
    volume: 10,
  );
}
