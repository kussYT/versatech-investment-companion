import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

/// Application-facing market data, including cache metadata.
abstract interface class MarketDataRepository {
  Future<CachedResult<List<Asset>>> searchAssets(
    String query, {
    bool forceRefresh = false,
  });

  Future<CachedResult<AssetProfile>> getProfile(
    String symbol, {
    bool forceRefresh = false,
  });

  Future<CachedResult<MarketQuote>> getQuote(
    String symbol, {
    bool forceRefresh = false,
  });

  Future<CachedResult<List<HistoricalPrice>>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
    bool forceRefresh = false,
  });
}

/// Remote-only contract used behind the cache. It does not describe freshness.
abstract interface class MarketDataRemote {
  Future<List<Asset>> searchAssets(String query);

  Future<AssetProfile> getProfile(String symbol);

  Future<MarketQuote> getQuote(String symbol);

  Future<List<HistoricalPrice>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
  });
}
