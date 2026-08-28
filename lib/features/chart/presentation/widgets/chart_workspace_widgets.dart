import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/market_bar.dart';
import '../../domain/entities/market_symbol.dart';
import '../../domain/entities/market_symbol_catalog.dart';
import '../../domain/entities/market_timeframe.dart';
import '../../domain/enums/indicator_type.dart';
import 'market_chart.dart';

class ChartTopNavigation extends StatelessWidget {
  const ChartTopNavigation({super.key, required this.isLoading, required this.hasError});

  final bool isLoading;
  final bool hasError;

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
          final compact = constraints.maxWidth < 700;
          return Row(
            children: [
              if (compact)
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
                  onPressed: () {},
                  tooltip: '메뉴',
                ),
              const BrandMark(),
              if (!compact) ...[
                const SizedBox(width: 42),
                const ChartNavigationItem(label: '차트', active: true),
                const ChartNavigationItem(label: '시장'),
                const ChartNavigationItem(label: '스크리너'),
              ],
              const Spacer(),
              if (!compact) ...[
                ChartTopAction(icon: Icons.notifications_none_rounded, onPressed: () {}),
                const SizedBox(width: 8),
                MarketStatusBadge(isLoading: isLoading, hasError: hasError),
                const SizedBox(width: 16),
              ],
              const UserAvatar(),
            ],
          );
        },
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          color: AppColors.green,
          child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 18),
        ),
        const SizedBox(width: 9),
        const Text(
          'PULSE',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'MARKET LAB',
          style: TextStyle(color: AppColors.muted, fontSize: 9, letterSpacing: 1.1),
        ),
      ],
    );
  }
}

class ChartNavigationItem extends StatelessWidget {
  const ChartNavigationItem({super.key, required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: active ? AppColors.green : Colors.transparent, width: 3)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.ink : AppColors.body,
          fontSize: 14,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class ChartTopAction extends StatelessWidget {
  const ChartTopAction({super.key, required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: AppColors.body),
      tooltip: '알림',
    );
  }
}

class MarketStatusBadge extends StatelessWidget {
  const MarketStatusBadge({super.key, required this.isLoading, required this.hasError});

  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final label = hasError
        ? 'SETUP REQUIRED'
        : isLoading
            ? 'LOADING'
            : 'REAL DATA';
    final accent = hasError ? AppColors.disabled : AppColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: hasError ? const Color(0xfff2f3f4) : const Color(0xffeefaf2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: accent, shape: BoxShape.circle))),
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: AppColors.label, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .6)),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      color: AppColors.ink,
      child: const Text('YE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class ChartWorkspaceHeader extends StatelessWidget {
  const ChartWorkspaceHeader({super.key, 
    required this.marketSymbol,
    required this.latestPrice,
    required this.priceChangePercent,
    required this.selectedTimeRange,
    required this.onTickerSelected,
    required this.onTimeRangeSelected,
  });

  final MarketSymbol marketSymbol;
  final double? latestPrice;
  final double? priceChangePercent;
  final String selectedTimeRange;
  final ValueChanged<String> onTickerSelected;
  final ValueChanged<String> onTimeRangeSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final change = priceChangePercent;
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
                      TickerSelector(selectedTicker: marketSymbol.ticker, onChanged: onTickerSelected),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(marketSymbol.exchange, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                if (!compact) TimeRangeSelector(selectedTimeRange: selectedTimeRange, onChanged: onTimeRangeSelected),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Text(
                  formatMarketPrice(latestPrice),
                  style: const TextStyle(color: AppColors.ink, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1),
                ),
                const SizedBox(width: 12),
                Text(
                  change == null
                      ? '—'
                      : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: change == null
                        ? AppColors.muted
                        : change >= 0
                            ? AppColors.green
                            : const Color(0xffd94d5b),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('vs prev bar', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                if (compact) ...[
                  const Spacer(),
                  TimeRangeSelector(selectedTimeRange: selectedTimeRange, onChanged: onTimeRangeSelected),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class TickerSelector extends StatelessWidget {
  const TickerSelector({super.key, required this.selectedTicker, required this.onChanged});

  final String selectedTicker;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedTicker,
      onSelected: onChanged,
      color: Colors.white,
      elevation: 3,
      itemBuilder: (context) => MarketSymbolCatalog.symbols
          .map((marketSymbol) => PopupMenuItem<String>(
                value: marketSymbol.ticker,
                height: 40,
                child: Text('${marketSymbol.ticker}  ·  ${marketSymbol.displayName}', style: const TextStyle(color: AppColors.ink, fontSize: 13)),
              ))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedTicker, style: const TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.body),
        ],
      ),
    );
  }
}

class TimeRangeSelector extends StatelessWidget {
  const TimeRangeSelector({super.key, required this.selectedTimeRange, required this.onChanged});

  final String selectedTimeRange;
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
                color: range == selectedTimeRange ? AppColors.green : Colors.transparent,
                child: Text(
                  range,
                  style: TextStyle(color: range == selectedTimeRange ? Colors.black : AppColors.muted, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class MarketDataStrip extends StatelessWidget {
  const MarketDataStrip({super.key, 
    required this.marketSymbol,
    required this.latestBarTimestamp,
    required this.isLoading,
  });

  final MarketSymbol marketSymbol;
  final DateTime? latestBarTimestamp;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final items = <Widget>[
          const Text('MARKET DATA', style: TextStyle(color: AppColors.muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8)),
          const SizedBox(width: 18),
          _buildMarketDataItem('SYMBOL', marketSymbol.ticker),
          _buildMarketDataItem('EXCHANGE', marketSymbol.exchange),
          if (!compact) ...[
            const Spacer(),
            Text(
              isLoading ? 'LOADING' : _formatLatestBarLabel(latestBarTimestamp),
              style: const TextStyle(color: AppColors.muted, fontSize: 9, letterSpacing: .3),
            ),
          ],
        ];
        final row = Row(children: items);
        return Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border)),
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

  Widget _buildMarketDataItem(String label, String value) {
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

  String _formatLatestBarLabel(DateTime? value) {
    if (value == null) return 'NO DATA';
    final date = '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final time = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return 'LAST BAR  $date $time';
  }
}

class MarketChartCard extends StatelessWidget {
  const MarketChartCard({super.key, 
    required this.marketBars,
    required this.activeIndicatorTypes,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetryRequested,
    required this.timeframeDisplayLabel,
  });

  final List<MarketBar> marketBars;
  final Set<IndicatorType> activeIndicatorTypes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetryRequested;
  final String timeframeDisplayLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('CANDLESTICK', style: TextStyle(color: AppColors.label, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .7)),
              const SizedBox(width: 8),
              Text(timeframeDisplayLabel, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
              const Spacer(),
              const Icon(Icons.open_with_rounded, size: 15, color: AppColors.muted),
              const SizedBox(width: 6),
              const Text('pinch to zoom', style: TextStyle(color: AppColors.muted, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: isLoading
                ? const ChartMessage(message: '실데이터를 불러오는 중입니다.')
                : errorMessage != null
                    ? ChartMessage(message: errorMessage!, isError: true, onRetryRequested: onRetryRequested)
                    : MarketChart(marketBars: marketBars, activeIndicatorTypes: activeIndicatorTypes),
          ),
        ],
      ),
    );
  }
}

class ChartMessage extends StatelessWidget {
  const ChartMessage({super.key, required this.message, this.isError = false, this.onRetryRequested});

  final String message;
  final bool isError;
  final VoidCallback? onRetryRequested;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.cloud_off_outlined : Icons.sync_rounded,
              color: AppColors.muted,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.body, fontSize: 12, height: 1.45),
            ),
            if (isError && onRetryRequested != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onRetryRequested,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: const Text('다시 시도', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class IndicatorPanel extends StatelessWidget {
  const IndicatorPanel({super.key, required this.activeIndicatorTypes, required this.onToggle, this.compact = false});

  final Set<IndicatorType> activeIndicatorTypes;
  final ValueChanged<IndicatorType> onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('SIGNALS', style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: .6))),
              Container(color: AppColors.green, padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), child: const Text('06 TOOLS', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 5),
          const Text('차트에 표시할 분석 도구를 선택하세요.', style: TextStyle(color: AppColors.body, fontSize: 11)),
          const SizedBox(height: 14),
          _buildIndicatorList(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xfff7f8f8),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: AppColors.muted),
                SizedBox(width: 7),
                Expanded(child: Text('실데이터 OHLCV를 기준으로 6개 분석 도구를 계산합니다. 데이터 지연 여부는 공급자 플랜에 따라 달라질 수 있습니다.', style: TextStyle(color: AppColors.body, fontSize: 10, height: 1.35))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorList() {
    final list = ListView.separated(
      shrinkWrap: compact,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      itemCount: IndicatorType.values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final indicatorType = IndicatorType.values[index];
        return IndicatorTile(
          indicatorType: indicatorType,
          selected: activeIndicatorTypes.contains(indicatorType),
          onTap: () => onToggle(indicatorType),
        );
      },
    );
    return compact ? list : Expanded(child: list);
  }
}

class IndicatorTile extends StatelessWidget {
  const IndicatorTile({super.key, required this.indicatorType, required this.selected, required this.onTap});

  final IndicatorType indicatorType;
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
              left: BorderSide(color: selected ? AppColors.green : AppColors.border, width: selected ? 3 : 1),
              top: const BorderSide(color: AppColors.border),
              right: const BorderSide(color: AppColors.border),
              bottom: const BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(indicatorType.displayName, style: const TextStyle(color: AppColors.ink, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(indicatorType.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.body, fontSize: 9, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Icon(selected ? Icons.visibility_rounded : Icons.visibility_off_outlined, color: selected ? AppColors.green : AppColors.disabled, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

String formatMarketPrice(double? value) {
  if (value == null) return '—';
  return value >= 1000 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}
