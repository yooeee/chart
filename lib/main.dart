import 'package:flutter/material.dart';

import 'models/market_data.dart';
import 'widgets/market_chart.dart';

void main() {
  runApp(const PulseChartApp());
}

class PulseChartApp extends StatelessWidget {
  const PulseChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Chart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _Palette.canvas,
        fontFamily: 'Malgun Gothic',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _Palette.green,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _Palette.green,
          selectionColor: Color(0x4400de5a),
          selectionHandleColor: _Palette.green,
        ),
      ),
      home: const ChartWorkspacePage(),
    );
  }
}

class _Palette {
  static const green = Color(0xff00de5a);
  static const ink = Color(0xff17191d);
  static const nearBlack = Color(0xff080410);
  static const body = Color(0xff737881);
  static const label = Color(0xff4a4e57);
  static const muted = Color(0xff919191);
  static const disabled = Color(0xff9fa1a7);
  static const canvas = Color(0xfff5f7f8);
  static const border = Color(0xffe6e9eb);
}

class ChartWorkspacePage extends StatefulWidget {
  const ChartWorkspacePage({super.key});

  @override
  State<ChartWorkspacePage> createState() => _ChartWorkspacePageState();
}

class _ChartWorkspacePageState extends State<ChartWorkspacePage> {
  String _selectedTicker = 'NEXON';
  String _selectedRange = '1D';
  late List<MarketBar> _bars;
  Set<IndicatorKind> _activeIndicators = <IndicatorKind>{
    IndicatorKind.trendRibbon,
    IndicatorKind.bollingerSqueeze,
  };

  @override
  void initState() {
    super.initState();
    _bars = DemoMarketDataSource.barsFor(_selectedTicker);
  }

  MarketSymbol get _symbol => DemoMarketDataSource.symbolFor(_selectedTicker);
  double get _lastPrice => _bars.last.close;
  double get _lastChange => (_bars.last.close / _bars[_bars.length - 2].close - 1) * 100;

  void _selectTicker(String ticker) {
    setState(() {
      _selectedTicker = ticker;
      _bars = DemoMarketDataSource.barsFor(ticker);
    });
  }

  void _toggleIndicator(IndicatorKind kind) {
    final next = <IndicatorKind>{..._activeIndicators};
    if (!next.add(kind)) next.remove(kind);
    setState(() => _activeIndicators = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _TopNavigation(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 980;
                  return isDesktop ? _desktopLayout() : _mobileLayout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          _WorkspaceHeader(
            symbol: _symbol,
            lastPrice: _lastPrice,
            lastChange: _lastChange,
            selectedRange: _selectedRange,
            onTickerChanged: _selectTicker,
            onRangeChanged: (range) => setState(() => _selectedRange = range),
          ),
          const SizedBox(height: 12),
          const _MarketTickerStrip(),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ChartCard(
                    bars: _bars,
                    activeIndicators: _activeIndicators,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 310,
                  child: _IndicatorPanel(
                    activeIndicators: _activeIndicators,
                    onToggle: _toggleIndicator,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WorkspaceHeader(
            symbol: _symbol,
            lastPrice: _lastPrice,
            lastChange: _lastChange,
            selectedRange: _selectedRange,
            onTickerChanged: _selectTicker,
            onRangeChanged: (range) => setState(() => _selectedRange = range),
          ),
          const SizedBox(height: 10),
          const _MarketTickerStrip(),
          const SizedBox(height: 12),
          SizedBox(
            height: 510,
            child: _ChartCard(
              bars: _bars,
              activeIndicators: _activeIndicators,
            ),
          ),
          const SizedBox(height: 12),
          _IndicatorPanel(
            activeIndicators: _activeIndicators,
            onToggle: _toggleIndicator,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _Palette.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          return Row(
            children: [
              if (compact)
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: _Palette.ink),
                  onPressed: () {},
                  tooltip: '메뉴',
                ),
              const _BrandMark(),
              if (!compact) ...[
                const SizedBox(width: 42),
                const _NavItem(label: '차트', active: true),
                const _NavItem(label: '시장'),
                const _NavItem(label: '스크리너'),
              ],
              const Spacer(),
              if (!compact) ...[
                _TopAction(icon: Icons.notifications_none_rounded, onPressed: () {}),
                const SizedBox(width: 8),
                const _StatusBadge(),
                const SizedBox(width: 16),
              ],
              const _Avatar(),
            ],
          );
        },
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          color: _Palette.green,
          child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 18),
        ),
        const SizedBox(width: 9),
        const Text(
          'PULSE',
          style: TextStyle(
            color: _Palette.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'MARKET LAB',
          style: TextStyle(color: _Palette.muted, fontSize: 9, letterSpacing: 1.1),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: active ? _Palette.green : Colors.transparent, width: 3)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: active ? _Palette.ink : _Palette.body,
          fontSize: 14,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: _Palette.body),
      tooltip: '알림',
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: const Color(0xffeefaf2),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: _Palette.green, shape: BoxShape.circle))),
          SizedBox(width: 6),
          Text('DEMO FEED', style: TextStyle(color: _Palette.label, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .6)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      color: _Palette.ink,
      child: const Text('YE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.symbol,
    required this.lastPrice,
    required this.lastChange,
    required this.selectedRange,
    required this.onTickerChanged,
    required this.onRangeChanged,
  });

  final MarketSymbol symbol;
  final double lastPrice;
  final double lastChange;
  final String selectedRange;
  final ValueChanged<String> onTickerChanged;
  final ValueChanged<String> onRangeChanged;

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
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TickerSelector(selectedTicker: symbol.ticker, onChanged: onTickerChanged),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(symbol.exchange, style: const TextStyle(color: _Palette.muted, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                if (!compact) _RangeSelector(selectedRange: selectedRange, onChanged: onRangeChanged),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Text(
                  _priceText(lastPrice),
                  style: const TextStyle(color: _Palette.ink, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1),
                ),
                const SizedBox(width: 12),
                Text(
                  '${lastChange >= 0 ? '+' : ''}${lastChange.toStringAsFixed(2)}%',
                  style: TextStyle(color: lastChange >= 0 ? _Palette.green : const Color(0xffd94d5b), fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                const Text('today', style: TextStyle(color: _Palette.muted, fontSize: 11)),
                if (compact) ...[
                  const Spacer(),
                  _RangeSelector(selectedRange: selectedRange, onChanged: onRangeChanged),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TickerSelector extends StatelessWidget {
  const _TickerSelector({required this.selectedTicker, required this.onChanged});

  final String selectedTicker;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedTicker,
      onSelected: onChanged,
      color: Colors.white,
      elevation: 3,
      itemBuilder: (context) => DemoMarketDataSource.symbols
          .map((symbol) => PopupMenuItem<String>(
                value: symbol.ticker,
                height: 40,
                child: Text('${symbol.ticker}  ·  ${symbol.name}', style: const TextStyle(color: _Palette.ink, fontSize: 13)),
              ))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedTicker, style: const TextStyle(color: _Palette.ink, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _Palette.body),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selectedRange, required this.onChanged});

  final String selectedRange;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const ranges = ['1D', '1W', '1M', '3M', '1Y'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ranges
          .map(
            (range) => InkWell(
              onTap: () => onChanged(range),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: range == selectedRange ? _Palette.green : Colors.transparent,
                child: Text(
                  range,
                  style: TextStyle(color: range == selectedRange ? Colors.black : _Palette.muted, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MarketTickerStrip extends StatelessWidget {
  const _MarketTickerStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final items = <Widget>[
          const Text('MARKET PULSE', style: TextStyle(color: _Palette.muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8)),
          const SizedBox(width: 18),
          _ticker('KOSPI', '+0.82%', true),
          _ticker('KOSDAQ', '+1.14%', true),
          _ticker('NASDAQ', '+0.46%', true),
          _ticker('USD/KRW', '1,386.40', false),
          if (!compact) ...[
            const Spacer(),
            const Text('LAST UPDATE  14:28:05', style: TextStyle(color: _Palette.muted, fontSize: 9, letterSpacing: .3)),
          ],
        ];
        final row = Row(children: items);
        return Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _Palette.border)),
          child: compact
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: row,
                )
              : row,
        );
      },
    );
  }

  Widget _ticker(String label, String value, bool positive) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label  ', style: const TextStyle(color: _Palette.body, fontSize: 10)),
            TextSpan(text: value, style: TextStyle(color: positive ? _Palette.green : _Palette.ink, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.bars, required this.activeIndicators});

  final List<MarketBar> bars;
  final Set<IndicatorKind> activeIndicators;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _Palette.border),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('CANDLESTICK', style: TextStyle(color: _Palette.label, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .7)),
              const SizedBox(width: 8),
              const Text('Daily', style: TextStyle(color: _Palette.muted, fontSize: 10)),
              const Spacer(),
              const Icon(Icons.open_with_rounded, size: 15, color: _Palette.muted),
              const SizedBox(width: 6),
              const Text('pinch to zoom', style: TextStyle(color: _Palette.muted, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(child: MarketChart(bars: bars, activeIndicators: activeIndicators)),
        ],
      ),
    );
  }
}

class _IndicatorPanel extends StatelessWidget {
  const _IndicatorPanel({required this.activeIndicators, required this.onToggle, this.compact = false});

  final Set<IndicatorKind> activeIndicators;
  final ValueChanged<IndicatorKind> onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _Palette.border),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('SIGNALS', style: TextStyle(color: _Palette.ink, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: .6))),
              Container(color: _Palette.green, padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), child: const Text('06 TOOLS', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 5),
          const Text('차트에 표시할 분석 도구를 선택하세요.', style: TextStyle(color: _Palette.body, fontSize: 11)),
          const SizedBox(height: 14),
          _indicatorList(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xfff7f8f8),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: _Palette.muted),
                SizedBox(width: 7),
                Expanded(child: Text('현재는 데모 데이터입니다. 실제 시세 연결 시 신호 계산 모듈은 그대로 재사용할 수 있습니다.', style: TextStyle(color: _Palette.body, fontSize: 10, height: 1.35))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicatorList() {
    final list = ListView.separated(
      shrinkWrap: compact,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      itemCount: IndicatorKind.values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final kind = IndicatorKind.values[index];
        return _IndicatorTile(
          kind: kind,
          selected: activeIndicators.contains(kind),
          onTap: () => onToggle(kind),
        );
      },
    );
    return compact ? list : Expanded(child: list);
  }
}

class _IndicatorTile extends StatelessWidget {
  const _IndicatorTile({required this.kind, required this.selected, required this.onTap});

  final IndicatorKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xfff1fcf5) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: selected ? _Palette.green : _Palette.border, width: selected ? 3 : 1),
              top: const BorderSide(color: _Palette.border),
              right: const BorderSide(color: _Palette.border),
              bottom: const BorderSide(color: _Palette.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kind.label, style: const TextStyle(color: _Palette.ink, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(kind.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _Palette.body, fontSize: 9, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Icon(selected ? Icons.visibility_rounded : Icons.visibility_off_outlined, color: selected ? _Palette.green : _Palette.disabled, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

String _priceText(double value) => value >= 1000 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
