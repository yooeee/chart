import 'package:flutter/foundation.dart';

import '../../domain/entities/market_bar.dart';
import '../../domain/entities/market_symbol.dart';
import '../../domain/entities/market_symbol_catalog.dart';
import '../../domain/entities/market_timeframe.dart';
import '../../domain/enums/indicator_type.dart';
import '../../domain/errors/market_data_exception.dart';
import '../../domain/usecases/fetch_market_bars.dart';

class ChartController extends ChangeNotifier {
  ChartController({
    required FetchMarketBars fetchMarketBars,
    String initialTicker = 'NEXON',
    String initialTimeRange = '1D',
  })  : _fetchMarketBars = fetchMarketBars,
        _selectedTicker = initialTicker,
        _selectedTimeRange = initialTimeRange;

  final FetchMarketBars _fetchMarketBars;

  String _selectedTicker;
  String _selectedTimeRange;
  List<MarketBar> _marketBars = const <MarketBar>[];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _latestBarTimestamp;
  int _requestVersion = 0;
  bool _isDisposed = false;
  Set<IndicatorType> _activeIndicatorTypes = <IndicatorType>{
    IndicatorType.trendRibbon,
    IndicatorType.bollingerSqueeze,
  };

  String get selectedTicker => _selectedTicker;
  String get selectedTimeRange => _selectedTimeRange;
  MarketSymbol get selectedMarketSymbol =>
      MarketSymbolCatalog.findByTicker(_selectedTicker);
  List<MarketBar> get marketBars => _marketBars;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get latestBarTimestamp => _latestBarTimestamp;
  double? get latestPrice =>
      _marketBars.isEmpty ? null : _marketBars.last.close;
  double? get priceChangePercent {
    if (_marketBars.length < 2) return null;
    final previousClose = _marketBars[_marketBars.length - 2].close;
    return (_marketBars.last.close / previousClose - 1) * 100;
  }

  String get timeframeDisplayLabel =>
      MarketTimeframe.fromRange(_selectedTimeRange).displayLabel;

  Set<IndicatorType> get activeIndicatorTypes =>
      Set<IndicatorType>.unmodifiable(_activeIndicatorTypes);

  Future<void> selectTicker(String ticker) async {
    if (ticker == _selectedTicker) return;
    _selectedTicker = ticker;
    _notifyIfActive();
    await loadMarketBars();
  }

  Future<void> selectTimeRange(String timeRange) async {
    if (timeRange == _selectedTimeRange) return;
    _selectedTimeRange = timeRange;
    _notifyIfActive();
    await loadMarketBars();
  }

  Future<void> loadMarketBars() async {
    final requestTicker = _selectedTicker;
    final requestTimeRange = _selectedTimeRange;
    final requestVersion = ++_requestVersion;

    _isLoading = true;
    _errorMessage = null;
    _notifyIfActive();

    try {
      final loadedMarketBars = await _fetchMarketBars(
        ticker: requestTicker,
        timeRange: requestTimeRange,
      );
      if (!_isCurrentRequest(requestVersion)) return;

      _marketBars = loadedMarketBars;
      _latestBarTimestamp = loadedMarketBars.last.timestamp;
      _isLoading = false;
      _errorMessage = null;
      _notifyIfActive();
    } on MarketDataException catch (error) {
      if (!_isCurrentRequest(requestVersion)) return;
      _clearMarketData();
      _isLoading = false;
      _errorMessage = error.message;
      _notifyIfActive();
    } catch (error) {
      if (!_isCurrentRequest(requestVersion)) return;
      _clearMarketData();
      _isLoading = false;
      _errorMessage = '실데이터를 불러오지 못했습니다.\n$error';
      _notifyIfActive();
    }
  }

  void toggleIndicator(IndicatorType indicatorType) {
    final nextIndicatorTypes = <IndicatorType>{..._activeIndicatorTypes};
    if (!nextIndicatorTypes.add(indicatorType)) {
      nextIndicatorTypes.remove(indicatorType);
    }
    _activeIndicatorTypes = nextIndicatorTypes;
    _notifyIfActive();
  }

  void _clearMarketData() {
    _marketBars = const <MarketBar>[];
    _latestBarTimestamp = null;
  }

  bool _isCurrentRequest(int requestVersion) =>
      !_isDisposed && requestVersion == _requestVersion;

  void _notifyIfActive() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestVersion++;
    super.dispose();
  }
}
