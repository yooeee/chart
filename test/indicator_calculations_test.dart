import 'package:flutter_test/flutter_test.dart';

import 'package:pulse_chart/indicators/indicator_calculations.dart';
import 'package:pulse_chart/models/market_data.dart';

void main() {
  test('demo bars keep valid OHLC relationships', () {
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
