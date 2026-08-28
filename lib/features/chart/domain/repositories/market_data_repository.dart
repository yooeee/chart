import '../entities/market_bar.dart';

abstract interface class MarketDataRepository {
  Future<List<MarketBar>> fetchMarketBars({
    required String ticker,
    required String timeRange,
  });
}
