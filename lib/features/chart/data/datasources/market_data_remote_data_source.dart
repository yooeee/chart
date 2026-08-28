import '../models/market_bar_model.dart';

abstract interface class MarketDataRemoteDataSource {
  Future<List<MarketBarModel>> fetchMarketBars({
    required String ticker,
    required String timeRange,
  });
}
