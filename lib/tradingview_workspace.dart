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
                  ? const _TradingViewIntroductionPage()
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


class _TradingViewIntroductionPage extends StatelessWidget {
  const _TradingViewIntroductionPage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final horizontal = compact ? 16.0 : 36.0;
        final statWidth = compact ? constraints.maxWidth - 32 : (constraints.maxWidth - 96) / 4;
        final assetWidth = compact ? constraints.maxWidth - 32 : (constraints.maxWidth - 48) / 2;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 28, horizontal, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TradingViewIntroHero(compact: compact),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: statWidth, child: const _TradingViewIntroStat(value: '04', label: 'TRACKED MARKETS')),
                  SizedBox(width: statWidth, child: const _TradingViewIntroStat(value: '24/7', label: 'CRYPTO + TRADFI')),
                  SizedBox(width: statWidth, child: const _TradingViewIntroStat(value: 'LIVE', label: 'TRADINGVIEW FEED')),
                  SizedBox(width: statWidth, child: const _TradingViewIntroStat(value: 'NEXT', label: '6 CUSTOM STUDIES')),
                ],
              ),
              const SizedBox(height: 32),
              const Text('WHAT IS PULSE?', style: TextStyle(color: _TradingViewPalette.green, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text(
                '복잡한 시장 정보를 한 화면에 모아\n빠르게 확인하는 차트 워크스페이스',
                style: TextStyle(color: _TradingViewPalette.ink, fontSize: compact ? 24 : 32, fontWeight: FontWeight.w800, height: 1.15),
              ),
              const SizedBox(height: 10),
              const Text(
                'PULSE MARKET LAB은 TradingView Advanced Chart를 기반으로 주요 디지털 자산과 국내 기업 주가 추종 선물의 흐름을 확인할 수 있도록 구성했습니다.',
                style: TextStyle(color: _TradingViewPalette.body, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: assetWidth, child: const _TradingViewIntroFeature(number: '01', title: '실시간 차트', body: 'TradingView의 인터랙티브 차트에서 가격 흐름과 시간봉을 직접 확인합니다.')),
                  SizedBox(width: assetWidth, child: const _TradingViewIntroFeature(number: '02', title: '4개 핵심 종목', body: 'Bitcoin, Ethereum, 삼성전자 추종 선물, SK하이닉스 추종 선물을 한곳에 모았습니다.')),
                  SizedBox(width: assetWidth, child: const _TradingViewIntroFeature(number: '03', title: '반응형 워크스페이스', body: '데스크톱과 모바일 화면 크기에 맞춰 메뉴와 차트 영역이 자동으로 정렬됩니다.')),
                  SizedBox(width: assetWidth, child: const _TradingViewIntroFeature(number: '04', title: 'CUSTOM STUDIES', body: '다음 단계에서 자체 제작 보조지표 6종을 버튼으로 선택할 수 있게 확장합니다.')),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                color: const Color(0xffeafbf0),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_forward_rounded, color: _TradingViewPalette.ink, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '차트 메뉴에서 종목을 선택하면 TradingView 차트 내부의 시간봉·확대·지표 기능을 바로 사용할 수 있습니다.',
                        style: TextStyle(color: _TradingViewPalette.ink, fontSize: 12, height: 1.45, fontWeight: FontWeight.w600),
                      ),
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

class _TradingViewIntroHero extends StatelessWidget {
  const _TradingViewIntroHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 36),
      color: _TradingViewPalette.ink,
      child: compact
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TradingViewHeroBadge(),
                SizedBox(height: 24),
                _TradingViewHeroCopy(),
              ],
            )
          : const Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_TradingViewHeroBadge(), SizedBox(height: 24), _TradingViewHeroCopy()])),
                SizedBox(width: 32),
                _TradingViewHeroSignal(),
              ],
            ),
    );
  }
}

class _TradingViewHeroBadge extends StatelessWidget {
  const _TradingViewHeroBadge();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: _TradingViewPalette.green),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text('PULSE', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
        ),
        SizedBox(width: 8),
        Text('MARKET LAB', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      ],
    );
  }
}

class _TradingViewHeroCopy extends StatelessWidget {
  const _TradingViewHeroCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('읽고,\n확인하고,\n움직이다.', style: TextStyle(color: Colors.white, fontSize: 36, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -1)),
        SizedBox(height: 16),
        Text('시장에 필요한 신호만\n선명하게 보여드립니다.', style: TextStyle(color: Color(0xffb7bec1), fontSize: 14, height: 1.45)),
      ],
    );
  }
}

class _TradingViewHeroSignal extends StatelessWidget {
  const _TradingViewHeroSignal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _TradingViewPalette.green,
        border: Border.all(color: Colors.black, width: 8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('LIVE', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
          Icon(Icons.show_chart_rounded, color: Colors.black, size: 58),
          Text('DATA / 04', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .8)),
        ],
      ),
    );
  }
}

class _TradingViewIntroStat extends StatelessWidget {
  const _TradingViewIntroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _TradingViewPalette.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: _TradingViewPalette.ink, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: _TradingViewPalette.muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8)),
        ],
      ),
    );
  }
}

class _TradingViewIntroFeature extends StatelessWidget {
  const _TradingViewIntroFeature({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _TradingViewPalette.border),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(color: _TradingViewPalette.green, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: _TradingViewPalette.ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: _TradingViewPalette.body, fontSize: 12, height: 1.45)),
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
