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
  static const _studies = <_TradingViewStudyPreviewData>[
    _TradingViewStudyPreviewData(
      number: '01',
      category: 'TREND / OVERLAY',
      title: 'Adaptive Trend Ribbon',
      shortCode: 'TREND',
      formula: 'EMA 21 / EMA 55',
      summary: 'EMA 21과 EMA 55의 방향과 간격으로 추세의 결을 읽습니다.',
      reading:
          '두 평균선의 기울기와 간격이 같은 방향으로 움직이는지 먼저 확인합니다.',
      mode: 0,
      accent: _TradingViewPalette.green,
    ),
    _TradingViewStudyPreviewData(
      number: '02',
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
      number: '03',
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
      number: '04',
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
      number: '05',
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
      number: '06',
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

  late final AnimationController _entryController;
  late final AnimationController _motionController;
  final GlobalKey _studyViewportKey = GlobalKey();
  final List<GlobalKey> _studyKeys = List<GlobalKey>.generate(
    _studies.length,
    (_) => GlobalKey(),
  );
  final Set<int> _revealedStudies = <int>{0};
  int _activeStudyIndex = 0;
  bool _measureScheduled = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..forward();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scheduleStudyMeasure(),
    );
  }

  bool _handleStudyScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      _scheduleStudyMeasure();
    }
    return false;
  }

  void _scheduleStudyMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (mounted) _measureStudies();
    });
  }

  void _measureStudies() {
    final viewportObject =
        _studyViewportKey.currentContext?.findRenderObject();
    if (viewportObject is! RenderBox || !viewportObject.hasSize) return;

    final viewportOrigin = viewportObject.localToGlobal(Offset.zero);
    final viewportTop = viewportOrigin.dy;
    final viewportBottom = viewportTop + viewportObject.size.height;
    final focusY = viewportTop + viewportObject.size.height * .48;
    final nextRevealed = <int>{..._revealedStudies};
    var nextActive = _activeStudyIndex;
    var nearestDistance = double.infinity;
    var visibleStudyFound = false;

    for (var index = 0; index < _studyKeys.length; index++) {
      final cardObject = _studyKeys[index].currentContext?.findRenderObject();
      if (cardObject is! RenderBox || !cardObject.hasSize) continue;

      final cardOrigin = cardObject.localToGlobal(Offset.zero);
      final cardTop = cardOrigin.dy;
      final cardBottom = cardTop + cardObject.size.height;
      final isVisible = cardBottom > viewportTop + 28 &&
          cardTop < viewportBottom - 28;
      if (!isVisible) continue;

      visibleStudyFound = true;
      nextRevealed.add(index);
      final cardCenter = (cardTop + cardBottom) / 2;
      final distance = (cardCenter - focusY).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nextActive = index;
      }
    }

    if (!visibleStudyFound) return;
    final revealChanged = nextRevealed.length != _revealedStudies.length;
    if (revealChanged || nextActive != _activeStudyIndex) {
      setState(() {
        _revealedStudies
          ..clear()
          ..addAll(nextRevealed);
        _activeStudyIndex = nextActive;
      });
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _motionController.dispose();
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
        final lensColumns = constraints.maxWidth < 620 ? 1 : 3;
        final lensWidth =
            (contentWidth - (lensColumns - 1) * 12) / lensColumns;

        return SizedBox.expand(
          key: _studyViewportKey,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleStudyScroll,
            child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            compact ? 18 : 30,
            horizontal,
            46,
          ),
          child: AnimatedBuilder(
            animation: _motionController,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: 0,
                    child: _TradingViewStudiesHero(
                      compact: compact,
                      entryProgress: Curves.easeOutCubic
                          .transform(_entryController.value),
                      pulseProgress: _motionController.value,
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
                            value: '06',
                            label: 'CUSTOM STUDIES',
                            detail: '차트 신호 레이어',
                          ),
                        ),
                      ),
                      _TradingViewIntroReveal(
                        animation: _entryController,
                        delay: .15,
                        child: SizedBox(
                          width: metricWidth,
                          child: const _TradingViewIntroMetric(
                            value: '02',
                            label: 'OVERLAY LAYERS',
                            detail: '가격 위에 겹쳐 읽기',
                          ),
                        ),
                      ),
                      _TradingViewIntroReveal(
                        animation: _entryController,
                        delay: .20,
                        child: SizedBox(
                          width: metricWidth,
                          child: const _TradingViewIntroMetric(
                            value: '04',
                            label: 'SIGNAL PANELS',
                            detail: '모멘텀·거래량·흐름',
                          ),
                        ),
                      ),
                      _TradingViewIntroReveal(
                        animation: _entryController,
                        delay: .25,
                        child: SizedBox(
                          width: metricWidth,
                          child: const _TradingViewIntroMetric(
                            value: 'ONE',
                            label: 'READING SYSTEM',
                            detail: '한 화면에서 이어보기',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: .18,
                    child: const _TradingViewIntroSectionHeading(
                      kicker: 'STUDY LIBRARY',
                      title: '여섯 개의 신호를 한 흐름으로.',
                      detail: '06 STUDIES / VISUAL GUIDE',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: lensWidth,
                        child: const _TradingViewStudyLensCard(
                          label: '01 / DIRECTION',
                          title: '추세',
                          body: '가격이 어느 방향으로 움직이는지 먼저 확인합니다.',
                          icon: Icons.north_east_rounded,
                        ),
                      ),
                      SizedBox(
                        width: lensWidth,
                        child: const _TradingViewStudyLensCard(
                          label: '02 / ENERGY',
                          title: '모멘텀',
                          body: '방향에 힘이 붙는지, 약해지는지 살펴봅니다.',
                          icon: Icons.bolt_rounded,
                        ),
                      ),
                      SizedBox(
                        width: lensWidth,
                        child: const _TradingViewStudyLensCard(
                          label: '03 / PARTICIPATION',
                          title: '변동성·흐름',
                          body: '움직임의 폭과 거래량이 함께 말하는 내용을 읽습니다.',
                          icon: Icons.radar_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: .26,
                    child: _TradingViewStudyProgress(
                      compact: compact,
                      activeIndex: _activeStudyIndex,
                    ),
                  ),
                  const SizedBox(height: 42),
                  for (var index = 0; index < _studies.length; index++)
                    Padding(
                      key: _studyKeys[index],
                      padding: EdgeInsets.only(
                        bottom: index == _studies.length - 1 ? 0 : 14,
                      ),
                      child: _TradingViewIntroReveal(
                        animation: _entryController,
                        delay: .30 + index * .055,
                        child: _TradingViewStudyCard(
                          data: _studies[index],
                          compact: compact,
                          pulseProgress: _motionController.value,
                          revealed: _revealedStudies.contains(index),
                          active: _activeStudyIndex == index,
                        ),
                      ),
                    ),
                  const SizedBox(height: 46),
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: .55,
                    child: const _TradingViewIntroSectionHeading(
                      kicker: 'READING FLOW',
                      title: '하나씩 보고, 마지막에 겹쳐 읽습니다.',
                      detail: 'A SIMPLE STUDY ROUTINE',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: .62,
                    child: _TradingViewStudyReadingFlow(
                      compact: compact,
                      onOpenChart: widget.onOpenChart,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _TradingViewIntroReveal(
                    animation: _entryController,
                    delay: .70,
                    child: _TradingViewStudyCta(
                      compact: compact,
                      onOpenChart: widget.onOpenChart,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '소개용 미니 차트는 지표의 구조와 읽는 순서를 설명하기 위한 개념 그래픽입니다. 실제 시세 차트는 차트 메뉴의 TradingView 위젯에서 제공합니다.',
                    style: TextStyle(
                      color: _TradingViewPalette.muted,
                      fontSize: 10,
                      height: 1.45,
                    ),
                  ),
                ],
              );
            },
              ),
            ),
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
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(reveal);

    return FadeTransition(
      opacity: Tween<double>(begin: .72, end: 1).animate(reveal),
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _TradingViewStudiesHero extends StatelessWidget {
  const _TradingViewStudiesHero({
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
    return SizedBox(
      height: compact ? 560 : 420,
      child: Container(
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
                painter: _TradingViewStudyHeroPainter(
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
                      const Color(0xb417191d),
                      const Color(0x1a17191d),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 22 : 36),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _TradingViewStudiesEyebrow(),
                        const SizedBox(height: 22),
                        _TradingViewStudiesHeroCopy(
                          compact: compact,
                          onOpenChart: onOpenChart,
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          height: 240,
                          child: _TradingViewStudySignalTerminal(
                            compact: compact,
                            progress: pulseProgress,
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
                              const _TradingViewStudiesEyebrow(),
                              const SizedBox(height: 22),
                              _TradingViewStudiesHeroCopy(
                                compact: compact,
                                onOpenChart: onOpenChart,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        SizedBox(
                          width: 330,
                          height: 250,
                          child: _TradingViewStudySignalTerminal(
                            compact: compact,
                            progress: pulseProgress,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
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
              color: _TradingViewPalette.green,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 10),
        Text(
          'PULSE / STUDY SYSTEM',
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

class _TradingViewStudiesHeroCopy extends StatelessWidget {
  const _TradingViewStudiesHeroCopy({
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
          '여섯 개의 신호로\n시장 흐름을 읽다.',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 34 : 44,
            height: 1.04,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          '추세·모멘텀·변동성·거래량을 나누어 보고,\n마지막에는 하나의 흐름으로 겹쳐 읽습니다.',
          style: TextStyle(
            color: Color(0xffb7bec1),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: compact ? double.infinity : null,
          child: ElevatedButton.icon(
            onPressed: onOpenChart,
            icon: const Icon(Icons.arrow_outward_rounded, size: 17),
            label: const Text('차트에서 사용하기'),
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

class _TradingViewStudySignalTerminal extends StatelessWidget {
  const _TradingViewStudySignalTerminal({
    required this.compact,
    required this.progress,
  });

  final bool compact;
  final double progress;

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
                'STUDY SIGNAL MAP',
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
                  'ILLUSTRATIVE',
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
          const SizedBox(height: 10),
          SizedBox(
            height: compact ? 112 : 132,
            child: CustomPaint(
              painter: _TradingViewStudyHeroPainter(
                progress: progress,
                intensity: compact ? .8 : 1,
                mini: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: _TradingViewIntroductionPageState._studies
                .map(
                  (study) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    color: const Color(0x14ffffff),
                    child: Text(
                      study.shortCode,
                      style: TextStyle(
                        color: study.accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
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
        ..color = _TradingViewPalette.green
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
      Paint()..color = _TradingViewPalette.green,
    );
  }

  @override
  bool shouldRepaint(covariant _TradingViewStudyHeroPainter oldDelegate) {
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
      height: 94,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            label,
            style: const TextStyle(
              color: _TradingViewPalette.label,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
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

class _TradingViewStudyLensCard extends StatelessWidget {
  const _TradingViewStudyLensCard({
    required this.label,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String label;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
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
                width: 28,
                height: 28,
                alignment: Alignment.center,
                color: _TradingViewPalette.ink,
                child: Icon(
                  icon,
                  color: _TradingViewPalette.green,
                  size: 15,
                ),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: _TradingViewPalette.muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: _TradingViewPalette.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _TradingViewPalette.body,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}



class _TradingViewStudyProgress extends StatelessWidget {
  const _TradingViewStudyProgress({
    required this.compact,
    required this.activeIndex,
  });

  final bool compact;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final label = Row(
      children: [
        const Text(
          'SCROLL TO EXPLORE',
          style: TextStyle(
            color: _TradingViewPalette.label,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: .9,
          ),
        ),
        const Spacer(),
        Text(
          (activeIndex + 1).toString().padLeft(2, '0') + ' / 06',
          style: const TextStyle(
            color: _TradingViewPalette.muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: .7,
          ),
        ),
      ],
    );
    final segments = Row(
      children: [
        for (var index = 0; index < 6; index++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 5 ? 0 : 5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                height: 5,
                color: index == activeIndex
                    ? _TradingViewPalette.green
                    : index < activeIndex
                        ? const Color(0x5500de5a)
                        : const Color(0xffe6e9eb),
              ),
            ),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _TradingViewPalette.border),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label,
                const SizedBox(height: 10),
                segments,
              ],
            )
          : Row(
              children: [
                Expanded(child: label),
                const SizedBox(width: 22),
                Expanded(flex: 2, child: segments),
              ],
            ),
    );
  }
}

class _TradingViewStudyCard extends StatelessWidget {
  const _TradingViewStudyCard({
    required this.data,
    required this.compact,
    required this.pulseProgress,
    required this.revealed,
    required this.active,
  });

  final _TradingViewStudyPreviewData data;
  final bool compact;
  final double pulseProgress;
  final bool revealed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final visual = SizedBox(
      width: compact ? double.infinity : 380,
      height: 238,
      child: _TradingViewStudyVisual(
        data: data,
        progress: pulseProgress,
      ),
    );
    final copy = _TradingViewStudyCopy(data: data);
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: active
              ? _TradingViewPalette.green
              : _TradingViewPalette.border,
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
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
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                visual,
                const SizedBox(height: 18),
                copy,
              ],
            )
          : data.number == '01' ||
                  data.number == '03' ||
                  data.number == '05'
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    visual,
                    const SizedBox(width: 28),
                    Expanded(child: copy),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 28),
                    visual,
                  ],
                ),
    );

    return AnimatedOpacity(
      opacity: revealed ? 1 : .18,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: revealed ? Offset.zero : const Offset(0, .08),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: card,
      ),
    );
  }
}

class _TradingViewStudyCopy extends StatelessWidget {
  const _TradingViewStudyCopy({required this.data});

  final _TradingViewStudyPreviewData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data.number,
              style: const TextStyle(
                color: _TradingViewPalette.green,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              data.category,
              style: const TextStyle(
                color: _TradingViewPalette.muted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          data.title,
          style: const TextStyle(
            color: _TradingViewPalette.ink,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data.summary,
          style: const TextStyle(
            color: _TradingViewPalette.body,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          color: const Color(0xfff1f4f5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.tune_rounded,
                color: _TradingViewPalette.label,
                size: 14,
              ),
              const SizedBox(width: 7),
              Text(
                data.formula,
                style: const TextStyle(
                  color: _TradingViewPalette.label,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'READING POINT',
          style: TextStyle(
            color: _TradingViewPalette.green,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.reading,
          style: const TextStyle(
            color: _TradingViewPalette.body,
            fontSize: 11,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
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
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ILLUSTRATIVE PREVIEW',
              style: TextStyle(
                color: _TradingViewPalette.muted,
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
        color: _TradingViewPalette.ink,
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
              'CONCEPT VISUAL',
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
          : _TradingViewPalette.green;
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
        ..color = _TradingViewPalette.green
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
    required this.number,
    required this.category,
    required this.title,
    required this.shortCode,
    required this.formula,
    required this.summary,
    required this.reading,
    required this.mode,
    required this.accent,
  });

  final String number;
  final String category;
  final String title;
  final String shortCode;
  final String formula;
  final String summary;
  final String reading;
  final int mode;
  final Color accent;
}

class _TradingViewStudyReadingFlow extends StatelessWidget {
  const _TradingViewStudyReadingFlow({
    required this.compact,
    required this.onOpenChart,
  });

  final bool compact;
  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    const steps = <_TradingViewStudyFlowStepData>[
      _TradingViewStudyFlowStepData(
        number: '01',
        title: '방향을 봅니다',
        body: 'Adaptive Trend Ribbon으로 큰 흐름을 먼저 정리합니다.',
      ),
      _TradingViewStudyFlowStepData(
        number: '02',
        title: '힘을 확인합니다',
        body: 'RSI Pulse와 MACD Momentum으로 움직임의 속도를 비교합니다.',
      ),
      _TradingViewStudyFlowStepData(
        number: '03',
        title: '참여를 겹칩니다',
        body: 'Bollinger Squeeze, Volume Pressure, Smart Flow를 함께 읽습니다.',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(compact ? 20 : 26),
      color: _TradingViewPalette.ink,
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TradingViewStudyFlowIntro(onOpenChart: onOpenChart),
                const SizedBox(height: 24),
                for (var index = 0; index < steps.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == steps.length - 1 ? 0 : 12,
                    ),
                    child: _TradingViewStudyFlowStep(data: steps[index]),
                  ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _TradingViewStudyFlowIntro(onOpenChart: onOpenChart),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      for (var index = 0; index < steps.length; index++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index == steps.length - 1 ? 0 : 12,
                          ),
                          child: _TradingViewStudyFlowStep(data: steps[index]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _TradingViewStudyFlowIntro extends StatelessWidget {
  const _TradingViewStudyFlowIntro({required this.onOpenChart});

  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FROM SIGNAL TO CONTEXT',
          style: TextStyle(
            color: _TradingViewPalette.green,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '한 개씩 확인하고,\n마지막에 겹쳐 봅니다.',
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
          '지표를 많이 켜는 것보다 각 신호가 어떤 질문에 답하는지 아는 것이 먼저입니다.',
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

class _TradingViewStudyFlowStepData {
  const _TradingViewStudyFlowStepData({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;
}

class _TradingViewStudyFlowStep extends StatelessWidget {
  const _TradingViewStudyFlowStep({required this.data});

  final _TradingViewStudyFlowStepData data;

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
            data.number,
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
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.body,
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

class _TradingViewStudyCta extends StatelessWidget {
  const _TradingViewStudyCta({
    required this.compact,
    required this.onOpenChart,
  });

  final bool compact;
  final VoidCallback onOpenChart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 20 : 26),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _TradingViewPalette.border),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _TradingViewStudyCtaCopy(),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onOpenChart,
                  icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                  label: const Text('차트 열기'),
                  style: _TradingViewStudyCtaButton.style,
                ),
              ],
            )
          : Row(
              children: [
                const Expanded(child: _TradingViewStudyCtaCopy()),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  onPressed: onOpenChart,
                  icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                  label: const Text('차트 열기'),
                  style: _TradingViewStudyCtaButton.style,
                ),
              ],
            ),
    );
  }
}

class _TradingViewStudyCtaCopy extends StatelessWidget {
  const _TradingViewStudyCtaCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'READY TO READ',
          style: TextStyle(
            color: _TradingViewPalette.green,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '신호를 직접 차트에 올려보세요.',
          style: TextStyle(
            color: _TradingViewPalette.ink,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '차트 메뉴에서 TradingView 위젯의 시간봉과 도구를 함께 사용할 수 있습니다.',
          style: TextStyle(
            color: _TradingViewPalette.body,
            fontSize: 11,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _TradingViewStudyCtaButton {
  static final style = ElevatedButton.styleFrom(
    backgroundColor: _TradingViewPalette.green,
    foregroundColor: Colors.black,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
    ),
  );
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
