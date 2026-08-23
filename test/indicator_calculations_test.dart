import 'package:flutter_test/flutter_test.dart';

import 'package:pulse_chart/indicators/indicator_calculations.dart';
import 'package:pulse_chart/models/market_data.dart';

void main() {
  test('fixture bars keep valid OHLC relationships', () {
    final bars = DemoMarketDataSource.barsFor('NEXON');

    expect(bars, hasLength(180));
    for (final bar in bars) {
      expect(bar.high, greaterThanOrEqualTo(bar.open));
      expect(bar.high, greaterThanOrEqualTo(bar.close));
      expect(bar.low, lessThanOrEqualTo(bar.open));
      expect(bar.low, lessThanOrEqualTo(bar.close));
      expect(bar.volume, greaterThan(0));
    }
  });

  test('Twelve Data values are parsed in ascending time order', () {
    final bars = TwelveDataMarketDataSource.parseBars({
      'status': 'ok',
      'values': [
        {
          'datetime': '2026-08-24 10:00:00',
          'open': '102.0',
          'high': '105.0',
          'low': '101.0',
          'close': '104.0',
          'volume': '1200',
        },
        {
          'datetime': '2026-08-24 09:00:00',
          'open': '100.0',
          'high': '103.0',
          'low': '99.0',
          'close': '102.0',
          'volume': '900',
        },
      ],
    });

    expect(bars, hasLength(2));
    expect(bars.first.close, 102);
    expect(bars.last.close, 104);
    expect(bars.first.time.isBefore(bars.last.time), isTrue);
  });

  test('RSI is bounded between zero and one hundred', () {
    final values = List<double>.generate(80, (index) => 100 + index * 0.35);
    final rsi = IndicatorCalculator.rsi(values, 14).whereType<double>();

    expect(rsi, isNotEmpty);
    expect(rsi.every((value) => value >= 0 && value <= 100), isTrue);
  });

  test('MACD returns aligned series', () {
    final bars = DemoMarketDataSource.barsFor('NAVER');
    final closes = bars.map((bar) => bar.close).toList();
    final macd = IndicatorCalculator.macd(closes);

    expect(macd.primary, hasLength(closes.length));
    expect(macd.secondary, hasLength(closes.length));
    expect(macd.tertiary, hasLength(closes.length));
  });
}
