import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../landing/domain/entities/trading_view_market.dart';

class WatchlistPanel extends StatelessWidget {
  const WatchlistPanel({
    super.key,
    required this.markets,
    required this.selectedMarket,
    required this.onSelected,
    required this.onRemove,
    required this.onAdd,
  });

  final List<TradingViewMarket> markets;
  final TradingViewMarket selectedMarket;
  final ValueChanged<TradingViewMarket> onSelected;
  final ValueChanged<TradingViewMarket> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 8, 9),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'WATCHLIST',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '관심종목 추가',
                  onPressed: onAdd,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add, size: 18, color: AppColors.ink),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.builder(
              itemCount: markets.length,
              itemBuilder: (context, index) {
                final market = markets[index];
                final active = market.tradingViewSymbol ==
                    selectedMarket.tradingViewSymbol;
                return Material(
                  color: active ? const Color(0xffeefaf2) : Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelected(market),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 28,
                            color: active ? AppColors.green : AppColors.border,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  market.ticker,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  market.displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: '관심종목 제거',
                            onPressed: () => onRemove(market),
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CompactWatchlistBar extends StatelessWidget {
  const CompactWatchlistBar({
    super.key,
    required this.markets,
    required this.selectedMarket,
    required this.onSelected,
    required this.onAdd,
  });

  final List<TradingViewMarket> markets;
  final TradingViewMarket selectedMarket;
  final ValueChanged<TradingViewMarket> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: markets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final market = markets[index];
                final active = market.tradingViewSymbol ==
                    selectedMarket.tradingViewSymbol;
                return Material(
                  color: active ? AppColors.ink : Colors.white,
                  child: InkWell(
                    onTap: () => onSelected(market),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: active ? AppColors.ink : AppColors.border,
                        ),
                      ),
                      child: Text(
                        market.ticker,
                        style: TextStyle(
                          color: active ? Colors.white : AppColors.ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filled(
            tooltip: '관심종목 추가',
            onPressed: onAdd,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.ink,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: AppColors.border),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}
