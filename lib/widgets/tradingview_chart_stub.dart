import 'package:flutter/material.dart';

/// Native fallback for the web-only TradingView embed.
///
/// The GitHub Pages build uses [tradingview_chart_web.dart]. Keeping this
/// fallback makes the shared Flutter source compile for iOS and Android while
/// the native TradingView container is added in a later mobile pass.
class TradingViewChart extends StatelessWidget {
  const TradingViewChart({
    super.key,
    required this.symbol,
    this.interval = 'D',
  });

  final String symbol;
  final String interval;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'TradingView 위젯은 Web에서 표시됩니다.\n$symbol · $interval',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xff737881), fontSize: 12),
      ),
    );
  }
}
