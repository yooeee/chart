import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../landing/domain/entities/trading_view_market.dart';
import '../../data/repositories/workspace_local_repository.dart';
import '../../data/services/google_authentication_service.dart';
import '../../data/services/pulse_api_client.dart';
import '../../domain/entities/workspace_models.dart';

class PulseWorkspaceController extends ChangeNotifier {
  PulseWorkspaceController({
    WorkspaceLocalRepository? localRepository,
    PulseApiClient? apiClient,
    GoogleAuthenticationService? googleAuthenticationService,
  })  : _localRepository = localRepository ?? WorkspaceLocalRepository(),
        _apiClient = apiClient ?? PulseApiClient(),
        _googleAuthenticationService =
            googleAuthenticationService ?? GoogleAuthenticationService();

  final WorkspaceLocalRepository _localRepository;
  final PulseApiClient _apiClient;
  final GoogleAuthenticationService _googleAuthenticationService;
  Timer? _notificationTimer;

  bool _initialized = false;
  bool _busy = false;
  String? _statusMessage;
  ChartWorkspacePreferences _preferences =
      ChartWorkspacePreferences.initial;
  List<String> _watchlistSymbols = const [];
  List<SavedPriceAlert> _alerts = const [];
  List<PulseNotification> _notifications = const [];
  PulseAccount? _account;
  MarketSummaryData _marketSummary = MarketSummaryData.demo;
  EconomicCalendarData _economicCalendar =
      EconomicCalendarData.createDemo();

  bool get initialized => _initialized;
  bool get busy => _busy;
  bool get apiConfigured => _apiClient.isConfigured;
  bool get googleConfigured => _googleAuthenticationService.isConfigured;
  bool get supportsProgrammaticGoogleSignIn =>
      _googleAuthenticationService.supportsProgrammaticSignIn;
  bool get isSignedIn => _account != null && _apiClient.isAuthenticated;
  PulseAccount? get account => _account;
  ChartWorkspacePreferences get preferences => _preferences;
  TradingViewMarket get selectedMarket =>
      TradingViewMarket.findBySymbol(_preferences.symbol);
  String get interval => _preferences.interval;
  ChartThemePreference get chartTheme => _preferences.theme;
  Set<String> get activeIndicators => _preferences.activeIndicators;
  List<SavedPriceAlert> get alerts => List.unmodifiable(_alerts);
  List<PulseNotification> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadNotificationCount =>
      _notifications.where((notification) => !notification.read).length;
  MarketSummaryData get marketSummary => _marketSummary;
  EconomicCalendarData get economicCalendar => _economicCalendar;

  List<TradingViewMarket> get watchlistMarkets => _watchlistSymbols
      .map(TradingViewMarket.findBySymbol)
      .where((market) =>
          _watchlistSymbols.contains(market.tradingViewSymbol))
      .toList(growable: false);

  bool isInWatchlist(TradingViewMarket market) =>
      _watchlistSymbols.contains(market.tradingViewSymbol);

  Future<void> initialize() async {
    if (_initialized) return;
    final local = await _localRepository.load();
    _watchlistSymbols = local.watchlistSymbols
        .where((symbol) => TradingViewMarket.markets.any(
              (market) => market.tradingViewSymbol == symbol,
            ))
        .toList();
    if (_watchlistSymbols.isEmpty) {
      _watchlistSymbols = ['BINANCE:BTCUSDT', 'KRX:005930'];
    }
    _preferences = local.preferences;
    _alerts = local.alerts;
    _initialized = true;
    notifyListeners();

    await Future.wait([
      _loadMarketData(),
      _googleAuthenticationService.initialize(_handleGoogleAccountChanged),
    ]);
  }

  Future<void> selectMarket(TradingViewMarket market) async {
    _preferences = _preferences.copyWith(
      symbol: market.tradingViewSymbol,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _persistPreferences();
  }

  Future<void> toggleWatchlist(TradingViewMarket market) async {
    if (isInWatchlist(market)) {
      _watchlistSymbols = _watchlistSymbols
          .where((symbol) => symbol != market.tradingViewSymbol)
          .toList();
      if (isSignedIn) {
        await _runRemote(
          () => _apiClient.removeWatchlistItem(market.tradingViewSymbol),
        );
      }
    } else {
      _watchlistSymbols = [market.tradingViewSymbol, ..._watchlistSymbols];
      if (isSignedIn) await _uploadWatchlistItem(market);
    }
    notifyListeners();
    await _localRepository.saveWatchlist(_watchlistSymbols);
  }

  Future<void> setInterval(String interval) async {
    _preferences = _preferences.copyWith(
      interval: interval,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _persistPreferences();
  }

  Future<void> toggleChartTheme() async {
    _preferences = _preferences.copyWith(
      theme: _preferences.theme == ChartThemePreference.light
          ? ChartThemePreference.dark
          : ChartThemePreference.light,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _persistPreferences();
  }

  Future<void> toggleIndicator(String indicatorId) async {
    final selected = {..._preferences.activeIndicators};
    if (!selected.add(indicatorId)) selected.remove(indicatorId);
    _preferences = _preferences.copyWith(
      activeIndicators: selected,
      updatedAt: DateTime.now(),
    );
    _statusMessage = selected.contains(indicatorId)
        ? '지표 선택을 저장했습니다. 차트 렌더링은 데이터·라이선스 연동 후 활성화됩니다.'
        : '지표 선택을 해제했습니다.';
    notifyListeners();
    await _persistPreferences();
  }

  Future<void> addAlert({
    required String name,
    required String symbol,
    required PriceAlertType type,
    double? targetPrice,
    String? indicatorId,
  }) async {
    final alert = SavedPriceAlert(
      id: _createLocalId(),
      name: name,
      symbol: symbol,
      type: type,
      targetPrice: targetPrice,
      indicatorId: indicatorId,
      enabled: true,
      createdAt: DateTime.now(),
    );
    _alerts = [alert, ..._alerts];
    notifyListeners();
    await _localRepository.saveAlerts(_alerts);
    if (isSignedIn) {
      final remoteAlerts = await _runRemote(() => _apiClient.createAlert(alert));
      if (remoteAlerts != null) {
        _alerts = remoteAlerts;
        await _localRepository.saveAlerts(_alerts);
        notifyListeners();
      }
    }
  }

  Future<void> toggleAlert(SavedPriceAlert alert) async {
    final updated = alert.copyWith(enabled: !alert.enabled);
    _alerts = _alerts
        .map((item) => item.id == alert.id ? updated : item)
        .toList();
    notifyListeners();
    await _localRepository.saveAlerts(_alerts);
    if (isSignedIn && !alert.id.startsWith('local-')) {
      final remoteAlerts =
          await _runRemote(() => _apiClient.updateAlert(updated));
      if (remoteAlerts != null) _alerts = remoteAlerts;
      notifyListeners();
    }
  }

  Future<void> removeAlert(SavedPriceAlert alert) async {
    _alerts = _alerts.where((item) => item.id != alert.id).toList();
    notifyListeners();
    await _localRepository.saveAlerts(_alerts);
    if (isSignedIn && !alert.id.startsWith('local-')) {
      final remoteAlerts =
          await _runRemote(() => _apiClient.removeAlert(alert.id));
      if (remoteAlerts != null) _alerts = remoteAlerts;
      notifyListeners();
    }
  }

  Future<void> testAlert(SavedPriceAlert alert) async {
    PulseNotification notification;
    if (isSignedIn && !alert.id.startsWith('local-')) {
      notification = await _apiClient.testAlert(alert.id);
    } else {
      notification = PulseNotification(
        id: _createLocalId(),
        title: '기기 내 알림 테스트',
        message: '${alert.name} 규칙이 저장되어 있습니다. 자동 판정은 백엔드와 시세 공급자 연결 후 동작합니다.',
        createdAt: DateTime.now(),
      );
    }
    _notifications = [notification, ..._notifications];
    _statusMessage = notification.message;
    notifyListeners();
  }

  void markAllNotificationsRead() {
    final unreadIds = _notifications
        .where(
          (notification) =>
              !notification.read && !notification.id.startsWith('local-'),
        )
        .map((notification) => notification.id)
        .toList();
    _notifications = _notifications
        .map((notification) => notification.copyWith(read: true))
        .toList();
    notifyListeners();
    if (isSignedIn) {
      for (final notificationId in unreadIds) {
        unawaited(
          _runRemote(
            () => _apiClient.markNotificationRead(notificationId),
          ),
        );
      }
    }
  }

  Future<void> signInWithGoogle() async {
    _busy = true;
    _statusMessage = null;
    notifyListeners();
    try {
      await _googleAuthenticationService.signIn();
    } on Object catch (error) {
      _statusMessage = error.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleAuthenticationService.signOut();
    _apiClient.clearSession();
    _notificationTimer?.cancel();
    _account = null;
    _statusMessage = '이 기기의 로컬 설정은 유지된 상태로 로그아웃했습니다.';
    notifyListeners();
  }

  String? takeStatusMessage() {
    final message = _statusMessage;
    _statusMessage = null;
    return message;
  }

  Future<void> _handleGoogleAccountChanged(
    GoogleSignInAccount? googleAccount,
  ) async {
    if (googleAccount == null) {
      _apiClient.clearSession();
      _account = null;
      notifyListeners();
      return;
    }
    if (!_apiClient.isConfigured) {
      _statusMessage = 'Google 계정은 확인했지만 PULSE_API_BASE_URL이 설정되지 않아 동기화할 수 없습니다.';
      notifyListeners();
      return;
    }
    final idToken = googleAccount.authentication.idToken;
    if (idToken == null) {
      _statusMessage = 'Google ID token을 받지 못했습니다.';
      notifyListeners();
      return;
    }

    _busy = true;
    notifyListeners();
    try {
      final result = await _apiClient.authenticateWithGoogle(idToken);
      _account = result.account;
      await _mergeServerWorkspace(result.workspace);
      await _loadNotifications();
      _notificationTimer?.cancel();
      _notificationTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => unawaited(_loadNotifications()),
      );
      _statusMessage = '${result.account.displayName} 계정과 동기화했습니다.';
    } on Object catch (error) {
      _statusMessage = error.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _mergeServerWorkspace(Map<String, dynamic> workspace) async {
    final remoteWatchlist = (workspace['watchlist'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => item['symbol'])
        .whereType<String>();
    _watchlistSymbols = {
      ..._watchlistSymbols,
      ...remoteWatchlist,
    }.where((symbol) => TradingViewMarket.markets.any(
          (market) => market.tradingViewSymbol == symbol,
        )).toList();

    final remotePreferencesSource = workspace['preferences'];
    if (remotePreferencesSource is Map<String, dynamic>) {
      final remotePreferences =
          ChartWorkspacePreferences.fromJson(remotePreferencesSource);
      if (remotePreferences.updatedAt.isAfter(_preferences.updatedAt)) {
        _preferences = remotePreferences;
      }
    }

    final remoteAlerts = (workspace['alerts'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SavedPriceAlert.fromJson)
        .toList();
    final remoteKeys = remoteAlerts.map(_alertIdentity).toSet();
    final localOnly = _alerts
        .where((alert) => !remoteKeys.contains(_alertIdentity(alert)))
        .toList();
    _alerts = remoteAlerts;
    for (final alert in localOnly) {
      _alerts = await _apiClient.createAlert(alert);
    }

    await Future.wait([
      _localRepository.saveWatchlist(_watchlistSymbols),
      _localRepository.savePreferences(_preferences),
      _localRepository.saveAlerts(_alerts),
    ]);
    for (final symbol in _watchlistSymbols) {
      await _uploadWatchlistItem(TradingViewMarket.findBySymbol(symbol));
    }
    await _apiClient.savePreferences(_preferences);
  }

  Future<void> _persistPreferences() async {
    await _localRepository.savePreferences(_preferences);
    if (isSignedIn) {
      await _runRemote(() => _apiClient.savePreferences(_preferences));
    }
  }

  Future<void> _uploadWatchlistItem(TradingViewMarket market) {
    return _apiClient.saveWatchlistItem(
      symbol: market.tradingViewSymbol,
      ticker: market.ticker,
      displayName: market.displayName,
      exchange: market.exchange,
    );
  }

  Future<void> _loadMarketData() async {
    if (!_apiClient.isConfigured) return;
    try {
      final results = await Future.wait([
        _apiClient.getMarketSummary(),
        _apiClient.getEconomicCalendar(),
      ]);
      _marketSummary = results[0] as MarketSummaryData;
      _economicCalendar = results[1] as EconomicCalendarData;
      notifyListeners();
    } on Object {
      _statusMessage = '시장 데이터 서버에 연결하지 못해 샘플 데이터를 표시합니다.';
      notifyListeners();
    }
  }

  Future<void> _loadNotifications() async {
    if (!isSignedIn) return;
    try {
      _notifications = await _apiClient.getNotifications();
      notifyListeners();
    } on Object {
      // 다음 폴링에서 재시도합니다. 화면 사용을 방해하지 않습니다.
    }
  }

  Future<T?> _runRemote<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Object catch (error) {
      _statusMessage = '기기에는 저장했지만 서버 동기화에 실패했습니다: $error';
      notifyListeners();
      return null;
    }
  }

  String _createLocalId() =>
      'local-${DateTime.now().microsecondsSinceEpoch}-${math.Random().nextInt(9999)}';

  String _alertIdentity(SavedPriceAlert alert) =>
      '${alert.name}|${alert.symbol}|${alert.type.name}|${alert.targetPrice}|${alert.indicatorId}';

  @override
  void dispose() {
    _notificationTimer?.cancel();
    unawaited(_googleAuthenticationService.dispose());
    super.dispose();
  }
}
