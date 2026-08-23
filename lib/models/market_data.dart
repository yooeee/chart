import 'dart:math' as math;

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
  });

  final String ticker;
  final String name;
  final String exchange;
  final double basePrice;
  final double change;
}

class DemoMarketDataSource {
  static const symbols = <MarketSymbol>[
    MarketSymbol(
      ticker: 'NEXON',
      name: '넥슨게임즈',
      exchange: 'KOSDAQ',
      basePrice: 18_650,
      change: 3.42,
    ),
    MarketSymbol(
      ticker: 'NAVER',
      name: 'NAVER',
      exchange: 'KOSPI',
      basePrice: 214_500,
      change: 1.86,
    ),
    MarketSymbol(
      ticker: 'SAMSUNG',
      name: '삼성전자',
      exchange: 'KOSPI',
      basePrice: 81_200,
      change: -0.74,
    ),
    MarketSymbol(
      ticker: 'NVDA',
      name: 'NVIDIA',
      exchange: 'NASDAQ',
      basePrice: 178.42,
      change: 2.15,
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
      final high = math.max(open, close).toDouble() *
          (1 + volatility * (0.45 + intraday * 0.18));
      final low = math.min(open, close).toDouble() *
          (1 - volatility * (0.45 + intraday * 0.15));
      final volume = (1_000_000 +
              530_000 * (1 + math.sin(index / 5 + seed)) +
              (index % 17 == 0 ? 1_800_000 : 0)) *
          (symbol.basePrice > 1000 ? 0.62 : 1.0).toDouble();
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
