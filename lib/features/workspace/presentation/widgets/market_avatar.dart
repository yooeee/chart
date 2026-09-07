import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../landing/domain/entities/trading_view_market.dart';

/// A typographic market marker; intentionally not an issuer logo.
class MarketAvatar extends StatelessWidget {
  const MarketAvatar({super.key, required this.market, this.size = 36});

  final TradingViewMarket market;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = switch (market.exchange) {
      'BINANCE' => const Color(0xff976310),
      'KRX' => const Color(0xff315cc3),
      'NASDAQ' => const Color(0xff7152b7),
      _ => AppColors.greenInk,
    };
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(size * .24),
          border: Border.all(color: color.withValues(alpha: .12)),
        ),
        child: Text(
          market.ticker.substring(0, 1),
          style: TextStyle(color: color, fontSize: size * .42, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
