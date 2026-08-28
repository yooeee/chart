import '../../domain/entities/market_bar.dart';
import '../../domain/repositories/market_data_repository.dart';
import '../datasources/market_data_remote_data_source.dart';

class MarketDataRepositoryImpl implements MarketDataRepository {
  const MarketDataRepositoryImpl({
    required MarketDataRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MarketDataRemoteDataSource _remoteDataSource;

  @override
  Future<List<MarketBar>> fetchMarketBars({
    required String ticker,
    required String timeRange,
  }) async {
    final marketBarModels = await _remoteDataSource.fetchMarketBars(
      ticker: ticker,
      timeRange: timeRange,
    );
    return List<MarketBar>.unmodifiable(
      marketBarModels.map((marketBarModel) => marketBarModel.toEntity()),
    );
  }
}
