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
      ticker: 'SAMSUNG',
      name: '삼성전자',
      exchange: 'KRX',
      tradingViewSymbol: 'KRX:005930',
    ),
    TradingViewMarket(
      ticker: 'BTCUSD',
      name: 'Bitcoin',
      exchange: 'BINANCE',
      tradingViewSymbol: 'BINANCE:BTCUSDT',
    ),
    TradingViewMarket(
      ticker: 'NAVER',
      name: 'NAVER',
      exchange: 'KRX',
      tradingViewSymbol: 'KRX:035420',
    ),
    TradingViewMarket(
      ticker: 'NVDA',
      name: 'NVIDIA',
      exchange: 'NASDAQ',
      tradingViewSymbol: 'NASDAQ:NVDA',
    ),
    TradingViewMarket(
      ticker: 'NEXON',
      name: 'NEXON Games',
      exchange: 'KRX',
      tradingViewSymbol: 'KRX:225570',
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
  String _selectedInterval = 'D';

  void _selectMarket(TradingViewMarket market) {
    setState(() => _selectedMarket = market);
  }

  void _selectInterval(String interval) {
    setState(() => _selectedInterval = interval);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TradingViewPalette.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const _TradingViewTopNavigation(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(compact ? 12 : 24, compact ? 12 : 20, compact ? 12 : 24, compact ? 16 : 24),
                    child: Column(
                      children: [
                        _TradingViewWorkspaceHeader(
                          market: _selectedMarket,
                          selectedInterval: _selectedInterval,
                          onMarketChanged: _selectMarket,
                          onIntervalChanged: _selectInterval,
                        ),
                        const SizedBox(height: 12),
                        _TradingViewMarketStrip(market: _selectedMarket),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _TradingViewChartCard(
                            market: _selectedMarket,
                            interval: _selectedInterval,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
  const _TradingViewTopNavigation();

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
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: _TradingViewPalette.ink),
                  onPressed: () {},
                  tooltip: '메뉴',
                ),
              const _TradingViewBrandMark(),
              if (!compact) ...[
                const SizedBox(width: 42),
                const _TradingViewNavItem(label: '차트', active: true),
                const _TradingViewNavItem(label: '시장'),
                const _TradingViewNavItem(label: '스크리너'),
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
  const _TradingViewNavItem({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: active ? _TradingViewPalette.green : Colors.transparent, width: 3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: active ? _TradingViewPalette.ink : _TradingViewPalette.body, fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w400),
      ),
    );
  }
}

class _TradingViewWorkspaceHeader extends StatelessWidget {
  const _TradingViewWorkspaceHeader({
    required this.market,
    required this.selectedInterval,
    required this.onMarketChanged,
    required this.onIntervalChanged,
  });

  final TradingViewMarket market;
  final String selectedInterval;
  final ValueChanged<TradingViewMarket> onMarketChanged;
  final ValueChanged<String> onIntervalChanged;

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
                      _TradingViewMarketSelector(market: market, onChanged: onMarketChanged),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(market.exchange, style: const TextStyle(color: _TradingViewPalette.muted, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                if (!compact) _TradingViewIntervalSelector(selectedInterval: selectedInterval, onChanged: onIntervalChanged),
              ],
            ),
            const SizedBox(height: 7),
            if (compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('LIVE MARKET DATA', style: TextStyle(color: _TradingViewPalette.ink, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Expanded(child: Text('TradingView Advanced Chart', style: TextStyle(color: _TradingViewPalette.body, fontSize: 11))),
                      _TradingViewIntervalSelector(selectedInterval: selectedInterval, onChanged: onIntervalChanged),
                    ],
                  ),
                ],
              )
            else
              const Row(
                children: [
                  Text('LIVE MARKET DATA', style: TextStyle(color: _TradingViewPalette.ink, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.6)),
                  SizedBox(width: 12),
                  Text('TradingView Advanced Chart', style: TextStyle(color: _TradingViewPalette.body, fontSize: 12)),
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

class _TradingViewIntervalSelector extends StatelessWidget {
  const _TradingViewIntervalSelector({required this.selectedInterval, required this.onChanged});

  final String selectedInterval;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const intervals = <MapEntry<String, String>>[
      MapEntry('15분', '15'),
      MapEntry('1시간', '60'),
      MapEntry('일봉', 'D'),
      MapEntry('주봉', 'W'),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: intervals
          .map(
            (interval) => InkWell(
              onTap: () => onChanged(interval.value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                color: interval.value == selectedInterval ? _TradingViewPalette.green : Colors.transparent,
                child: Text(interval.key, style: TextStyle(color: interval.value == selectedInterval ? Colors.black : _TradingViewPalette.muted, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ),
          )
          .toList(),
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

class _TradingViewChartCard extends StatelessWidget {
  const _TradingViewChartCard({required this.market, required this.interval});

  final TradingViewMarket market;
  final String interval;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _TradingViewPalette.border),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('ADVANCED CHART', style: TextStyle(color: _TradingViewPalette.label, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .7)),
              const SizedBox(width: 8),
              Text(market.tradingViewSymbol, style: const TextStyle(color: _TradingViewPalette.muted, fontSize: 10)),
              const Spacer(),
              const Icon(Icons.open_with_rounded, size: 15, color: _TradingViewPalette.muted),
              const SizedBox(width: 6),
              const Text('drag / zoom', style: TextStyle(color: _TradingViewPalette.muted, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: TradingViewChart(
              key: ValueKey('${market.tradingViewSymbol}-$interval'),
              symbol: market.tradingViewSymbol,
              interval: interval,
            ),
          ),
        ],
      ),
    );
  }
}
