import '../entities/market_bar.dart';
import '../repositories/market_data_repository.dart';

class FetchMarketBars {
  const FetchMarketBars(this._marketDataRepository);

  final MarketDataRepository _marketDataRepository;

  Future<List<MarketBar>> call({
    required String ticker,
    required String timeRange,
  }) {
    return _marketDataRepository.fetchMarketBars(
      ticker: ticker,
      timeRange: timeRange,
    );
  }
}
