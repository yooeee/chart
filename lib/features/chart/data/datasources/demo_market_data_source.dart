import 'dart:math' as math;

import '../../domain/entities/market_bar.dart';
import '../../domain/entities/market_symbol_catalog.dart';

/// Deterministic fixture data used by indicator tests and local previews.
abstract final class DemoMarketDataSource {
  static const _referencePriceByTicker = <String, double>{
    'NEXON': 18650,
    'NAVER': 214500,
    'SAMSUNG': 81200,
    'NVDA': 178.42,
  };

  static const _referenceChangePercentByTicker = <String, double>{
    'NEXON': 3.42,
    'NAVER': 1.86,
    'SAMSUNG': -0.74,
    'NVDA': 2.15,
  };

  static List<MarketBar> generateMarketBars(
    String ticker, {
    int count = 180,
  }) {
    final referencePrice = _referencePriceByTicker[ticker] ?? 1000;
    final referenceChangePercent =
        _referenceChangePercentByTicker[ticker] ?? 0;
    final seed = ticker.codeUnits.fold<int>(
      17,
      (value, codeUnit) => value + codeUnit,
    );
    final volatility = referencePrice > 1000 ? 0.012 : 0.018;
    final startTimestamp = DateTime.utc(2025, 11, 3);
    var previousClose =
        referencePrice * (1 - referenceChangePercent / 100 * 0.55);

    return List<MarketBar>.generate(count, (index) {
      final cycle = math.sin((index + seed) / 8.5) * volatility;
      final slowCycle = math.cos((index + seed) / 24) * volatility * 1.8;
      final drift = (index / count) * volatility * 2.4;
      final pulse = math.sin((index + seed) * 1.73) * volatility * 0.32;
      final open = previousClose;
      final close = (open *
              (1 + cycle + slowCycle + drift / count + pulse))
          .clamp(referencePrice * 0.72, referencePrice * 1.48)
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
              (referencePrice > 1000 ? 0.62 : 1.0))
          .toDouble();
      previousClose = close;

      return MarketBar(
        timestamp: startTimestamp.add(Duration(days: index)),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );
    });
  }
}
