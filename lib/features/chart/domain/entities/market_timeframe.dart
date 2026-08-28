class MarketTimeframe {
  const MarketTimeframe({
    required this.interval,
    required this.outputSize,
    required this.displayLabel,
  });

  final String interval;
  final int outputSize;
  final String displayLabel;

  static MarketTimeframe fromRange(String timeRange) {
    switch (timeRange) {
      case '1D':
        return const MarketTimeframe(
          interval: '15min',
          outputSize: 96,
          displayLabel: '15 min',
        );
      case '1W':
        return const MarketTimeframe(
          interval: '1h',
          outputSize: 120,
          displayLabel: '1 hour',
        );
      case '1M':
        return const MarketTimeframe(
          interval: '1day',
          outputSize: 31,
          displayLabel: 'Daily',
        );
      case '3M':
        return const MarketTimeframe(
          interval: '1day',
          outputSize: 93,
          displayLabel: 'Daily',
        );
      case '1Y':
        return const MarketTimeframe(
          interval: '1day',
          outputSize: 260,
          displayLabel: 'Daily',
        );
      default:
        return const MarketTimeframe(
          interval: '1day',
          outputSize: 180,
          displayLabel: 'Daily',
        );
    }
  }
}
