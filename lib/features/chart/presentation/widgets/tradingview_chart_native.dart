import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// TradingView chart container for Android and iOS.
///
/// Web uses the platform-view implementation in
/// [tradingview_chart_web.dart]. Mobile platforms load the same TradingView
/// Advanced Chart widget inside the system WebView.
class TradingViewChart extends StatefulWidget {
  const TradingViewChart({
    super.key,
    required this.symbol,
    this.interval = 'D',
    this.theme = 'light',
    this.showMarketPanels = false,
  });

  final String symbol;
  final String interval;
  final String theme;
  final bool showMarketPanels;

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
        ),
      );
    _loadChart();
  }

  @override
  void didUpdateWidget(covariant TradingViewChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol ||
        oldWidget.interval != widget.interval ||
        oldWidget.theme != widget.theme ||
        oldWidget.showMarketPanels != widget.showMarketPanels) {
      _isLoading = true;
      _loadChart();
    }
  }

  void _loadChart() {
    _controller.loadHtmlString(
      _tradingViewDocument(
        symbol: widget.symbol,
        interval: widget.interval,
        theme: widget.theme,
        showMarketPanels: widget.showMarketPanels,
      ),
      baseUrl: 'https://www.tradingview.com/',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const ColoredBox(
            color: widget.theme == 'dark'
                ? const Color(0xff111318)
                : Colors.white,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

String _tradingViewDocument({
  required String symbol,
  required String interval,
  required String theme,
  required bool showMarketPanels,
}) {
  final config = jsonEncode(<String, Object>{
    'autosize': true,
    'symbol': symbol,
    'interval': interval,
    'timezone': 'Asia/Seoul',
    'theme': theme,
    'style': '1',
    'locale': 'ko',
    'withdateranges': true,
    'hide_side_toolbar': false,
    'allow_symbol_change': true,
    'save_image': false,
    'calendar': showMarketPanels,
    'details': showMarketPanels,
    'hotlist': showMarketPanels,
    'support_host': 'https://www.tradingview.com',
  });

  return '''
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8">
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, maximum-scale=1"
    >
    <style>
      html, body {
        width: 100%;
        height: 100%;
        margin: 0;
        overflow: hidden;
        background: ${theme == 'dark' ? '#111318' : '#ffffff'};
      }

      .tradingview-widget-container {
        width: 100%;
        height: 100%;
      }

      .tradingview-widget-container__widget {
        width: 100%;
        height: calc(100% - 28px);
      }

      .tradingview-widget-copyright {
        height: 28px;
        display: flex;
        align-items: center;
        font: 11px Arial, sans-serif;
      }

      .tradingview-widget-copyright a {
        color: #737881;
        text-decoration: none;
      }
    </style>
  </head>
  <body>
    <div class="tradingview-widget-container">
      <div class="tradingview-widget-container__widget"></div>
      <div class="tradingview-widget-copyright">
        <a href="https://www.tradingview.com/" target="_blank" rel="noopener">
          Chart by TradingView
        </a>
      </div>
    </div>
    <script
      type="text/javascript"
      src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js"
      async
    >$config</script>
  </body>
</html>
''';
}
