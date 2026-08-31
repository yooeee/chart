import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../chart/presentation/widgets/tradingview_chart.dart';
import '../../../landing/domain/entities/trading_view_market.dart';
import '../../domain/entities/workspace_models.dart';

class FullScreenChartPage extends StatelessWidget {
  const FullScreenChartPage({
    super.key,
    required this.market,
    required this.interval,
    required this.theme,
  });

  final TradingViewMarket market;
  final String interval;
  final ChartThemePreference theme;

  @override
  Widget build(BuildContext context) {
    final dark = theme == ChartThemePreference.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xff111318) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: dark ? const Color(0xff171a21) : Colors.white,
              child: Row(
                children: [
                  IconButton(
                    tooltip: '전체화면 닫기',
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_fullscreen_rounded,
                      size: 19,
                      color: dark ? Colors.white : AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    market.ticker,
                    style: TextStyle(
                      color: dark ? Colors.white : AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$interval · ${market.exchange}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                  const Spacer(),
                  const Text(
                    'FULL SCREEN CHART',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TradingViewChart(
                key: ValueKey('${market.tradingViewSymbol}-$interval-${theme.name}-fullscreen'),
                symbol: market.tradingViewSymbol,
                interval: interval,
                theme: theme.name,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
