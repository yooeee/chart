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
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PageHeading(
              eyebrow: 'MARKET INTELLIGENCE',
              title: '오늘의 시장을 한 화면에서 확인하세요',
              description: '주요 지수·상승률·하락률·코인과 경제 일정을 분리해 제공합니다.',
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
            color: AppColors.green,
            fontSize: 10,
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
          style: const TextStyle(color: AppColors.body, fontSize: 12),
        ),
      ],
    );
  }
}

class _MarketSummaryView extends StatelessWidget {
  const _MarketSummaryView({
    required this.data,
    required this.onOpenMarket,
  });

  final MarketSummaryData data;
  final ValueChanged<TradingViewMarket> onOpenMarket;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        return ListView(
          children: [
            _DataSourceBanner(
              isDemo: data.isDemo,
              configured: data.configured,
              source: data.source,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 2.5 : 1.45,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MarketGroupCard(
                  title: '주요 지수',
                  items: data.indices,
                  onOpenMarket: onOpenMarket,
                ),
                _MarketGroupCard(
                  title: '상승률 상위',
                  items: data.gainers,
                  onOpenMarket: onOpenMarket,
                ),
                _MarketGroupCard(
                  title: '하락률 상위',
                  items: data.losers,
                  onOpenMarket: onOpenMarket,
                ),
                _MarketGroupCard(
                  title: '주요 코인',
                  items: data.crypto,
                  onOpenMarket: onOpenMarket,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
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
        ? '현재 샘플 데이터입니다. 실제 배포 전 시세 API 공급자를 연결하세요.'
        : configured
            ? '$source 데이터에 연결되어 있습니다.'
            : '시세 API 공급자가 설정되지 않았습니다.';
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
                fontSize: 11,
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
  const _MarketGroupCard({
    required this.title,
    required this.items,
    required this.onOpenMarket,
  });

  final String title;
  final List<MarketSnapshot> items;
  final ValueChanged<TradingViewMarket> onOpenMarket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Expanded(
              child: _MarketSnapshotRow(
                item: item,
                onTap: () {
                  final matches = TradingViewMarket.markets
                      .where((market) => market.tradingViewSymbol == item.symbol);
                  if (matches.isNotEmpty) onOpenMarket(matches.first);
                },
              ),
            ),
          if (items.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  '데이터 없음',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MarketSnapshotRow extends StatelessWidget {
  const _MarketSnapshotRow({required this.item, required this.onTap});

  final MarketSnapshot item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final up = item.changePercent >= 0;
    final changeColor = up ? const Color(0xff009944) : AppColors.chartDown;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.price.toStringAsFixed(item.price >= 1000 ? 0 : 2),
                  style: const TextStyle(color: AppColors.body, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            '${up ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
            style: TextStyle(
              color: changeColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right, size: 15, color: AppColors.muted),
        ],
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
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
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
    final dateText =
        '${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final importanceColor = switch (event.importance) {
      'high' => AppColors.chartDown,
      'medium' => const Color(0xffffb020),
      _ => AppColors.muted,
    };
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              dateText,
              style: const TextStyle(
                color: AppColors.body,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(width: 4, height: 32, color: importanceColor),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 24,
            alignment: Alignment.center,
            color: const Color(0xfff2f4f5),
            child: Text(
              event.country,
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event.title,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (event.forecast != null)
            Text(
              '예상 ${event.forecast}',
              style: const TextStyle(color: AppColors.body, fontSize: 10),
            ),
        ],
      ),
    );
  }
}
