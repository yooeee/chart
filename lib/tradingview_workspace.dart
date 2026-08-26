import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'widgets/tradingview_chart.dart';

class TradingViewMarket {
  const TradingViewMarket({
    required this.ticker,
    required this.name,
    required this.exchange,
    required this.tradingViewSymbol,
  });

  final String ticker;
  final String name;
  final String exchange;
  final String tradingViewSymbol;

  static const markets = <TradingViewMarket>[
    TradingViewMarket(
      ticker: 'BTCUSD',
      name: 'Bitcoin',
      exchange: 'BINANCE',
      tradingViewSymbol: 'BINANCE:BTCUSDT',
    ),
    TradingViewMarket(
      ticker: 'ETHUSD',
      name: 'Ethereum',
      exchange: 'BINANCE',
      tradingViewSymbol: 'BINANCE:ETHUSDT',
    ),
    TradingViewMarket(
      ticker: 'SAMSUNG',
      name: '삼성전자 추종 선물',
      exchange: 'BINANCE FUTURES',
      tradingViewSymbol: 'BINANCE:SAMSUNGUSDT.P',
    ),
    TradingViewMarket(
      ticker: 'SKHYNIX',
      name: 'SK하이닉스 추종 선물',
      exchange: 'BINANCE FUTURES',
      tradingViewSymbol: 'BINANCE:SKHYNIXUSDT.P',
    ),
  ];
}

class TradingViewWorkspacePage extends StatefulWidget {
  const TradingViewWorkspacePage({super.key});

  @override
  State<TradingViewWorkspacePage> createState() => _TradingViewWorkspacePageState();
}

class _TradingViewWorkspacePageState extends State<TradingViewWorkspacePage> {
  TradingViewMarket _selectedMarket = TradingViewMarket.markets.first;
  bool _showIntroduction = true;

  void _selectMarket(TradingViewMarket market) {
    setState(() => _selectedMarket = market);
  }

  void _showIntro() {
    setState(() => _showIntroduction = true);
  }

  void _showChart() {
    setState(() => _showIntroduction = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TradingViewPalette.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _TradingViewTopNavigation(
              showIntroduction: _showIntroduction,
              onIntroductionSelected: _showIntro,
              onChartSelected: _showChart,
            ),
            Expanded(
              child: _showIntroduction
                  ? _TradingViewIntroductionPage(onOpenChart: _showChart)
                  : _TradingViewChartPage(
                      market: _selectedMarket,
                      onMarketChanged: _selectMarket,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradingViewChartPage extends StatelessWidget {
  const _TradingViewChartPage({
    required this.market,
    required this.onMarketChanged,
  });

  final TradingViewMarket market;
  final ValueChanged<TradingViewMarket> onMarketChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 12 : 24,
            compact ? 12 : 20,
            compact ? 12 : 24,
            compact ? 16 : 24,
          ),
          child: Column(
            children: [
              _TradingViewWorkspaceHeader(
                market: market,
                onMarketChanged: onMarketChanged,
              ),
              const SizedBox(height: 12),
              _TradingViewMarketStrip(market: market),
              const SizedBox(height: 16),
              Expanded(child: _TradingViewChartCard(market: market)),
            ],
          ),
        );
      },
    );
  }
}

class _TradingViewPalette {
  static const green = Color(0xff00de5a);
  static const ink = Color(0xff17191d);
  static const body = Color(0xff737881);
  static const label = Color(0xff4a4e57);
  static const muted = Color(0xff919191);
  static const canvas = Color(0xfff5f7f8);
  static const border = Color(0xffe6e9eb);
}

class _TradingViewTopNavigation extends StatelessWidget {
  const _TradingViewTopNavigation({
    required this.showIntroduction,
    required this.onIntroductionSelected,
    required this.onChartSelected,
  });

  final bool showIntroduction;
  final VoidCallback onIntroductionSelected;
  final VoidCallback onChartSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _TradingViewPalette.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          return Row(
            children: [
              if (compact)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu_rounded, color: _TradingViewPalette.ink),
                  onSelected: (value) {
                    if (value == 'intro') {
                      onIntroductionSelected();
                    } else {
                      onChartSelected();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'intro', child: Text('소개')),
                    PopupMenuItem(value: 'chart', child: Text('차트')),
                  ],
                ),
              const _TradingViewBrandMark(),
              if (!compact) ...[
                const SizedBox(width: 42),
                _TradingViewNavItem(
                  label: '소개',
                  active: showIntroduction,
                  onTap: onIntroductionSelected,
                ),
                _TradingViewNavItem(
                  label: '차트',
                  active: !showIntroduction,
                  onTap: onChartSelected,
                ),
              ],
              const Spacer(),
              if (!compact) ...[
                const Icon(Icons.notifications_none_rounded, size: 20, color: _TradingViewPalette.body),
                const SizedBox(width: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  color: const Color(0xffeefaf2),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: _TradingViewPalette.green, shape: BoxShape.circle))),
                      SizedBox(width: 6),
                      Text('TRADINGVIEW', style: TextStyle(color: _TradingViewPalette.label, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .6)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                color: _TradingViewPalette.ink,
                child: const Text('YE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TradingViewBrandMark extends StatelessWidget {
  const _TradingViewBrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          color: _TradingViewPalette.green,
          child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 18),
        ),
        const SizedBox(width: 9),
        const Text('PULSE', style: TextStyle(color: _TradingViewPalette.ink, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.6)),
        const SizedBox(width: 6),
        const Text('MARKET LAB', style: TextStyle(color: _TradingViewPalette.muted, fontSize: 9, letterSpacing: 1.1)),
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
          border: Border(bottom: BorderSide(color: active ? _TradingViewPalette.green : Colors.transparent, width: 3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? _TradingViewPalette.ink : _TradingViewPalette.body,
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
                    style: const TextStyle(color: _TradingViewPalette.muted, fontSize: 11),
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
                    style: TextStyle(color: _TradingViewPalette.ink, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -.5),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'TradingView Advanced Chart',
                    style: TextStyle(color: _TradingViewPalette.body, fontSize: 11),
                  ),
                ],
              )
            else
              const Row(
                children: [
                  Text(
                    'LIVE MARKET DATA',
                    style: TextStyle(color: _TradingViewPalette.ink, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.6),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'TradingView Advanced Chart',
                    style: TextStyle(color: _TradingViewPalette.body, fontSize: 12),
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
              child: Text('${item.ticker}  ·  ${item.name}', style: const TextStyle(color: _TradingViewPalette.ink, fontSize: 13)),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(market.ticker, style: const TextStyle(color: _TradingViewPalette.ink, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _TradingViewPalette.body),
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
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _TradingViewPalette.border)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const Text('MARKET DATA', style: TextStyle(color: _TradingViewPalette.muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8)),
            const SizedBox(width: 18),
            _item('SYMBOL', market.tradingViewSymbol),
            _item('SOURCE', 'TRADINGVIEW'),
            const Text('실시간 차트는 거래소별 지연 정책이 적용될 수 있습니다.', style: TextStyle(color: _TradingViewPalette.muted, fontSize: 9)),
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
            TextSpan(text: '$label  ', style: const TextStyle(color: _TradingViewPalette.body, fontSize: 10)),
            TextSpan(text: value, style: const TextStyle(color: _TradingViewPalette.ink, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
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
  late final AnimationController _entryController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        final horizontal = compact ? 16.0 : 36.0;
        final contentWidth = constraints.maxWidth > horizontal * 2
            ? constraints.maxWidth - horizontal * 2
            : 0.0;
        final metricColumns = constraints.maxWidth < 560
            ? 1
            : constraints.maxWidth < 980
                ? 2
                : 4;
        final metricWidth =
            (contentWidth - (metricColumns - 1) * 12) / metricColumns;
        final assetColumns = constraints.maxWidth < 560
            ? 1
            : constraints.maxWidth < 1100
                ? 2
                : 4;
        final assetWidth =
            (contentWidth - (assetColumns - 1) * 12) / assetColumns;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, compact ? 18 : 30, horizontal, 44),
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[
              _entryController,
              _pulseController,
            ]),
            builder: (context, child) {
              final entryProgress =
                  Curves.easeOutCubic.transform(_entryController.value);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: 0,
                    child: _TradingViewIntroHero(
                      compact: compact,
                      entryProgress: entryProgress,
                      pulseProgress: _pulseController.value,
                      onOpenChart: widget.onOpenChart,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _TradingViewIntroReveal(
                        animation: _entryController,
                        delay: .10,
                        child: SizedBox(
                          width: metricWidth,
                          child: const _TradingViewIntroMetric(
                            value: '04',
                            label: 'TRACKED ASSETS',
                            detail: '핵심 관심 종목',
                          ),
                        ),
                      ),
                      _TradingViewIntroReveal(
                        animation: _entryController,
                        delay: .16,
                        child: SizedBox(
                          width: metricWidth,
                          child: const _TradingViewIntroMetric(
                            value: '02',
                            label: 'MARKET TYPES',
                            detail: 'CRYPTO + EQUITY-LINKED',
                          ),
                        ),
                      ),
                      _TradingViewIntroReveal(
                        animation: _entryController,
                        delay: .22,
                        child: SizedBox(
                          width: metricWidth,
                          child: const _TradingViewIntroMetric(
                            value: 'LIVE',
                            label: 'TRADINGVIEW FEED',
                            detail: '인터랙티브 차트',
                          ),
                        ),
                      ),
                      _TradingViewIntroReveal(
                        animation: _entryController,
                        delay: .28,
                        child: SizedBox(
                          width: metricWidth,
                          child: const _TradingViewIntroMetric(
                            value: 'NEXT',
                            label: 'CUSTOM STUDIES',
                            detail: '보조지표 6종 확장',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: .20,
                    child: const _TradingViewIntroSectionHeading(
                      kicker: 'MARKET UNIVERSE',
                      title: '네 개의 시장, 하나의 시야.',
                      detail: '04 ASSETS / ONE WORKSPACE',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...TradingViewMarket.markets.asMap().entries.map(
                            (entry) => _TradingViewIntroReveal(
                              animation: _entryController,
                              delay: .34 + entry.key * .06,
                              child: SizedBox(
                                width: assetWidth,
                                child: _TradingViewIntroMarketCard(
                                  index: entry.key + 1,
                                  market: entry.value,
                                  onTap: widget.onOpenChart,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: .42,
                    child: const _TradingViewIntroSectionHeading(
                      kicker: 'WHY PULSE',
                      title: '결정에 필요한 정보만 남깁니다.',
                      detail: 'BUILT FOR CLARITY',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: assetWidth,
                        child: const _TradingViewIntroFeature(
                          icon: Icons.query_stats_rounded,
                          number: '01',
                          title: 'LIVE CHART ENGINE',
                          body:
                              'TradingView Advanced Chart의 확대, 이동, 시간봉 전환을 한 화면에서 사용합니다.',
                        ),
                      ),
                      SizedBox(
                        width: assetWidth,
                        child: const _TradingViewIntroFeature(
                          icon: Icons.grid_view_rounded,
                          number: '02',
                          title: 'CURATED UNIVERSE',
                          body:
                              'Bitcoin과 Ethereum, 삼성전자·SK하이닉스 추종 선물을 핵심 워치리스트로 구성했습니다.',
                        ),
                      ),
                      SizedBox(
                        width: assetWidth,
                        child: const _TradingViewIntroFeature(
                          icon: Icons.devices_rounded,
                          number: '03',
                          title: 'RESPONSIVE SHELL',
                          body:
                              '데스크톱, 태블릿, 모바일에서 메뉴와 차트 영역이 자연스럽게 재배치됩니다.',
                        ),
                      ),
                      SizedBox(
                        width: assetWidth,
                        child: const _TradingViewIntroFeature(
                          icon: Icons.auto_graph_rounded,
                          number: '04',
                          title: 'STUDY-READY',
                          body:
                              '다음 확장 단계에서 자체 제작 보조지표 6종을 차트 워크스페이스에 연결할 수 있습니다.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: .54,
                    child: _TradingViewIntroWorkflow(
                      compact: compact,
                      onOpenChart: widget.onOpenChart,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '실시간 시세와 상품 이용 가능 여부는 TradingView 및 거래소 정책과 지역 제한의 영향을 받을 수 있습니다.',
                    style: TextStyle(
                      color: _TradingViewPalette.muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _TradingViewIntroReveal extends StatelessWidget {
  const _TradingViewIntroReveal({
    required this.animation,
    required this.delay,
    required this.child,
  });

  final Animation<double> animation;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reveal = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, 1, curve: Curves.easeOutCubic),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(reveal);

    return FadeTransition(
      opacity: reveal,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _TradingViewIntroHero extends StatelessWidget {
  const _TradingViewIntroHero({
    required this.compact,
    required this.entryProgress,
    required this.pulseProgress,
    required this.onOpenChart,
  });

  final bool compact;
  final double entryProgress;
  final double pulseProgress;
  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    final heroPadding = compact ? 22.0 : 36.0;
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 620 : 330),
      decoration: const BoxDecoration(
        color: _TradingViewPalette.ink,
        border: Border(
          left: BorderSide(color: _TradingViewPalette.green, width: 4),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TradingViewSignalPainter(
                progress: pulseProgress,
                intensity: entryProgress,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xf217191d),
                    const Color(0x9017191d),
                    const Color(0x2417191d),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(heroPadding),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TradingViewHeroEyebrow(),
                      const SizedBox(height: 24),
                      _TradingViewHeroCopy(
                        compact: compact,
                        onOpenChart: onOpenChart,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 205,
                        child: _TradingViewHeroTerminal(
                          progress: pulseProgress,
                          compact: compact,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _TradingViewHeroEyebrow(),
                            const SizedBox(height: 24),
                            _TradingViewHeroCopy(
                              compact: compact,
                              onOpenChart: onOpenChart,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      SizedBox(
                        width: 320,
                        height: 205,
                        child: _TradingViewHeroTerminal(
                          progress: pulseProgress,
                          compact: compact,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TradingViewHeroEyebrow extends StatelessWidget {
  const _TradingViewHeroEyebrow();

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
              color: _TradingViewPalette.green,
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

class _TradingViewHeroCopy extends StatelessWidget {
  const _TradingViewHeroCopy({
    required this.compact,
    required this.onOpenChart,
  });

  final bool compact;
  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시장의 흐름을\n한 박자 먼저 읽다.',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 34 : 42,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          '복잡한 가격 데이터는 정리하고,\n차트에서 확인해야 할 신호에 집중합니다.',
          style: TextStyle(
            color: Color(0xffb7bec1),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: compact ? double.infinity : null,
          child: ElevatedButton.icon(
            onPressed: onOpenChart,
            icon: const Icon(Icons.arrow_outward_rounded, size: 17),
            label: const Text('차트 열기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _TradingViewPalette.green,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TradingViewHeroTerminal extends StatelessWidget {
  const _TradingViewHeroTerminal({
    required this.progress,
    required this.compact,
  });

  final double progress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xb5080d0e),
        border: Border.all(color: const Color(0x60767d7f)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'SIGNAL PREVIEW',
                style: TextStyle(
                  color: Color(0xffe9edef),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                color: const Color(0x2200de5a),
                child: const Text(
                  'LIVE LAYER',
                  style: TextStyle(
                    color: _TradingViewPalette.green,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _TradingViewSignalPainter(
                progress: progress,
                intensity: compact ? .8 : 1,
                mini: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                'VOLATILITY MAP',
                style: TextStyle(
                  color: Color(0xff8f999b),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .8,
                ),
              ),
              Spacer(),
              Text(
                'SIGNAL PREVIEW',
                style: TextStyle(
                  color: Color(0xff8f999b),
                  fontSize: 8,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TradingViewSignalPainter extends CustomPainter {
  const _TradingViewSignalPainter({
    required this.progress,
    required this.intensity,
    this.mini = false,
  });

  final double progress;
  final double intensity;
  final bool mini;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final gridPaint = Paint()
      ..color = mini ? const Color(0x1cffffff) : const Color(0x16ffffff)
      ..strokeWidth = 1;
    for (var index = 1; index < 6; index++) {
      final y = size.height * index / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var index = 1; index < 9; index++) {
      final x = size.width * index / 9;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    const coordinates = <Offset>[
      Offset(0, .72),
      Offset(.08, .68),
      Offset(.15, .74),
      Offset(.22, .54),
      Offset(.30, .60),
      Offset(.38, .44),
      Offset(.46, .49),
      Offset(.54, .32),
      Offset(.62, .39),
      Offset(.70, .25),
      Offset(.78, .29),
      Offset(.86, .15),
      Offset(1, .20),
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
        ..shader = LinearGradient(
          colors: [
            const Color(0x4200de5a),
            const Color(0x0500de5a),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = _TradingViewPalette.green
        ..strokeWidth = mini ? 2 : 2.4
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
      Offset(scanX, size.height * .23),
      mini ? 3 : 4,
      Paint()..color = _TradingViewPalette.green,
    );
  }

  @override
  bool shouldRepaint(covariant _TradingViewSignalPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.intensity != intensity ||
        oldDelegate.mini != mini;
  }
}

class _TradingViewIntroMetric extends StatelessWidget {
  const _TradingViewIntroMetric({
    required this.value,
    required this.label,
    required this.detail,
  });

  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _TradingViewPalette.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0d000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _TradingViewPalette.ink,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -.6,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: _TradingViewPalette.label,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            style: const TextStyle(
              color: _TradingViewPalette.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _TradingViewIntroSectionHeading extends StatelessWidget {
  const _TradingViewIntroSectionHeading({
    required this.kicker,
    required this.title,
    required this.detail,
  });

  final String kicker;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kicker,
                style: const TextStyle(
                  color: _TradingViewPalette.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  color: _TradingViewPalette.ink,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Text(
          detail,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: _TradingViewPalette.muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
      ],
    );
  }
}

class _TradingViewIntroMarketCard extends StatefulWidget {
  const _TradingViewIntroMarketCard({
    required this.index,
    required this.market,
    required this.onTap,
  });

  final int index;
  final TradingViewMarket market;
  final VoidCallback onTap;

  @override
  State<_TradingViewIntroMarketCard> createState() =>
      _TradingViewIntroMarketCardState();
}

class _TradingViewIntroMarketCardState
    extends State<_TradingViewIntroMarketCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -.035) : Offset.zero,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _hovered
                    ? _TradingViewPalette.green
                    : _TradingViewPalette.border,
              ),
              boxShadow: _hovered
                  ? const [
                      BoxShadow(
                        color: Color(0x1a000000),
                        offset: Offset(0, 8),
                        blurRadius: 18,
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x0d000000),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  color: _hovered
                      ? _TradingViewPalette.green
                      : const Color(0xffeef1f2),
                  child: Text(
                    widget.index.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: _TradingViewPalette.ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.market.ticker,
                        style: const TextStyle(
                          color: _TradingViewPalette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.market.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _TradingViewPalette.body,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.market.tradingViewSymbol,
                        style: const TextStyle(
                          color: _TradingViewPalette.muted,
                          fontSize: 9,
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: _TradingViewPalette.body,
                    ),
                    const SizedBox(height: 11),
                    Text(
                      widget.market.exchange,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _TradingViewPalette.muted,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TradingViewIntroFeature extends StatelessWidget {
  const _TradingViewIntroFeature({
    required this.icon,
    required this.number,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 178),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _TradingViewPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                color: _TradingViewPalette.ink,
                child: Icon(icon, color: _TradingViewPalette.green, size: 16),
              ),
              const Spacer(),
              Text(
                number,
                style: const TextStyle(
                  color: _TradingViewPalette.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: _TradingViewPalette.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: _TradingViewPalette.body,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TradingViewIntroWorkflow extends StatelessWidget {
  const _TradingViewIntroWorkflow({
    required this.compact,
    required this.onOpenChart,
  });

  final bool compact;
  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    final steps = [
      const _TradingViewIntroStep(
        number: '01',
        title: '종목을 고릅니다',
        body: '차트 메뉴에서 관심 자산을 선택하세요.',
      ),
      const _TradingViewIntroStep(
        number: '02',
        title: '시간을 바꿉니다',
        body: '시간봉과 확대 도구는 TradingView 내부에서 조작합니다.',
      ),
      const _TradingViewIntroStep(
        number: '03',
        title: '신호를 쌓습니다',
        body: '다음 업데이트에서 자체 보조지표 6종을 연결합니다.',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(compact ? 20 : 26),
      color: _TradingViewPalette.ink,
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TradingViewWorkflowIntro(onOpenChart: onOpenChart),
                const SizedBox(height: 24),
                ...steps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: step,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _TradingViewWorkflowIntro(onOpenChart: onOpenChart),
                ),
                const SizedBox(width: 30),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      for (var index = 0; index < steps.length; index++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index == steps.length - 1 ? 0 : 14,
                          ),
                          child: steps[index],
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _TradingViewWorkflowIntro extends StatelessWidget {
  const _TradingViewWorkflowIntro({required this.onOpenChart});

  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FROM OVERVIEW TO ACTION',
          style: TextStyle(
            color: _TradingViewPalette.green,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '다음 차트를\n지금 확인하세요.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '관심 종목과 차트 도구를 한곳에 모아, 시장을 보는 루틴을 짧게 만듭니다.',
          style: TextStyle(
            color: Color(0xffaab3b5),
            fontSize: 11,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onOpenChart,
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: const Text('워크스페이스 진입'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0x73848c8e)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TradingViewIntroStep extends StatelessWidget {
  const _TradingViewIntroStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Color(0x6600de5a), width: 2),
        ),
        color: Color(0x14000000),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: _TradingViewPalette.green,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xff9ba5a7),
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TradingViewChartCard extends StatelessWidget {
  const _TradingViewChartCard({required this.market});

  final TradingViewMarket market;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _TradingViewPalette.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'ADVANCED CHART',
                style: TextStyle(color: _TradingViewPalette.label, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .7),
              ),
              const SizedBox(width: 8),
              Text(
                market.tradingViewSymbol,
                style: const TextStyle(color: _TradingViewPalette.muted, fontSize: 10),
              ),
              const Spacer(),
              const Icon(Icons.open_with_rounded, size: 15, color: _TradingViewPalette.muted),
              const SizedBox(width: 6),
              const Text('TradingView에서 시간봉 선택', style: TextStyle(color: _TradingViewPalette.muted, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: TradingViewChart(
              key: ValueKey(market.tradingViewSymbol),
              symbol: market.tradingViewSymbol,
              interval: 'D',
            ),
          ),
        ],
      ),
    );
  }
}
