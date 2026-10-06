import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

abstract interface class MarketDataRepository {
  Future<List<Asset>> searchAssets(String query);

  Future<AssetProfile> getProfile(String symbol);

  Future<MarketQuote> getQuote(String symbol);

  Future<List<HistoricalPrice>> getHistoricalPrices({
    required String symbol,
    required DateTime from,
    required DateTime to,
  });
}
