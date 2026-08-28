import 'dart:convert';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// TradingView's free Advanced Chart widget embedded as a Flutter Web
/// platform view. The widget loads the market feed in the browser, so no
/// market-data API key is bundled into the Flutter application.
class TradingViewChart extends StatefulWidget {
  const TradingViewChart({
    super.key,
    required this.symbol,
    this.interval = 'D',
  });

  final String symbol;
  final String interval;

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  static int _nextViewId = 0;

  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'tradingview-advanced-chart-${_nextViewId++}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final container = web.HTMLDivElement()
        ..className = 'tradingview-widget-container'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#ffffff';

      final chart = web.HTMLDivElement()
        ..className = 'tradingview-widget-container__widget'
        ..style.width = '100%'
        ..style.height = 'calc(100% - 28px)';

      final copyright = web.HTMLDivElement()
        ..className = 'tradingview-widget-copyright'
        ..style.height = '28px'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.fontSize = '11px'
        ..style.color = '#737881';

      final link = web.HTMLAnchorElement()
        ..href = 'https://www.tradingview.com/'
        ..target = '_blank'
        ..rel = 'noopener nofollow'
        ..text = 'Chart by TradingView';
      copyright.append(link);

      final script = web.HTMLScriptElement()
        ..type = 'text/javascript'
        ..src = 'https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js'
        ..async = true
        ..text = jsonEncode(<String, Object>{
          'autosize': true,
          'symbol': widget.symbol,
          'interval': widget.interval,
          'timezone': 'Asia/Seoul',
          'theme': 'light',
          'style': '1',
          'locale': 'ko',
          'withdateranges': true,
          'hide_side_toolbar': false,
          'allow_symbol_change': true,
          'save_image': false,
          'calendar': false,
          'support_host': 'https://www.tradingview.com',
        });

      container.append(chart);
      container.append(copyright);
      container.append(script);
      return container;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
