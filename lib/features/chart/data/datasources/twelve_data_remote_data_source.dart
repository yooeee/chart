import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/market_symbol_catalog.dart';
import '../../domain/entities/market_timeframe.dart';
import '../../domain/errors/market_data_exception.dart';
import '../models/market_bar_model.dart';
import 'market_data_remote_data_source.dart';

/// Twelve Data adapter. The API key is supplied at build or run time.
class TwelveDataRemoteDataSource implements MarketDataRemoteDataSource {
  TwelveDataRemoteDataSource({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('TWELVE_DATA_API_KEY');

  final http.Client _client;
  final String _apiKey;

  @override
  Future<List<MarketBarModel>> fetchMarketBars({
    required String ticker,
    required String timeRange,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const MarketDataException(
        'TWELVE_DATA_API_KEY가 설정되지 않았습니다.\n'
        '실행 시 --dart-define=TWELVE_DATA_API_KEY=키 값을 전달하세요.',
      );
    }

    final marketSymbol = MarketSymbolCatalog.findByTicker(ticker);
    final timeframe = MarketTimeframe.fromRange(timeRange);
    final requestUri = Uri.https(
      'api.twelvedata.com',
      '/time_series',
      <String, String>{
        'symbol': marketSymbol.providerSymbol,
        'exchange': marketSymbol.providerExchange,
        'interval': timeframe.interval,
        'outputsize': timeframe.outputSize.toString(),
        'apikey': _apiKey,
      },
    );

    late http.Response response;
    try {
      response = await _client.get(requestUri).timeout(
        const Duration(seconds: 15),
      );
    } on Exception catch (error) {
      throw MarketDataException('시세 서버에 연결하지 못했습니다.\n$error');
    }

    if (response.statusCode != 200) {
      final statusCode = response.statusCode;
      throw MarketDataException(
        '시세 서버 응답 오류($statusCode)가 발생했습니다.',
      );
    }

    late final Object? decodedResponse;
    try {
      decodedResponse = jsonDecode(response.body);
    } on FormatException {
      throw const MarketDataException('시세 서버 응답 형식이 올바르지 않습니다.');
    }

    if (decodedResponse is! Map) {
      throw const MarketDataException('시세 서버 응답 형식이 올바르지 않습니다.');
    }

    final responsePayload = Map<String, dynamic>.from(decodedResponse);
    final status = responsePayload['status']?.toString().toLowerCase();
    if (status == 'error' || responsePayload['values'] == null) {
      final message =
          responsePayload['message']?.toString() ?? '시세 데이터를 받을 수 없습니다.';
      throw MarketDataException(message);
    }

    return parseMarketBarModels(responsePayload);
  }

  /// Converts Twelve Data's descending response into ascending time order.
  static List<MarketBarModel> parseMarketBarModels(
    Map<String, dynamic> responsePayload,
  ) {
    final rawValues = responsePayload['values'];
    if (rawValues is! List) {
      throw const MarketDataException('시세 데이터 목록이 응답에 없습니다.');
    }

    final marketBarModels = <MarketBarModel>[];
    for (final rawValue in rawValues) {
      if (rawValue is! Map) continue;
      final marketBarModel = MarketBarModel.tryParse(
        Map<String, dynamic>.from(rawValue),
      );
      if (marketBarModel != null) {
        marketBarModels.add(marketBarModel);
      }
    }

    if (marketBarModels.length < 2) {
      throw const MarketDataException('차트를 그릴 수 있는 시세 데이터가 부족합니다.');
    }

    marketBarModels.sort(
      (first, second) => first.timestamp.compareTo(second.timestamp),
    );
    return List<MarketBarModel>.unmodifiable(marketBarModels);
  }
}
