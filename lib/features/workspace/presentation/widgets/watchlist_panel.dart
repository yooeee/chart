import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../landing/domain/entities/trading_view_market.dart';
import 'market_avatar.dart';

class WatchlistPanel extends StatelessWidget {
  const WatchlistPanel({
    super.key, required this.markets, required this.selectedMarket,
    required this.onSelected, required this.onRemove, required this.onAdd,
  });
  final List<TradingViewMarket> markets;
  final TradingViewMarket selectedMarket;
  final ValueChanged<TradingViewMarket> onSelected;
  final ValueChanged<TradingViewMarket> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
    width: 264,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: Colors.white,
      border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
        child: Row(children: [
          const Expanded(child: Text('관심종목', style: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w700))),
          Text('${markets.length}', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          const SizedBox(width: 4),
          IconButton(tooltip: '관심종목 추가', onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 21, color: AppColors.ink)),
        ]),
      ),
      const Divider(height: 1),
      Expanded(
        child: markets.isEmpty
          ? Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_border_rounded, color: AppColors.muted, size: 32),
                const SizedBox(height: 12),
                const Text('자주 보는 종목을 모아보세요.', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.body, fontSize: 14, height: 1.6)),
                const SizedBox(height: 12),
                TextButton(onPressed: onAdd, child: const Text('종목 추가')),
              ]),
            ))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: markets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final market = markets[index];
                final active = market.tradingViewSymbol == selectedMarket.tradingViewSymbol;
                return Semantics(
                  selected: active,
                  child: Material(
                    color: active ? AppColors.greenWash : Colors.white,
                    child: InkWell(
                      onTap: () => onSelected(market),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                        decoration: BoxDecoration(border: Border(
                          left: BorderSide(color: active ? AppColors.greenInk : Colors.transparent, width: 3))),
                        child: Row(children: [
                          MarketAvatar(market: market),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(market.displayName, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 5),
                            Text('${market.exchange} · ${market.tradingViewSymbol.split(':').last}',
                              overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.body, fontSize: 12)),
                          ])),
                          IconButton(
                            tooltip: '관심종목에서 제거', onPressed: () => onRemove(market),
                            icon: const Icon(Icons.star_rounded, size: 18, color: AppColors.greenInk),
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
      const Divider(height: 1),
      const Padding(
        padding: EdgeInsets.all(18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.bookmark_border_rounded, size: 16, color: AppColors.muted),
          SizedBox(width: 8),
          Expanded(child: Text('관심종목과 차트 설정은 이 기기에 저장됩니다.',
            style: TextStyle(color: AppColors.body, fontSize: 12, height: 1.6))),
        ]),
      ),
    ]),
  );
}

class CompactWatchlistBar extends StatelessWidget {
  const CompactWatchlistBar({
    super.key, required this.markets, required this.selectedMarket,
    required this.onSelected, required this.onAdd,
  });
  final List<TradingViewMarket> markets;
  final TradingViewMarket selectedMarket;
  final ValueChanged<TradingViewMarket> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48 + (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(0, 56).toDouble(),
    child: Row(children: [
      Expanded(child: markets.isEmpty
        ? const Text('관심종목을 추가해 보세요.', style: TextStyle(color: AppColors.body, fontSize: 14))
        : ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: markets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final market = markets[index];
            final active = market.tradingViewSymbol == selectedMarket.tradingViewSymbol;
            return Semantics(
              selected: active, button: true,
              child: Material(
                color: active ? AppColors.ink : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: active ? AppColors.ink : AppColors.border)),
                child: InkWell(
                  onTap: () => onSelected(market), borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(child: Text(market.displayName,
                      style: TextStyle(color: active ? Colors.white : AppColors.label, fontSize: 14, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(width: 8),
      IconButton.filled(
        tooltip: '관심종목 추가', onPressed: onAdd,
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44), backgroundColor: Colors.white, foregroundColor: AppColors.ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.border)),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
      ),
    ]),
  );
}
