import 'package:flutter/material.dart';

import '../../domain/usecases/fetch_market_bars.dart';
import '../controllers/chart_controller.dart';
import '../widgets/chart_workspace_widgets.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({
    super.key,
    required this.fetchMarketBars,
  });

  final FetchMarketBars fetchMarketBars;

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late final ChartController _chartController;

  @override
  void initState() {
    super.initState();
    _chartController = ChartController(
      fetchMarketBars: widget.fetchMarketBars,
    );
    _chartController.loadMarketBars();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _chartController,
      builder: (context, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                ChartTopNavigation(
                  isLoading: _chartController.isLoading,
                  hasError: _chartController.errorMessage != null,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 980;
                      return isDesktop
                          ? _buildDesktopLayout()
                          : _buildMobileLayout();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          ChartWorkspaceHeader(
            marketSymbol: _chartController.selectedMarketSymbol,
            latestPrice: _chartController.latestPrice,
            priceChangePercent: _chartController.priceChangePercent,
            selectedTimeRange: _chartController.selectedTimeRange,
            onTickerSelected: _chartController.selectTicker,
            onTimeRangeSelected: _chartController.selectTimeRange,
          ),
          const SizedBox(height: 12),
          MarketDataStrip(
            marketSymbol: _chartController.selectedMarketSymbol,
            latestBarTimestamp: _chartController.latestBarTimestamp,
            isLoading: _chartController.isLoading,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: MarketChartCard(
                    marketBars: _chartController.marketBars,
                    activeIndicatorTypes:
                        _chartController.activeIndicatorTypes,
                    isLoading: _chartController.isLoading,
                    errorMessage: _chartController.errorMessage,
                    onRetryRequested: _chartController.loadMarketBars,
                    timeframeDisplayLabel:
                        _chartController.timeframeDisplayLabel,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 310,
                  child: IndicatorPanel(
                    activeIndicatorTypes:
                        _chartController.activeIndicatorTypes,
                    onToggle: _chartController.toggleIndicator,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChartWorkspaceHeader(
            marketSymbol: _chartController.selectedMarketSymbol,
            latestPrice: _chartController.latestPrice,
            priceChangePercent: _chartController.priceChangePercent,
            selectedTimeRange: _chartController.selectedTimeRange,
            onTickerSelected: _chartController.selectTicker,
            onTimeRangeSelected: _chartController.selectTimeRange,
          ),
          const SizedBox(height: 10),
          MarketDataStrip(
            marketSymbol: _chartController.selectedMarketSymbol,
            latestBarTimestamp: _chartController.latestBarTimestamp,
            isLoading: _chartController.isLoading,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 510,
            child: MarketChartCard(
              marketBars: _chartController.marketBars,
              activeIndicatorTypes: _chartController.activeIndicatorTypes,
              isLoading: _chartController.isLoading,
              errorMessage: _chartController.errorMessage,
              onRetryRequested: _chartController.loadMarketBars,
              timeframeDisplayLabel: _chartController.timeframeDisplayLabel,
            ),
          ),
          const SizedBox(height: 12),
          IndicatorPanel(
            activeIndicatorTypes: _chartController.activeIndicatorTypes,
            onToggle: _chartController.toggleIndicator,
            compact: true,
          ),
        ],
      ),
    );
  }
}
