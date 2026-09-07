import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../landing/domain/entities/trading_view_market.dart';
import '../../domain/entities/workspace_models.dart';
import '../controllers/pulse_workspace_controller.dart';

class MarketIntelligencePage extends StatelessWidget {
  const MarketIntelligencePage({
    super.key,
    required this.controller,
    required this.onOpenMarket,
  });

  final PulseWorkspaceController controller;
  final ValueChanged<TradingViewMarket> onOpenMarket;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PageHeading(
              eyebrow: 'MARKET INTELLIGENCE',
              title: '시장 둘러보기',
              description: '주요 종목의 흐름과 경제 일정을 확인하세요.',
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: AppColors.ink,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.green,
                tabs: [
                  Tab(text: '시장 요약'),
                  Tab(text: '경제 캘린더'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  _MarketSummaryView(
                    data: controller.marketSummary,
                    onOpenMarket: onOpenMarket,
                  ),
                  _EconomicCalendarView(data: controller.economicCalendar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppColors.greenInk,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(color: AppColors.body, fontSize: 14),
        ),
      ],
    );
  }
}

class _MarketSummaryView extends StatelessWidget {
  const _MarketSummaryView({required this.data, required this.onOpenMarket});
  final MarketSummaryData data;
  final ValueChanged<TradingViewMarket> onOpenMarket;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final enlarged = MediaQuery.textScalerOf(context).scale(14) > 20;
    final columns = !enlarged && constraints.maxWidth >= 1180 ? 4
      : !enlarged && constraints.maxWidth >= 660 ? 2 : 1;
    final groups = <String, List<MarketSnapshot>>{
      '주요 지수': data.indices, '상승률 상위': data.gainers,
      '하락률 상위': data.losers, '주요 코인': data.crypto,
    };
    return ListView(children: [
      _DataSourceBanner(isDemo: data.isDemo, configured: data.configured, source: data.source),
      const SizedBox(height: 16),
      Wrap(spacing: 16, runSpacing: 16, children: [
        for (final group in groups.entries)
          SizedBox(
            width: (constraints.maxWidth - (columns - 1) * 16) / columns,
            child: _MarketGroupCard(title: group.key, items: group.value, onOpenMarket: onOpenMarket),
          ),
      ]),
    ]);
  });
}

class _DataSourceBanner extends StatelessWidget {
  const _DataSourceBanner({
    required this.isDemo,
    required this.configured,
    required this.source,
  });

  final bool isDemo;
  final bool configured;
  final String source;

  @override
  Widget build(BuildContext context) {
    final message = isDemo
        ? '샘플 데이터 · 현재 시세와 다릅니다.'
        : configured
            ? '$source 데이터에 연결되어 있습니다.'
            : '현재 시장 데이터를 불러올 수 없습니다.';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      color: isDemo ? const Color(0xfffff7df) : const Color(0xffeefaf2),
      child: Row(
        children: [
          Icon(
            isDemo ? Icons.science_outlined : Icons.cloud_done_outlined,
            size: 17,
            color: isDemo ? const Color(0xffa56b00) : AppColors.green,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketGroupCard extends StatelessWidget {
  const _MarketGroupCard({required this.title, required this.items, required this.onOpenMarket});
  final String title;
  final List<MarketSnapshot> items;
  final ValueChanged<TradingViewMarket> onOpenMarket;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(title, style: const TextStyle(color: AppColors.ink, fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      const Divider(height: 1),
      for (final item in items)
        _MarketSnapshotRow(
          item: item,
          onTap: TradingViewMarket.markets.any((market) => market.tradingViewSymbol == item.symbol)
            ? () => onOpenMarket(TradingViewMarket.findBySymbol(item.symbol)) : null,
        ),
      if (items.isEmpty)
        const Padding(padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('표시할 데이터가 없습니다.', style: TextStyle(color: AppColors.muted, fontSize: 14))),
    ]),
  );
}

class _MarketSnapshotRow extends StatelessWidget {
  const _MarketSnapshotRow({required this.item, required this.onTap});
  final MarketSnapshot item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final up = item.changePercent >= 0;
    final color = up ? AppColors.greenInk : AppColors.chartDown;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(item.name, style: const TextStyle(color: AppColors.label, fontSize: 14, fontWeight: FontWeight.w600))),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.muted),
          ]),
          const SizedBox(height: 9),
          Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 8, children: [
            Text(item.price.toStringAsFixed(item.price >= 1000 ? 0 : 2),
              style: const TextStyle(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -.4)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: color.withValues(alpha: .08), borderRadius: BorderRadius.circular(5)),
              child: Text('${up ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _EconomicCalendarView extends StatelessWidget {
  const _EconomicCalendarView({required this.data});

  final EconomicCalendarData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _DataSourceBanner(
          isDemo: data.isDemo,
          configured: data.configured,
          source: data.source,
        ),
        const SizedBox(height: 12),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              for (var index = 0; index < data.events.length; index++) ...[
                _EconomicEventRow(event: data.events[index]),
                if (index != data.events.length - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
              if (data.events.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '등록된 경제 일정이 없습니다.',
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EconomicEventRow extends StatelessWidget {
  const _EconomicEventRow({required this.event});
  final EconomicCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final local = event.scheduledAt.toLocal();
    final date = '${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')}';
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final importance = switch (event.importance) {'high' => '중요도 높음', 'medium' => '중요도 보통', _ => '중요도 낮음'};
    final color = event.importance == 'high' ? AppColors.chartDown : AppColors.body;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 14, runSpacing: 6, children: [
          Text('$date  $time', style: const TextStyle(color: AppColors.body, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(event.country, style: const TextStyle(color: AppColors.label, fontSize: 12, fontWeight: FontWeight.w700)),
          Text(importance, style: TextStyle(color: color, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        Text(event.title, style: const TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w700)),
        if (event.forecast != null) ...[
          const SizedBox(height: 8),
          Text('예상 ${event.forecast}', style: const TextStyle(color: AppColors.body, fontSize: 14)),
        ],
      ]),
    );
  }
}
