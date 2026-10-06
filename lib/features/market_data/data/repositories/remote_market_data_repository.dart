import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/network/network_exception_mapper.dart';
import 'package:versatech_investment_companion/features/market_data/data/datasources/fmp_market_data_source.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';
import 'package:versatech_investment_companion/features/market_data/domain/repositories/market_data_repository.dart';

class RemoteMarketDataRepository implements MarketDataRepository {
  const RemoteMarketDataRepository({required FmpMarketDataSource dataSource})
      : _dataSource = dataSource;

  final FmpMarketDataSource _dataSource;

  @override
  Future<List<Asset>> searchAssets(String query) {
    return _guard(() => _dataSource.searchAssets(query));
  }

  @override
  Future<AssetProfile> getProfile(String symbol) {
    return _guard(() => _dataSource.getProfile(symbol));
  }

  @override
  Future<MarketQuote> getQuote(String symbol) {
    return _guard(() => _dataSource.getQuote(symbol));
  }

  @override
  Future<List<HistoricalPrice>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
  }) {
    return _guard(
      () => _dataSource.getHistoricalPrices(
        symbol: symbol,
        from: from,
        to: to,
      ),
    );
  }

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw mapDioException(error);
    } on FormatException {
      throw InvalidMarketDataException('The response was not valid JSON.');
    } catch (_) {
      throw const UnknownRemoteException();
    }
  }
}

final marketDataRepositoryProvider = Provider<MarketDataRepository>((ref) {
  return RemoteMarketDataRepository(
    dataSource: ref.watch(fmpMarketDataSourceProvider),
  );
});
