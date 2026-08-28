import '../../domain/entities/market_bar.dart';

class MarketBarModel {
  const MarketBarModel({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  MarketBar toEntity() {
    return MarketBar(
      timestamp: timestamp,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }

  static MarketBarModel? tryParse(Map<String, dynamic> rawData) {
    final timestampText = rawData['datetime']?.toString();
    final open = _parseNumber(rawData['open']);
    final high = _parseNumber(rawData['high']);
    final low = _parseNumber(rawData['low']);
    final close = _parseNumber(rawData['close']);
    final volume = _parseNumber(rawData['volume']) ?? 0;

    if (timestampText == null ||
        open == null ||
        high == null ||
        low == null ||
        close == null) {
      return null;
    }

    final timestamp = DateTime.tryParse(
      timestampText.replaceFirst(' ', 'T'),
    );
    if (timestamp == null) return null;

    return MarketBarModel(
      timestamp: timestamp,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }

  static double? _parseNumber(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
