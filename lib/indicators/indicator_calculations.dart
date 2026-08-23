import '../models/market_data.dart';

class IndicatorData {
  const IndicatorData({
    required this.primary,
    this.secondary = const <double?>[],
    this.tertiary = const <double?>[],
  });

  final List<double?> primary;
  final List<double?> secondary;
  final List<double?> tertiary;
}

class BollingerData {
  const BollingerData({required this.middle, required this.upper, required this.lower});

  final List<double?> middle;
  final List<double?> upper;
  final List<double?> lower;
}

class IndicatorCalculator {
  static List<double?> closes(List<MarketBar> bars) =>
      bars.map((bar) => bar.close).toList(growable: false);

  static List<double?> ema(List<double> values, int period) {
    final output = List<double?>.filled(values.length, null);
    if (values.isEmpty || period < 1) return output;
    final multiplier = 2 / (period + 1);
    var previous = values.first;
    output[0] = previous;
    for (var index = 1; index < values.length; index++) {
      previous = (values[index] - previous) * multiplier + previous;
      output[index] = previous;
    }
    return output;
  }

  static List<double?> sma(List<double> values, int period) {
    final output = List<double?>.filled(values.length, null);
    if (period < 1) return output;
    var sum = 0.0;
    for (var index = 0; index < values.length; index++) {
      sum += values[index];
      if (index >= period) sum -= values[index - period];
      if (index >= period - 1) output[index] = sum / period;
    }
    return output;
  }

  static List<double?> rsi(List<double> values, int period) {
    final result = List<double?>.filled(values.length, null);
    if (values.length <= period) return result;
    var gain = 0.0;
    var loss = 0.0;
    for (var index = 1; index <= period; index++) {
      final delta = values[index] - values[index - 1];
      if (delta >= 0) {
        gain += delta;
      } else {
        loss -= delta;
      }
    }
    var averageGain = gain / period;
    var averageLoss = loss / period;
    result[period] = _rsiValue(averageGain, averageLoss);
    for (var index = period + 1; index < values.length; index++) {
      final delta = values[index] - values[index - 1];
      final currentGain = delta > 0 ? delta : 0.0;
      final currentLoss = delta < 0 ? -delta : 0.0;
      averageGain = (averageGain * (period - 1) + currentGain) / period;
      averageLoss = (averageLoss * (period - 1) + currentLoss) / period;
      result[index] = _rsiValue(averageGain, averageLoss);
    }
    return result;
  }

  static double _rsiValue(double gain, double loss) {
    if (loss == 0) return 100;
    if (gain == 0) return 0;
    return 100 - 100 / (1 + gain / loss);
  }

  static IndicatorData macd(List<double> values) {
    final fast = ema(values, 12);
    final slow = ema(values, 26);
    final line = List<double?>.generate(
      values.length,
      (index) => fast[index] == null || slow[index] == null
          ? null
          : fast[index]! - slow[index]!,
    );
    final signal = ema(line.map((value) => value ?? 0).toList(), 9);
    final histogram = List<double?>.generate(
      values.length,
      (index) => line[index] == null || signal[index] == null
          ? null
          : line[index]! - signal[index]!,
    );
    return IndicatorData(primary: line, secondary: signal, tertiary: histogram);
  }

  static BollingerData bollinger(List<double> values, int period, double multiplier) {
    final middle = sma(values, period);
    final upper = List<double?>.filled(values.length, null);
    final lower = List<double?>.filled(values.length, null);
    for (var index = period - 1; index < values.length; index++) {
      final mean = middle[index];
      if (mean == null) continue;
      var variance = 0.0;
      for (var offset = 0; offset < period; offset++) {
        final difference = values[index - offset] - mean;
        variance += difference * difference;
      }
      final deviation = (variance / period).sqrt();
      upper[index] = mean + deviation * multiplier;
      lower[index] = mean - deviation * multiplier;
    }
    return BollingerData(middle: middle, upper: upper, lower: lower);
  }

  static List<double?> volumePressure(List<MarketBar> bars) {
    final output = List<double?>.filled(bars.length, null);
    const period = 14;
    for (var index = period - 1; index < bars.length; index++) {
      var pressure = 0.0;
      var volume = 0.0;
      for (var offset = 0; offset < period; offset++) {
        final bar = bars[index - offset];
        final range = bar.high - bar.low;
        pressure += range == 0 ? 0 : (bar.close - bar.open) / range * bar.volume;
        volume += bar.volume;
      }
      output[index] = volume == 0 ? 0 : (pressure / volume * 100).clamp(-100, 100).toDouble();
    }
    return output;
  }

  static IndicatorData smartFlow(List<MarketBar> bars) {
    final flow = List<double?>.filled(bars.length, null);
    final volumeZ = List<double?>.filled(bars.length, null);
    const period = 20;
    for (var index = period - 1; index < bars.length; index++) {
      var signedVolume = 0.0;
      var totalVolume = 0.0;
      var meanVolume = 0.0;
      for (var offset = 0; offset < period; offset++) {
        final bar = bars[index - offset];
        signedVolume += (bar.close >= bar.open ? 1 : -1) * bar.volume;
        totalVolume += bar.volume;
        meanVolume += bar.volume;
      }
      meanVolume /= period;
      var variance = 0.0;
      for (var offset = 0; offset < period; offset++) {
        final difference = bars[index - offset].volume - meanVolume;
        variance += difference * difference;
      }
      final deviation = (variance / period).sqrt();
      flow[index] = totalVolume == 0 ? 0 : signedVolume / totalVolume * 100;
      volumeZ[index] = deviation == 0
          ? 0
          : ((bars[index].volume - meanVolume) / deviation).clamp(-3, 3).toDouble();
    }
    return IndicatorData(primary: flow, secondary: volumeZ);
  }
}

extension on double {
  double sqrt() => this < 0 ? 0 : _sqrt(this);
}

double _sqrt(double value) {
  var guess = value == 0 ? 0.0 : value;
  if (guess == 0) return 0;
  for (var index = 0; index < 12; index++) {
    guess = (guess + value / guess) / 2;
  }
  return guess;
}
