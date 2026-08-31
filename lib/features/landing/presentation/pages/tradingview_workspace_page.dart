import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/trading_view_market.dart';
import '../../../chart/presentation/widgets/tradingview_chart.dart';
import '../../../workspace/domain/entities/workspace_models.dart';
import '../../../workspace/presentation/controllers/pulse_workspace_controller.dart';
import '../../../workspace/presentation/pages/alerts_page.dart';
import '../../../workspace/presentation/pages/full_screen_chart_page.dart';
import '../../../workspace/presentation/pages/indicator_guide_page.dart';
import '../../../workspace/presentation/pages/market_intelligence_page.dart';
import '../../../workspace/presentation/widgets/account_panel.dart';
import '../../../workspace/presentation/widgets/watchlist_panel.dart';

enum _WorkspaceSection { introduction, chart, market, indicators, alerts }

class TradingViewWorkspacePage extends StatefulWidget {
  const TradingViewWorkspacePage({super.key});

  @override
  State<TradingViewWorkspacePage> createState() => _TradingViewWorkspacePageState();
}

class _TradingViewWorkspacePageState extends State<TradingViewWorkspacePage> {
  late final PulseWorkspaceController _workspaceController;
  _WorkspaceSection _activeSection = _WorkspaceSection.introduction;

  @override
  void initState() {
    super.initState();
    _workspaceController = PulseWorkspaceController()..initialize();
  }

  @override
  void dispose() {
    _workspaceController.dispose();
    super.dispose();
  }

  void _selectMarket(TradingViewMarket market) {
    _workspaceController.selectMarket(market);
  }

  void _showIntroduction() {
    setState(() => _activeSection = _WorkspaceSection.introduction);
  }

  void _showChart() {
    setState(() => _activeSection = _WorkspaceSection.chart);
  }

  void _openMarketFromSummary(TradingViewMarket market) {
    _workspaceController.selectMarket(market);
    _showChart();
  }

  void _showAccountPanel() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (context) => AnimatedBuilder(
        animation: _workspaceController,
        builder: (context, _) => AccountPanel(
          controller: _workspaceController,
        ),
      ),
    );
  }

  void _showStatusMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _workspaceController,
      builder: (context, _) {
        final statusMessage = _workspaceController.takeStatusMessage();
        if (statusMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showStatusMessage(statusMessage);
          });
        }
        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: SafeArea(
            child: Column(
              children: [
                _TradingViewTopNavigation(
                  activeSection: _activeSection,
                  account: _workspaceController.account,
                  unreadNotificationCount:
                      _workspaceController.unreadNotificationCount,
                  onSectionSelected: (section) {
                    setState(() => _activeSection = section);
                    if (section == _WorkspaceSection.alerts) {
                      _workspaceController.markAllNotificationsRead();
                    }
                  },
                  onAccountSelected: _showAccountPanel,
                ),
                Expanded(
                  child: !_workspaceController.initialized
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : switch (_activeSection) {
                          _WorkspaceSection.introduction =>
                            _TradingViewIntroductionPage(
                              onOpenChart: _showChart,
                            ),
                          _WorkspaceSection.chart => _TradingViewChartPage(
                              controller: _workspaceController,
                              onMarketChanged: _selectMarket,
                            ),
                          _WorkspaceSection.market => MarketIntelligencePage(
                              controller: _workspaceController,
                              onOpenMarket: _openMarketFromSummary,
                            ),
                          _WorkspaceSection.indicators => IndicatorGuidePage(
                              controller: _workspaceController,
                            ),
                          _WorkspaceSection.alerts => AlertsPage(
                              controller: _workspaceController,
                            ),
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TradingViewChartPage extends StatelessWidget {
  const _TradingViewChartPage({
    required this.controller,
    required this.onMarketChanged,
  });

  final PulseWorkspaceController controller;
  final ValueChanged<TradingViewMarket> onMarketChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final showSideWatchlist = constraints.maxWidth >= 980;
        final market = controller.selectedMarket;
        final chartContent = Column(
          children: [
            _TradingViewWorkspaceHeader(
              market: market,
              onMarketChanged: onMarketChanged,
            ),
            if (!compact) ...[
              const SizedBox(height: 12),
              _TradingViewMarketStrip(market: market),
              const SizedBox(height: 12),
            ] else
              const SizedBox(height: 6),
            _TradingViewIndicatorToolbar(
              selectedIndicatorIds: controller.activeIndicators,
              onSelected: controller.toggleIndicator,
            ),
            SizedBox(height: compact ? 6 : 14),
            Expanded(
              child: _TradingViewChartCard(
                market: market,
                interval: controller.interval,
                theme: controller.chartTheme,
                onIntervalChanged: controller.setInterval,
                onThemeChanged: controller.toggleChartTheme,
                onFullScreen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FullScreenChartPage(
                      market: market,
                      interval: controller.interval,
                      theme: controller.chartTheme,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 12 : 24,
            compact ? 12 : 20,
            compact ? 12 : 24,
            compact ? 16 : 24,
          ),
          child: showSideWatchlist
              ? Row(
                  children: [
                    WatchlistPanel(
                      markets: controller.watchlistMarkets,
                      selectedMarket: market,
                      onSelected: onMarketChanged,
                      onRemove: controller.toggleWatchlist,
                      onAdd: () => _showMarketPicker(context),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: chartContent),
                  ],
                )
              : Column(
                  children: [
                    CompactWatchlistBar(
                      markets: controller.watchlistMarkets,
                      selectedMarket: market,
                      onSelected: onMarketChanged,
                      onAdd: () => _showMarketPicker(context),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: chartContent),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _showMarketPicker(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('관심종목 관리'),
        content: SizedBox(
          width: 420,
          height: 440,
          child: ListView.separated(
            itemCount: TradingViewMarket.markets.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final market = TradingViewMarket.markets[index];
              final saved = controller.isInWatchlist(market);
              return ListTile(
                onTap: () async {
                  if (!saved) await controller.toggleWatchlist(market);
                  onMarketChanged(market);
                  if (context.mounted) Navigator.pop(context);
                },
                title: Text(
                  market.displayName,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${market.exchange} · ${market.tradingViewSymbol}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 9),
                ),
                trailing: IconButton(
                  onPressed: () => controller.toggleWatchlist(market),
                  icon: Icon(
                    saved ? Icons.star_rounded : Icons.star_border_rounded,
                    color: saved ? AppColors.green : AppColors.muted,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

class _TradingViewTopNavigation extends StatelessWidget {
  const _TradingViewTopNavigation({
    required this.activeSection,
    required this.account,
    required this.unreadNotificationCount,
    required this.onSectionSelected,
    required this.onAccountSelected,
  });

  final _WorkspaceSection activeSection;
  final PulseAccount? account;
  final int unreadNotificationCount;
  final ValueChanged<_WorkspaceSection> onSectionSelected;
  final VoidCallback onAccountSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;
          return Row(
            children: [
              if (compact)
                PopupMenuButton<_WorkspaceSection>(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
                  onSelected: onSectionSelected,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _WorkspaceSection.introduction,
                      child: Text('소개'),
                    ),
                    PopupMenuItem(
                      value: _WorkspaceSection.chart,
                      child: Text('차트'),
                    ),
                    PopupMenuItem(
                      value: _WorkspaceSection.market,
                      child: Text('시장'),
                    ),
                    PopupMenuItem(
                      value: _WorkspaceSection.indicators,
                      child: Text('지표 가이드'),
                    ),
                    PopupMenuItem(
                      value: _WorkspaceSection.alerts,
                      child: Text('알림'),
                    ),
                  ],
                ),
              const _TradingViewBrandMark(),
              if (!compact) ...[
                const SizedBox(width: 30),
                for (final section in _WorkspaceSection.values)
                  _TradingViewNavItem(
                    label: _sectionLabel(section),
                    active: activeSection == section,
                    onTap: () => onSectionSelected(section),
                  ),
              ],
              const Spacer(),
              if (!compact) ...[
                InkWell(
                  onTap: () => onSectionSelected(_WorkspaceSection.alerts),
                  child: Badge(
                    isLabelVisible: unreadNotificationCount > 0,
                    label: Text('$unreadNotificationCount'),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AppColors.body,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  color: const Color(0xffeefaf2),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle))),
                      SizedBox(width: 6),
                      Text('LIVE MARKET', style: TextStyle(color: AppColors.label, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .6)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              InkWell(
                onTap: onAccountSelected,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  color: AppColors.ink,
                  child: Text(
                    _initials(account?.displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _sectionLabel(_WorkspaceSection section) => switch (section) {
        _WorkspaceSection.introduction => '소개',
        _WorkspaceSection.chart => '차트',
        _WorkspaceSection.market => '시장',
        _WorkspaceSection.indicators => '지표',
        _WorkspaceSection.alerts => '알림',
      };

  String _initials(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) return 'YE';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }
}

class _TradingViewBrandMark extends StatelessWidget {
  const _TradingViewBrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/branding/pulse_chart_icon.png',
          width: 26,
          height: 26,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 9),
        const Text('PULSE', style: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.6)),
        const SizedBox(width: 6),
        const Text('MARKET LAB', style: TextStyle(color: AppColors.muted, fontSize: 9, letterSpacing: 1.1)),
      ],
    );
  }
}

class _TradingViewNavItem extends StatelessWidget {
  const _TradingViewNavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? AppColors.green : Colors.transparent, width: 3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.ink : AppColors.body,
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TradingViewWorkspaceHeader extends StatelessWidget {
  const _TradingViewWorkspaceHeader({
    required this.market,
    required this.onMarketChanged,
  });

  final TradingViewMarket market;
  final ValueChanged<TradingViewMarket> onMarketChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TradingViewMarketSelector(
                  market: market,
                  onChanged: onMarketChanged,
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    market.exchange,
                    style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            if (compact)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'LIVE MARKET DATA',
                    style: TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -.5),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'TradingView Advanced Chart',
                    style: TextStyle(color: AppColors.body, fontSize: 11),
                  ),
                ],
              )
            else
              const Row(
                children: [
                  Text(
                    'LIVE MARKET DATA',
                    style: TextStyle(color: AppColors.ink, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.6),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'TradingView Advanced Chart',
                    style: TextStyle(color: AppColors.body, fontSize: 12),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _TradingViewMarketSelector extends StatelessWidget {
  const _TradingViewMarketSelector({required this.market, required this.onChanged});

  final TradingViewMarket market;
  final ValueChanged<TradingViewMarket> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TradingViewMarket>(
      initialValue: market,
      onSelected: onChanged,
      color: Colors.white,
      elevation: 3,
      itemBuilder: (context) => TradingViewMarket.markets
          .map(
            (item) => PopupMenuItem<TradingViewMarket>(
              value: item,
              height: 40,
              child: Text('${item.ticker}  ·  ${item.displayName}', style: const TextStyle(color: AppColors.ink, fontSize: 13)),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(market.ticker, style: const TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.body),
        ],
      ),
    );
  }
}

class _TradingViewMarketStrip extends StatelessWidget {
  const _TradingViewMarketStrip({required this.market});

  final TradingViewMarket market;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const Text('MARKET DATA', style: TextStyle(color: AppColors.muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8)),
            const SizedBox(width: 18),
            _item('SYMBOL', market.tradingViewSymbol),
            _item('SOURCE', 'TRADINGVIEW'),
            const Text('실시간 차트는 거래소별 지연 정책이 적용될 수 있습니다.', style: TextStyle(color: AppColors.muted, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label  ', style: const TextStyle(color: AppColors.body, fontSize: 10)),
            TextSpan(text: value, style: const TextStyle(color: AppColors.ink, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}



class _TradingViewIndicatorToolbar extends StatelessWidget {
  const _TradingViewIndicatorToolbar({
    required this.selectedIndicatorIds,
    required this.onSelected,
  });

  final Set<String> selectedIndicatorIds;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SIGNAL LAYER',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      compact ? '보조지표 선택' : '보조지표를 선택해 차트 분석 레이어를 확장하세요.',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.body,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (!compact)
                    Text(
                      '${selectedIndicatorIds.length} / 6 SELECTED',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .65,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 38,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      for (var index = 0; index < _TradingViewIntroductionPageState._studies.length; index++)
                        Padding(
                          padding: EdgeInsets.only(
                            right: index == _TradingViewIntroductionPageState._studies.length - 1 ? 0 : 7,
                          ),
                          child: _TradingViewIndicatorChip(
                            data: _TradingViewIntroductionPageState._studies[index],
                            indicatorId: IndicatorGuideEntry.entries[index].id,
                            selected: selectedIndicatorIds.contains(
                              IndicatorGuideEntry.entries[index].id,
                            ),
                            onSelected: onSelected,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TradingViewIndicatorChip extends StatelessWidget {
  const _TradingViewIndicatorChip({
    required this.data,
    required this.indicatorId,
    required this.selected,
    required this.onSelected,
  });

  final _TradingViewStudyPreviewData data;
  final String indicatorId;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xffeefaf2) : const Color(0xfff7faf8),
      child: InkWell(
        onTap: () => onSelected(indicatorId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                color: data.accent,
              ),
              const SizedBox(width: 8),
              Text(
                data.title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 9),
              Icon(
                selected ? Icons.check_circle : Icons.add_circle_outline,
                size: 13,
                color: selected ? AppColors.green : AppColors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                selected ? '선택됨' : '선택',
                style: TextStyle(
                  color: selected ? AppColors.ink : AppColors.muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TradingViewIntroductionPage extends StatefulWidget {
  const _TradingViewIntroductionPage({required this.onOpenChart});

  final VoidCallback onOpenChart;

  @override
  State<_TradingViewIntroductionPage> createState() =>
      _TradingViewIntroductionPageState();
}

class _TradingViewIntroductionPageState
    extends State<_TradingViewIntroductionPage>
    with TickerProviderStateMixin {
  static const _studies = <_TradingViewStudyPreviewData>[
    _TradingViewStudyPreviewData(
      category: 'TREND / OVERLAY',
      title: 'Adaptive Trend Ribbon',
      shortCode: 'TREND',
      formula: 'EMA 21 / EMA 55',
      summary: 'EMA 21과 EMA 55의 방향과 간격으로 추세의 결을 읽습니다.',
      reading:
          '두 평균선의 기울기와 간격이 같은 방향으로 움직이는지 먼저 확인합니다.',
      mode: 0,
      accent: AppColors.green,
    ),
    _TradingViewStudyPreviewData(
      category: 'MOMENTUM / OSCILLATOR',
      title: 'RSI Pulse',
      shortCode: 'RSI',
      formula: 'RSI 14 + SIGNAL 5',
      summary: '14기간 RSI와 5기간 신호선의 속도 변화를 함께 표시합니다.',
      reading:
          '과열·침체 숫자 하나보다 신호선의 방향 전환과 속도 변화를 함께 봅니다.',
      mode: 1,
      accent: Color(0xff9d8cff),
    ),
    _TradingViewStudyPreviewData(
      category: 'MOMENTUM / HISTOGRAM',
      title: 'MACD Momentum',
      shortCode: 'MACD',
      formula: 'EMA 12 / 26 / 9',
      summary: '추세 방향과 모멘텀 변화를 선과 히스토그램으로 표시합니다.',
      reading:
          '히스토그램의 색과 크기가 바뀌는 지점에서 모멘텀 전환을 관찰합니다.',
      mode: 2,
      accent: Color(0xff7eafff),
    ),
    _TradingViewStudyPreviewData(
      category: 'VOLATILITY / OVERLAY',
      title: 'Bollinger Squeeze',
      shortCode: 'BOLL',
      formula: 'SMA 20 / ±2σ',
      summary: '밴드 폭의 수축과 확장으로 변동성 국면을 추적합니다.',
      reading:
          '밴드가 좁아지는 압축 구간과 다시 벌어지는 확장 구간을 구분해 봅니다.',
      mode: 3,
      accent: Color(0xff62b5ff),
    ),
    _TradingViewStudyPreviewData(
      category: 'VOLUME / PRESSURE',
      title: 'Volume Pressure',
      shortCode: 'V-PRESS',
      formula: '14 PERIOD PRESSURE',
      summary: '가격 움직임에 실린 거래량의 매수·매도 압력을 계산합니다.',
      reading:
          '가격 방향이 거래량과 함께 나타나는지 확인해 움직임의 밀도를 읽습니다.',
      mode: 4,
      accent: Color(0xffffc857),
    ),
    _TradingViewStudyPreviewData(
      category: 'FLOW / DEVIATION',
      title: 'Smart Flow',
      shortCode: 'FLOW',
      formula: '20 PERIOD FLOW + Z',
      summary: '거래량 방향성과 현재 거래량 이탈을 함께 읽습니다.',
      reading:
          '20기간 흐름과 현재 거래량 이탈이 같은 방향인지 비교해 봅니다.',
      mode: 5,
      accent: Color(0xffff8f70),
    ),
  ];

  late final AnimationController _motionController;
  late final AnimationController _pageTransitionController;
  late final PageController _pageController;
  int _activePage = 0;
  bool _isPageAnimating = false;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..forward();
    _pageController = PageController();
  }

  void _handlePageChanged(int page) {
    if (!mounted) return;
    setState(() => _activePage = page);
    _pageTransitionController.forward(from: 0);
  }

  void _goToPage(int page) {
    final targetPage = page.clamp(0, _studies.length).toInt();
    if (targetPage == _activePage ||
        _isPageAnimating ||
        !_pageController.hasClients) {
      return;
    }

    _isPageAnimating = true;
    _pageController
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 620),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          _isPageAnimating = false;
        });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    final delta = event.scrollDelta.dy;
    if (delta.abs() < 1) return;

    _goToPage(_activePage + (delta > 0 ? 1 : -1));
  }

  double _pageValue() {
    if (!_pageController.hasClients) {
      return _activePage.toDouble();
    }
    return _pageController.page ?? _activePage.toDouble();
  }

  @override
  void dispose() {
    _motionController.dispose();
    _pageTransitionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        return SizedBox.expand(
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              scrollbars: false,
            ),
            child: Listener(
              onPointerSignal: _handlePointerSignal,
              child: Stack(
                children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const _StudyPageScrollPhysics(),
                  pageSnapping: true,
                  itemCount: _studies.length + 1,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: Listenable.merge(<Listenable>[
                        _pageController,
                        _pageTransitionController,
                        _motionController,
                      ]),
                      builder: (context, child) {
                        final page = _pageValue();
                        final distance =
                            (page - index).abs().clamp(0.0, 1.0).toDouble();
                        final focus = 1.0 - distance;
                        final transition = Curves.easeOutCubic.transform(
                          _pageTransitionController.value,
                        );
                        final activeEntry =
                            index == _activePage ? transition : 1.0;
                        final direction = index < page ? -1.0 : 1.0;
                        final offsetY = index == _activePage
                            ? (1.0 - activeEntry) * 30
                            : direction * distance * 18;
                        final opacity = ((.46 + focus * .54) *
                                (.70 + activeEntry * .30))
                            .clamp(0.0, 1.0)
                            .toDouble();
                        final scale = .965 + focus * .035;

                        final pageContent = index == 0
                            ? _TradingViewScrollIntroHero(
                                compact: compact,
                                focus: focus,
                                progress: _motionController.value,
                                onOpenChart: widget.onOpenChart,
                              )
                            : _TradingViewScrollStudySlide(
                                data: _studies[index - 1],
                                studyIndex: index - 1,
                                compact: compact,
                                focus: focus,
                                progress: _motionController.value,
                              );

                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, offsetY),
                            child: Transform.scale(
                              scale: scale,
                              child: pageContent,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                if (compact)
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: _TradingViewSceneRail(
                      activePage: _activePage,
                      compact: true,
                      onSelect: _goToPage,
                    ),
                  )
                else
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 26,
                    width: 112,
                    child: Center(
                      child: _TradingViewSceneRail(
                        activePage: _activePage,
                        compact: false,
                        onSelect: _goToPage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StudyPageScrollPhysics extends PageScrollPhysics {
  const _StudyPageScrollPhysics({super.parent});

  @override
  _StudyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _StudyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (position.outOfRange || position.viewportDimension <= 0) {
      return super.createBallisticSimulation(position, velocity);
    }

    final tolerance = toleranceFor(position);
    final page = position.pixels / position.viewportDimension;
    final nearestPage = page.roundToDouble();
    final distance = page - nearestPage;

    if (velocity.abs() < tolerance.velocity && distance.abs() >= .04) {
      final targetPage = distance > 0
          ? nearestPage.ceil().toDouble()
          : nearestPage.floor().toDouble();
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        targetPage * position.viewportDimension,
        velocity,
        tolerance: tolerance,
      );
    }

    return super.createBallisticSimulation(position, velocity);
  }
}

class _TradingViewSceneRail extends StatelessWidget {
  const _TradingViewSceneRail({
    required this.activePage,
    required this.compact,
    required this.onSelect,
  });

  static const _labels = <String>[
    'INTRO',
    'TREND',
    'RSI',
    'MACD',
    'BOLL',
    'V-PRESS',
    'FLOW',
  ];

  static const _colors = <Color>[
    AppColors.green,
    AppColors.green,
    Color(0xff9d8cff),
    Color(0xff7eafff),
    Color(0xff62b5ff),
    Color(0xffffc857),
    Color(0xffff8f70),
  ];

  final int activePage;
  final bool compact;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xee17191d),
        border: Border.all(color: const Color(0x4dffffff)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 9,
          vertical: compact ? 8 : 10,
        ),
        child: compact ? _compactRail() : _desktopRail(),
      ),
    );
  }

  Widget _compactRail() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _labels[activePage],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(width: 10),
        for (var index = 0; index < _labels.length; index++)
          _railSegment(index),
      ],
    );
  }

  Widget _desktopRail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'SCENE MAP',
          style: TextStyle(
            color: Color(0xffaab3b5),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .9,
          ),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < _labels.length; index++)
          _railSegment(index),
      ],
    );
  }

  Widget _railSegment(int index) {
    final active = index == activePage;
    final color = _colors[index];
    return InkWell(
      onTap: () => onSelect(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact && active) ...[
              Text(
                _labels[index],
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(width: 8),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: compact
                  ? (active ? 18 : 5)
                  : (active ? 22 : 5),
              height: 4,
              decoration: BoxDecoration(
                color: color.withValues(alpha: active ? 1 : .28),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradingViewScrollIntroHero extends StatelessWidget {
  const _TradingViewScrollIntroHero({
    required this.compact,
    required this.focus,
    required this.progress,
    required this.onOpenChart,
  });

  final bool compact;
  final double focus;
  final double progress;
  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final short = constraints.maxHeight < 620;
        final padding = compact
            ? (short ? 16.0 : 24.0)
            : (short ? 30.0 : 48.0);
        final terminalHeight = compact
            ? (short ? 126.0 : 220.0)
            : (short ? 190.0 : 292.0);
        final terminalWidth = math.min(392.0, constraints.maxWidth * .36);

        return Container(
          color: AppColors.ink,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TradingViewStudyHeroPainter(
                    progress: progress,
                    intensity: .72 + focus * .28,
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xf517191d),
                        Color(0xc817191d),
                        Color(0x2a17191d),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _TradingViewStudiesEyebrow(),
                    SizedBox(height: compact ? 16 : 26),
                    Expanded(
                      child: compact
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _TradingViewScrollHeroCopy(
                                      compact: true,
                                      short: short,
                                      onOpenChart: onOpenChart,
                                    ),
                                  ),
                                ),
                                SizedBox(height: short ? 9 : 16),
                                SizedBox(
                                  height: terminalHeight,
                                  child: _TradingViewScrollSignalTerminal(
                                    progress: progress,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: _TradingViewScrollHeroCopy(
                                    compact: false,
                                    short: short,
                                    onOpenChart: onOpenChart,
                                  ),
                                ),
                                const SizedBox(width: 32),
                                SizedBox(
                                  width: terminalWidth,
                                  height: terminalHeight,
                                  child: _TradingViewScrollSignalTerminal(
                                    progress: progress,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: compact ? 12 : 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.mouse_rounded,
                          color: Color(0xffaab3b5),
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          short
                              ? 'VERTICAL SCROLL / EXPLORE'
                              : 'VERTICAL SCROLL / ONE STUDY AT A TIME',
                          style: const TextStyle(
                            color: Color(0xffaab3b5),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .9,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.south_rounded,
                          color: Color(0xffaab3b5),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TradingViewScrollHeroCopy extends StatelessWidget {
  const _TradingViewScrollHeroCopy({
    required this.compact,
    required this.short,
    required this.onOpenChart,
  });

  final bool compact;
  final bool short;
  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    final titleSize = compact
        ? (short ? 26.0 : 34.0)
        : (short ? 35.0 : 48.0);
    final bodySize = short ? 10.0 : compact ? 12.0 : 13.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복잡한 차트를,\n선명한 신호로.',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            height: 1.03,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
          ),
        ),
        SizedBox(height: short ? 8 : 14),
        Text(
          compact
              ? '추세·모멘텀·변동성·거래량을 한 화면에서 읽는 분석 워크스페이스입니다.'
              : '추세·모멘텀·변동성·거래량을 한 화면에서 정리하고,\n하나씩 읽은 신호를 시장의 흐름으로 연결합니다.',
          style: TextStyle(
            color: const Color(0xffb7bec1),
            fontSize: bodySize,
            height: 1.5,
          ),
        ),
        SizedBox(height: short ? 12 : 22),
        ElevatedButton.icon(
          onPressed: onOpenChart,
          icon: const Icon(Icons.arrow_outward_rounded, size: 16),
          label: const Text('워크스페이스 열기'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: short ? 14 : 20,
              vertical: short ? 10 : 16,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: TextStyle(
              fontSize: short ? 10 : 13,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
          ),
        ),
      ],
    );
  }
}

class _TradingViewScrollSignalTerminal extends StatelessWidget {
  const _TradingViewScrollSignalTerminal({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xb5080d0e),
        border: Border.all(color: const Color(0x60767d7f)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _TradingViewStudyHeroPainter(
              progress: progress,
              intensity: 1,
              mini: true,
            ),
          ),
          const Positioned(
            left: 10,
            top: 9,
            child: Text(
              'SIGNAL WORKSPACE',
              style: TextStyle(
                color: Color(0xffe9edef),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: .9,
              ),
            ),
          ),
          const Positioned(
            right: 10,
            top: 9,
            child: Text(
              'STUDY INDEX',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: .7,
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 9,
            child: Wrap(
              spacing: 5,
              runSpacing: 4,
              children: [
                _TradingViewScrollSignalTag(
                  label: 'TREND',
                  color: AppColors.green,
                ),
                _TradingViewScrollSignalTag(
                  label: 'MOMENTUM',
                  color: const Color(0xff9d8cff),
                ),
                _TradingViewScrollSignalTag(
                  label: 'VOLATILITY',
                  color: const Color(0xff62b5ff),
                ),
                _TradingViewScrollSignalTag(
                  label: 'FLOW',
                  color: const Color(0xffff8f70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TradingViewScrollSignalTag extends StatelessWidget {
  const _TradingViewScrollSignalTag({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      color: const Color(0x1affffff),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class _TradingViewScrollStudySlide extends StatelessWidget {
  const _TradingViewScrollStudySlide({
    required this.data,
    required this.studyIndex,
    required this.compact,
    required this.focus,
    required this.progress,
  });

  final _TradingViewStudyPreviewData data;
  final int studyIndex;
  final bool compact;
  final double focus;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final short = constraints.maxHeight < 620;
        final padding = compact
            ? (short ? 14.0 : 20.0)
            : (short ? 28.0 : 46.0);
        final background = studyIndex.isEven
            ? Colors.white
            : const Color(0xfff1f4f5);

        final visual = Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, .06 + focus * .05),
                offset: const Offset(0, 8),
                blurRadius: 22,
              ),
            ],
          ),
          child: ClipRect(
            child: _TradingViewStudyVisual(
              data: data,
              progress: progress,
            ),
          ),
        );
        final copy = _TradingViewScrollStudyCopy(
          data: data,
          compact: compact,
          short: short,
        );

        return Container(
          color: background,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -120,
                right: -90,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: .045),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -160,
                left: -130,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .025),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding,
                  padding,
                  padding,
                  compact ? (short ? 12 : 18) : (short ? 18 : 28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TradingViewScrollStudyHeader(
                      data: data,
                      studyIndex: studyIndex,
                      compact: compact,
                    ),
                    SizedBox(height: compact ? 12 : 20),
                    Expanded(
                      child: compact
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: short ? 4 : 5,
                                  child: visual,
                                ),
                                SizedBox(height: short ? 10 : 16),
                                Expanded(
                                  flex: short ? 7 : 6,
                                  child: copy,
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 6, child: visual),
                                const SizedBox(width: 46),
                                Expanded(flex: 5, child: copy),
                              ],
                            ),
                    ),
                    SizedBox(height: compact ? 10 : 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              studyIndex == _TradingViewIntroductionPageState._studies.length - 1
                                  ? 'LAST SIGNAL / OPEN CHART'
                                  : 'SCROLL / NEXT SIGNAL',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .8,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              studyIndex == _TradingViewIntroductionPageState._studies.length - 1
                                  ? Icons.arrow_outward_rounded
                                  : Icons.south_rounded,
                              color: studyIndex == _TradingViewIntroductionPageState._studies.length - 1
                                  ? data.accent
                                  : AppColors.muted,
                              size: 15,
                            ),
                          ],
                        ),
                        if (studyIndex ==
                            _TradingViewIntroductionPageState._studies.length - 1) ...[
                          SizedBox(height: compact ? 8 : 12),
                          _TradingViewLandingFooter(compact: compact),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TradingViewLandingFooter extends StatelessWidget {
  const _TradingViewLandingFooter({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 7 : 9,
      ),
      color: AppColors.ink,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14,
        runSpacing: 5,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/branding/pulse_chart_icon.png',
                width: compact ? 18 : 20,
                height: compact ? 18 : 20,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(width: 7),
              const Text(
                'PULSE CHART',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Text(
            'CHARTS BY TRADINGVIEW',
            style: TextStyle(
              color: Color(0xffaab3b5),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
            ),
          ),
          const Text(
            '© 2026 PULSE CHART / ALL RIGHTS RESERVED',
            style: TextStyle(
              color: Color(0xff7f898c),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TradingViewScrollStudyHeader extends StatelessWidget {
  const _TradingViewScrollStudyHeader({
    required this.data,
    required this.studyIndex,
    required this.compact,
  });

  final _TradingViewStudyPreviewData data;
  final int studyIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final segments = Row(
      children: [
        for (var index = 0; index < 6; index++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 5 ? 0 : 5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                height: 4,
                color: index == studyIndex
                    ? AppColors.green
                    : index < studyIndex
                        ? const Color(0x5500de5a)
                        : const Color(0xffdfe5e6),
              ),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              color: data.accent,
            ),
            const SizedBox(width: 9),
            Text(
              'ACTIVE SIGNAL',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                data.category,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .75,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'FOCUS MODE',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 9 : 13),
        segments,
      ],
    );
  }
}

class _TradingViewScrollStudyCopy extends StatelessWidget {
  const _TradingViewScrollStudyCopy({
    required this.data,
    required this.compact,
    required this.short,
  });

  final _TradingViewStudyPreviewData data;
  final bool compact;
  final bool short;

  @override
  Widget build(BuildContext context) {
    final titleSize = compact
        ? (short ? 23.0 : 28.0)
        : (short ? 29.0 : 36.0);
    final bodySize = compact
        ? (short ? 10.0 : 12.0)
        : (short ? 11.0 : 13.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PULSE STUDY / ACTIVE SIGNAL',
          style: TextStyle(
            color: data.accent,
            fontSize: short ? 8 : 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: short ? 8 : 14),
        Text(
          data.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: titleSize,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -.8,
          ),
        ),
        SizedBox(height: short ? 8 : 12),
        Text(
          data.summary,
          maxLines: compact ? (short ? 2 : 3) : 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.body,
            fontSize: bodySize,
            height: 1.5,
          ),
        ),
        SizedBox(height: short ? 10 : 16),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: short ? 8 : 10,
            vertical: short ? 6 : 8,
          ),
          color: const Color(0xffe8edef),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                color: AppColors.label,
                size: short ? 12 : 14,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  data.formula,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.label,
                    fontSize: short ? 8 : 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .35,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: short ? 11 : 18),
        Text(
          'READING POINT',
          style: TextStyle(
            color: AppColors.green,
            fontSize: short ? 8 : 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.reading,
          maxLines: compact ? (short ? 3 : 4) : 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.body,
            fontSize: short ? 10 : compact ? 11 : 12,
            height: 1.5,
          ),
        ),
        SizedBox(height: short ? 10 : 16),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              color: data.accent,
            ),
            const SizedBox(width: 7),
            Text(
              data.shortCode,
              style: TextStyle(
                color: data.accent,
                fontSize: short ? 8 : 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'CONCEPT PREVIEW',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TradingViewStudiesEyebrow extends StatelessWidget {
  const _TradingViewStudiesEyebrow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 8,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 10),
        Text(
          'PULSE / MARKET INTELLIGENCE',
          style: TextStyle(
            color: Color(0xffc8ced0),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _TradingViewStudyHeroPainter extends CustomPainter {
  const _TradingViewStudyHeroPainter({
    required this.progress,
    required this.intensity,
    this.mini = false,
  });

  final double progress;
  final double intensity;
  final bool mini;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final gridPaint = Paint()
      ..color = mini ? const Color(0x1cffffff) : const Color(0x16ffffff)
      ..strokeWidth = 1;
    for (var index = 1; index < 6; index++) {
      final y = size.height * index / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var index = 1; index < 10; index++) {
      final x = size.width * index / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    const coordinates = <Offset>[
      Offset(0, .74),
      Offset(.07, .69),
      Offset(.14, .72),
      Offset(.22, .57),
      Offset(.30, .61),
      Offset(.38, .45),
      Offset(.46, .50),
      Offset(.54, .35),
      Offset(.62, .39),
      Offset(.70, .28),
      Offset(.78, .31),
      Offset(.87, .16),
      Offset(1, .21),
    ];
    final line = Path();
    for (var index = 0; index < coordinates.length; index++) {
      final coordinate = coordinates[index];
      final wave = math.sin(progress * math.pi * 2 + index * .65) *
          (mini ? .008 : .014) *
          intensity;
      final point = Offset(
        coordinate.dx * size.width,
        (coordinate.dy + wave) * size.height,
      );
      if (index == 0) {
        line.moveTo(point.dx, point.dy);
      } else {
        line.lineTo(point.dx, point.dy);
      }
    }

    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0x4200de5a),
            Color(0x0500de5a),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.green
        ..strokeWidth = mini ? 2 : 2.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final scanX = (progress * 1.15 % 1) * size.width;
    canvas.drawLine(
      Offset(scanX, 0),
      Offset(scanX, size.height),
      Paint()
        ..color = const Color(0x6500de5a)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      Offset(scanX, size.height * .21),
      mini ? 3 : 4,
      Paint()..color = AppColors.green,
    );
  }

  @override
  bool shouldRepaint(covariant _TradingViewStudyHeroPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.intensity != intensity ||
        oldDelegate.mini != mini;
  }
}

class _TradingViewStudyVisual extends StatelessWidget {
  const _TradingViewStudyVisual({
    required this.data,
    required this.progress,
  });

  final _TradingViewStudyPreviewData data;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: const Color(0xff2e3538)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _TradingViewStudyPreviewPainter(
              mode: data.mode,
              accent: data.accent,
              progress: progress,
            ),
          ),
          Positioned(
            left: 12,
            top: 10,
            child: Text(
              data.shortCode,
              style: TextStyle(
                color: data.accent,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const Positioned(
            right: 12,
            top: 10,
            child: Text(
              'SIGNAL PREVIEW',
              style: TextStyle(
                color: Color(0xff8e999b),
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: .7,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Row(
              children: [
                Text(
                  data.formula,
                  style: const TextStyle(
                    color: Color(0xffb9c1c3),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  color: data.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TradingViewStudyPreviewPainter extends CustomPainter {
  const _TradingViewStudyPreviewPainter({
    required this.mode,
    required this.accent,
    required this.progress,
  });

  final int mode;
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    _drawGrid(canvas, size);
    switch (mode) {
      case 0:
        _drawTrend(canvas, size);
        break;
      case 1:
        _drawRsi(canvas, size);
        break;
      case 2:
        _drawMacd(canvas, size);
        break;
      case 3:
        _drawBollinger(canvas, size);
        break;
      case 4:
        _drawVolumePressure(canvas, size);
        break;
      case 5:
        _drawSmartFlow(canvas, size);
        break;
      default:
        _drawTrend(canvas, size);
    }

    final scanX = (progress * 1.3 % 1) * size.width;
    canvas.drawLine(
      Offset(scanX, 0),
      Offset(scanX, size.height),
      Paint()
        ..color = accent.withValues(alpha: .28)
        ..strokeWidth = 1,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x16ffffff)
      ..strokeWidth = 1;
    for (var index = 1; index < 5; index++) {
      final y = size.height * index / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var index = 1; index < 9; index++) {
      final x = size.width * index / 9;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  Path _line(
    Size size,
    List<Offset> points, {
    double wave = .008,
    double phase = 0,
  }) {
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final y = point.dy +
          math.sin(progress * math.pi * 2 + phase + index * .7) * wave;
      final offset = Offset(point.dx * size.width, y * size.height);
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    return path;
  }

  void _drawTrend(Canvas canvas, Size size) {
    const closes = <double>[.70, .64, .68, .59, .61, .51, .54, .43, .47, .35, .39, .27];
    const opens = <double>[.73, .66, .63, .62, .57, .54, .50, .46, .43, .39, .34, .31];
    for (var index = 0; index < closes.length; index++) {
      final x = size.width * (.09 + index * .075);
      final close = closes[index];
      final open = opens[index];
      final high = math.min(open, close) - .045;
      final low = math.max(open, close) + .045;
      final color = close <= open
          ? const Color(0xffff8b76)
          : AppColors.green;
      final candle = Rect.fromLTRB(
        x - 4,
        math.min(open, close) * size.height,
        x + 4,
        math.max(open, close) * size.height,
      );
      canvas.drawLine(
        Offset(x, high * size.height),
        Offset(x, low * size.height),
        Paint()
          ..color = color
          ..strokeWidth = 1,
      );
      canvas.drawRect(candle, Paint()..color = color);
    }
    final fast = _line(
      size,
      const [
        Offset(.05, .76),
        Offset(.18, .67),
        Offset(.31, .61),
        Offset(.44, .54),
        Offset(.57, .45),
        Offset(.70, .36),
        Offset(.84, .25),
        Offset(.96, .19),
      ],
      wave: .006,
      phase: .2,
    );
    final slow = _line(
      size,
      const [
        Offset(.05, .79),
        Offset(.18, .73),
        Offset(.31, .68),
        Offset(.44, .60),
        Offset(.57, .52),
        Offset(.70, .43),
        Offset(.84, .34),
        Offset(.96, .27),
      ],
      wave: .004,
      phase: 1.1,
    );
    canvas.drawPath(
      slow,
      Paint()
        ..color = const Color(0xff7eafff)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      fast,
      Paint()
        ..color = AppColors.green
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawRsi(Canvas canvas, Size size) {
    _drawLevel(canvas, size, .28);
    _drawLevel(canvas, size, .72);
    final line = _line(
      size,
      const [
        Offset(.04, .64),
        Offset(.14, .57),
        Offset(.23, .42),
        Offset(.31, .32),
        Offset(.40, .39),
        Offset(.50, .62),
        Offset(.60, .74),
        Offset(.69, .66),
        Offset(.78, .48),
        Offset(.88, .29),
        Offset(.97, .40),
      ],
      wave: .012,
      phase: .6,
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = accent
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (final point in const [
      Offset(.31, .32),
      Offset(.60, .74),
      Offset(.88, .29),
    ]) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        3.5,
        Paint()..color = accent,
      );
    }
  }

  void _drawMacd(Canvas canvas, Size size) {
    _drawLevel(canvas, size, .64);
    const bars = <double>[.08, .04, -.04, -.10, -.15, -.07, .05, .12, .18, .11, .04, -.03];
    for (var index = 0; index < bars.length; index++) {
      final value = bars[index];
      final x = size.width * (.08 + index * .075);
      final y = size.height * .64;
      final barHeight = value.abs() * size.height * 1.8;
      canvas.drawRect(
        Rect.fromLTRB(
          x - 5,
          value >= 0 ? y - barHeight : y,
          x + 5,
          value >= 0 ? y : y + barHeight,
        ),
        Paint()
          ..color = value >= 0
              ? const Color(0x9e00de5a)
              : const Color(0x9eff8b76),
      );
    }
    canvas.drawPath(
      _line(
        size,
        const [
          Offset(.05, .61),
          Offset(.18, .57),
          Offset(.30, .66),
          Offset(.43, .70),
          Offset(.56, .60),
          Offset(.69, .47),
          Offset(.82, .42),
          Offset(.96, .53),
        ],
        wave: .01,
      ),
      Paint()
        ..color = accent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      _line(
        size,
        const [
          Offset(.05, .64),
          Offset(.18, .61),
          Offset(.30, .63),
          Offset(.43, .65),
          Offset(.56, .62),
          Offset(.69, .53),
          Offset(.82, .48),
          Offset(.96, .50),
        ],
        wave: .006,
        phase: 1,
      ),
      Paint()
        ..color = const Color(0xff8d98a0)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawBollinger(Canvas canvas, Size size) {
    final upper = _line(
      size,
      const [
        Offset(.04, .30),
        Offset(.15, .25),
        Offset(.26, .28),
        Offset(.37, .22),
        Offset(.48, .29),
        Offset(.59, .24),
        Offset(.70, .31),
        Offset(.81, .27),
        Offset(.96, .34),
      ],
      wave: .005,
    );
    final lower = _line(
      size,
      const [
        Offset(.04, .61),
        Offset(.15, .59),
        Offset(.26, .57),
        Offset(.37, .59),
        Offset(.48, .54),
        Offset(.59, .58),
        Offset(.70, .55),
        Offset(.81, .57),
        Offset(.96, .62),
      ],
      wave: .005,
      phase: 1.5,
    );
    final middle = _line(
      size,
      const [
        Offset(.04, .45),
        Offset(.15, .42),
        Offset(.26, .43),
        Offset(.37, .40),
        Offset(.48, .42),
        Offset(.59, .41),
        Offset(.70, .43),
        Offset(.81, .42),
        Offset(.96, .48),
      ],
      wave: .004,
    );
    canvas.drawPath(
      upper,
      Paint()
        ..color = accent
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      lower,
      Paint()
        ..color = accent
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      middle,
      Paint()
        ..color = const Color(0xff9ba5a7)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      _line(
        size,
        const [
          Offset(.05, .47),
          Offset(.16, .40),
          Offset(.27, .44),
          Offset(.38, .38),
          Offset(.49, .43),
          Offset(.60, .38),
          Offset(.71, .44),
          Offset(.82, .39),
          Offset(.95, .46),
        ],
        wave: .012,
        phase: .8,
      ),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawVolumePressure(Canvas canvas, Size size) {
    _drawLevel(canvas, size, .58);
    const values = <double>[.18, -.11, .28, .06, -.20, -.08, .24, .35, .12, -.08, .20, .30];
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      final x = size.width * (.08 + index * .075);
      final base = size.height * .58;
      final height = value.abs() * size.height;
      canvas.drawRect(
        Rect.fromLTRB(
          x - 6,
          value >= 0 ? base - height : base,
          x + 6,
          value >= 0 ? base : base + height,
        ),
        Paint()
          ..color = value >= 0
              ? const Color(0xbaffc857)
              : const Color(0xbaff8b76),
      );
    }
    canvas.drawPath(
      _line(
        size,
        const [
          Offset(.04, .61),
          Offset(.15, .55),
          Offset(.26, .58),
          Offset(.37, .48),
          Offset(.48, .53),
          Offset(.59, .42),
          Offset(.70, .46),
          Offset(.81, .35),
          Offset(.96, .39),
        ],
        wave: .012,
      ),
      Paint()
        ..color = accent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawSmartFlow(Canvas canvas, Size size) {
    _drawLevel(canvas, size, .50);
    final line = _line(
      size,
      const [
        Offset(.04, .68),
        Offset(.15, .61),
        Offset(.25, .65),
        Offset(.35, .43),
        Offset(.46, .36),
        Offset(.56, .48),
        Offset(.67, .30),
        Offset(.77, .39),
        Offset(.87, .24),
        Offset(.96, .28),
      ],
      wave: .014,
      phase: .9,
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = accent
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    const spikes = <double>[.12, .05, .30, .10, .18, .42, .08, .22, .34, .16];
    for (var index = 0; index < spikes.length; index++) {
      final x = size.width * (.07 + index * .09);
      final height = spikes[index] * size.height;
      canvas.drawRect(
        Rect.fromLTRB(
          x - 3,
          size.height * .86 - height,
          x + 3,
          size.height * .86,
        ),
        Paint()..color = const Color(0x6aff8f70),
      );
    }
  }

  void _drawLevel(Canvas canvas, Size size, double normalizedY) {
    canvas.drawLine(
      Offset(0, size.height * normalizedY),
      Offset(size.width, size.height * normalizedY),
      Paint()
        ..color = const Color(0x559aa5a7)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TradingViewStudyPreviewPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.accent != accent ||
        oldDelegate.progress != progress;
  }
}

class _TradingViewStudyPreviewData {
  const _TradingViewStudyPreviewData({
    required this.category,
    required this.title,
    required this.shortCode,
    required this.formula,
    required this.summary,
    required this.reading,
    required this.mode,
    required this.accent,
  });

  final String category;
  final String title;
  final String shortCode;
  final String formula;
  final String summary;
  final String reading;
  final int mode;
  final Color accent;
}

class _TradingViewChartCard extends StatelessWidget {
  const _TradingViewChartCard({
    required this.market,
    required this.interval,
    required this.theme,
    required this.onIntervalChanged,
    required this.onThemeChanged,
    required this.onFullScreen,
  });

  final TradingViewMarket market;
  final String interval;
  final ChartThemePreference theme;
  final ValueChanged<String> onIntervalChanged;
  final VoidCallback onThemeChanged;
  final VoidCallback onFullScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          return Column(
            children: [
              Row(
                children: [
                  const Text(
                    'LIVE CHART',
                    style: TextStyle(
                      color: AppColors.label,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .7,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      market.tradingViewSymbol,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: '시간봉 선택',
                    initialValue: interval,
                    onSelected: onIntervalChanged,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: '15', child: Text('15분')),
                      PopupMenuItem(value: '60', child: Text('1시간')),
                      PopupMenuItem(value: '240', child: Text('4시간')),
                      PopupMenuItem(value: 'D', child: Text('일봉')),
                      PopupMenuItem(value: 'W', child: Text('주봉')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      color: const Color(0xfff2f4f5),
                      child: Text(
                        interval,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: theme == ChartThemePreference.light
                        ? '다크 차트'
                        : '라이트 차트',
                    onPressed: onThemeChanged,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      theme == ChartThemePreference.light
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      size: 17,
                      color: AppColors.body,
                    ),
                  ),
                  IconButton(
                    tooltip: '차트 전체화면',
                    onPressed: onFullScreen,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.fullscreen_rounded,
                      size: 20,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 4 : 6),
              Expanded(
                child: TradingViewChart(
                  key: ValueKey(
                    '${market.tradingViewSymbol}-$interval-${theme.name}',
                  ),
                  symbol: market.tradingViewSymbol,
                  interval: interval,
                  theme: theme.name,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
