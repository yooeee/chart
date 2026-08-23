import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

class MarketBar {
  const MarketBar({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
}

class MarketSymbol {
  const MarketSymbol({
    required this.ticker,
    required this.name,
    required this.exchange,
    required this.basePrice,
    required this.change,
    required this.providerSymbol,
    required this.providerExchange,
  });

  final String ticker;
  final String name;
  final String exchange;
  final double basePrice;
  final double change;

  /// Symbol and exchange identifiers used by the selected market-data provider.
  final String providerSymbol;
  final String providerExchange;
}

class MarketTimeframe {
  const MarketTimeframe({
    required this.interval,
    required this.outputSize,
    required this.label,
  });

  final String interval;
  final int outputSize;
  final String label;

  static MarketTimeframe fromRange(String range) {
    switch (range) {
      case '1D':
        return const MarketTimeframe(interval: '15min', outputSize: 96, label: '15 min');
      case '1W':
        return const MarketTimeframe(interval: '1h', outputSize: 120, label: '1 hour');
      case '1M':
        return const MarketTimeframe(interval: '1day', outputSize: 31, label: 'Daily');
      case '3M':
        return const MarketTimeframe(interval: '1day', outputSize: 93, label: 'Daily');
      case '1Y':
        return const MarketTimeframe(interval: '1day', outputSize: 260, label: 'Daily');
      default:
        return const MarketTimeframe(interval: '1day', outputSize: 180, label: 'Daily');
    }
  }
}

class MarketDataException implements Exception {
  const MarketDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class MarketDataSource {
  Future<List<MarketBar>> barsFor(String ticker, {String range = '1D'});
}

/// Twelve Data OHLCV adapter.
///
/// The API key is intentionally read at build/run time instead of being stored
/// in source control:
///
/// flutter run -d chrome --dart-define=TWELVE_DATA_API_KEY=...
/// flutter build apk --release --dart-define=TWELVE_DATA_API_KEY=...
class TwelveDataMarketDataSource implements MarketDataSource {
  TwelveDataMarketDataSource({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('TWELVE_DATA_API_KEY');

  final http.Client _client;
  final String _apiKey;

  @override
  Future<List<MarketBar>> barsFor(String ticker, {String range = '1D'}) async {
    if (_apiKey.trim().isEmpty) {
      throw const MarketDataException(
        'TWELVE_DATA_API_KEY가 설정되지 않았습니다.\n'
        '실행 시 --dart-define=TWELVE_DATA_API_KEY=키 값을 전달하세요.',
      );
    }

    final symbol = DemoMarketDataSource.symbolFor(ticker);
    final timeframe = MarketTimeframe.fromRange(range);
    final uri = Uri.https(
      'api.twelvedata.com',
      '/time_series',
      <String, String>{
        'symbol': symbol.providerSymbol,
        'exchange': symbol.providerExchange,
        'interval': timeframe.interval,
        'outputsize': timeframe.outputSize.toString(),
        'apikey': _apiKey,
      },
    );

    late http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on Exception catch (error) {
      throw MarketDataException('시세 서버에 연결하지 못했습니다.\n$error');
    }

    if (response.statusCode != 200) {
      throw MarketDataException(
        '시세 서버 응답 오류(${response.statusCode})가 발생했습니다.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const MarketDataException('시세 서버 응답 형식이 올바르지 않습니다.');
    }

    final payload = Map<String, dynamic>.from(decoded);
    final status = payload['status']?.toString().toLowerCase();
    if (status == 'error' || payload['values'] == null) {
      final message = payload['message']?.toString() ?? '시세 데이터를 받을 수 없습니다.';
      throw MarketDataException(message);
    }

    return parseBars(payload);
  }

  /// Parses Twelve Data's descending `values` response into ascending bars.
  /// Kept public so the response transformation can be tested without a network call.
  static List<MarketBar> parseBars(Map<String, dynamic> payload) {
    final rawValues = payload['values'];
    if (rawValues is! List) {
      throw const MarketDataException('시세 데이터 목록이 응답에 없습니다.');
    }

    final bars = <MarketBar>[];
    for (final rawValue in rawValues) {
      if (rawValue is! Map) continue;

      final timeText = rawValue['datetime']?.toString();
      final open = _parseNumber(rawValue['open']);
      final high = _parseNumber(rawValue['high']);
      final low = _parseNumber(rawValue['low']);
      final close = _parseNumber(rawValue['close']);
      final volume = _parseNumber(rawValue['volume']) ?? 0;
      if (timeText == null || open == null || high == null || low == null || close == null) {
        continue;
      }

      final time = DateTime.tryParse(timeText.replaceFirst(' ', 'T'));
      if (time == null) continue;

      bars.add(
        MarketBar(
          time: time,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ),
      );
    }

    if (bars.length < 2) {
      throw const MarketDataException('차트를 그릴 수 있는 시세 데이터가 부족합니다.');
    }

    bars.sort((a, b) => a.time.compareTo(b.time));
    return List<MarketBar>.unmodifiable(bars);
  }

  static double? _parseNumber(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

/// Retained as a deterministic fixture for indicator unit tests only.
class DemoMarketDataSource {
  static const symbols = <MarketSymbol>[
    MarketSymbol(
      ticker: 'NEXON',
      name: '넥슨게임즈',
      exchange: 'KOSDAQ',
      basePrice: 18650,
      change: 3.42,
      providerSymbol: '225570',
      providerExchange: 'KRX',
    ),
    MarketSymbol(
      ticker: 'NAVER',
      name: 'NAVER',
      exchange: 'KOSPI',
      basePrice: 214500,
      change: 1.86,
      providerSymbol: '035420',
      providerExchange: 'KRX',
    ),
    MarketSymbol(
      ticker: 'SAMSUNG',
      name: '삼성전자',
      exchange: 'KOSPI',
      basePrice: 81200,
      change: -0.74,
      providerSymbol: '005930',
      providerExchange: 'KRX',
    ),
    MarketSymbol(
      ticker: 'NVDA',
      name: 'NVIDIA',
      exchange: 'NASDAQ',
      basePrice: 178.42,
      change: 2.15,
      providerSymbol: 'NVDA',
      providerExchange: 'NASDAQ',
    ),
  ];

  static MarketSymbol symbolFor(String ticker) => symbols.firstWhere(
        (symbol) => symbol.ticker == ticker,
        orElse: () => symbols.first,
      );

  static List<MarketBar> barsFor(String ticker, {int count = 180}) {
    final symbol = symbolFor(ticker);
    final seed = ticker.codeUnits.fold<int>(17, (value, code) => value + code);
    final volatility = symbol.basePrice > 1000 ? 0.012 : 0.018;
    final start = DateTime.utc(2025, 11, 3);
    var previousClose = symbol.basePrice * (1 - symbol.change / 100 * 0.55);

    return List<MarketBar>.generate(count, (index) {
      final cycle = math.sin((index + seed) / 8.5) * volatility;
      final slowCycle = math.cos((index + seed) / 24) * volatility * 1.8;
      final drift = (index / count) * volatility * 2.4;
      final pulse = math.sin((index + seed) * 1.73) * volatility * 0.32;
      final open = previousClose;
      final close = (open * (1 + cycle + slowCycle + drift / count + pulse))
          .clamp(symbol.basePrice * 0.72, symbol.basePrice * 1.48)
          .toDouble();
      final intraday = (math.sin(index * 2.2 + seed) + 2.3).abs();
      final high = (math.max(open, close).toDouble() *
              (1 + volatility * (0.45 + intraday * 0.18)))
          .toDouble();
      final low = (math.min(open, close).toDouble() *
              (1 - volatility * (0.45 + intraday * 0.15)))
          .toDouble();
      final volume = ((1000000 +
                  530000 * (1 + math.sin(index / 5 + seed)) +
                  (index % 17 == 0 ? 1800000 : 0)) *
              (symbol.basePrice > 1000 ? 0.62 : 1.0))
          .toDouble();
      previousClose = close;

      return MarketBar(
        time: start.add(Duration(days: index)),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );
    });
  }
}
