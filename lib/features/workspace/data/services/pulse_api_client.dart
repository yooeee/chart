import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/workspace_models.dart';

class PulseApiException implements Exception {
  const PulseApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class PulseApiClient {
  PulseApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment('PULSE_API_BASE_URL');

  final http.Client _httpClient;
  final String _baseUrl;
  String? _accessToken;

  bool get isConfigured => _baseUrl.trim().isNotEmpty;
  bool get isAuthenticated => _accessToken != null;

  Future<({PulseAccount account, Map<String, dynamic> workspace})>
      authenticateWithGoogle(String idToken) async {
    final response = await _post(
      'auth/google',
      body: {'idToken': idToken},
      authenticated: false,
    );
    _accessToken = response['accessToken'] as String;
    return (
      account: PulseAccount.fromJson(response['user'] as Map<String, dynamic>),
      workspace: response['workspace'] as Map<String, dynamic>,
    );
  }

  Future<MarketSummaryData> getMarketSummary() async {
    final response = await _get('market/summary', authenticated: false);
    return MarketSummaryData.fromJson(response);
  }

  Future<EconomicCalendarData> getEconomicCalendar() async {
    final response = await _get(
      'market/economic-calendar',
      authenticated: false,
    );
    return EconomicCalendarData.fromJson(response);
  }

  Future<void> saveWatchlistItem({
    required String symbol,
    required String ticker,
    required String displayName,
    required String exchange,
  }) async {
    await _post('watchlist', body: {
      'symbol': symbol,
      'ticker': ticker,
      'displayName': displayName,
      'exchange': exchange,
    });
  }

  Future<void> removeWatchlistItem(String symbol) async {
    await _request(
      'DELETE',
      'watchlist/${Uri.encodeComponent(symbol)}',
    );
  }

  Future<void> savePreferences(ChartWorkspacePreferences preferences) async {
    await _request(
      'PUT',
      'preferences',
      body: preferences.toJson()..remove('updatedAt'),
    );
  }

  Future<List<SavedPriceAlert>> getAlerts() async {
    final response = await _getList('alerts');
    return response
        .whereType<Map<String, dynamic>>()
        .map(SavedPriceAlert.fromJson)
        .toList();
  }

  Future<List<SavedPriceAlert>> createAlert(SavedPriceAlert alert) async {
    final response = await _request(
      'POST',
      'alerts',
      body: alert.toJson()
        ..remove('id')
        ..remove('createdAt'),
    );
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(SavedPriceAlert.fromJson)
        .toList();
  }

  Future<List<SavedPriceAlert>> updateAlert(SavedPriceAlert alert) async {
    final response = await _request(
      'PATCH',
      'alerts/${alert.id}',
      body: {'enabled': alert.enabled},
    );
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(SavedPriceAlert.fromJson)
        .toList();
  }

  Future<List<SavedPriceAlert>> removeAlert(String alertId) async {
    final response = await _request('DELETE', 'alerts/$alertId');
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(SavedPriceAlert.fromJson)
        .toList();
  }

  Future<PulseNotification> testAlert(String alertId) async {
    final response = await _post('alerts/$alertId/test', body: const {});
    return PulseNotification.fromJson(response);
  }

  Future<List<PulseNotification>> getNotifications() async {
    final response = await _getList('notifications');
    return response
        .whereType<Map<String, dynamic>>()
        .map(PulseNotification.fromJson)
        .toList();
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _request('PATCH', 'notifications/$notificationId/read');
  }

  void clearSession() {
    _accessToken = null;
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    bool authenticated = true,
  }) async {
    final response = await _request(
      'GET',
      path,
      authenticated: authenticated,
    );
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getList(String path) async {
    return await _request('GET', path) as List<dynamic>;
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, Object?> body,
    bool authenticated = true,
  }) async {
    final response = await _request(
      'POST',
      path,
      body: body,
      authenticated: authenticated,
    );
    return response as Map<String, dynamic>;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool authenticated = true,
  }) async {
    if (!isConfigured) {
      throw const PulseApiException('백엔드 주소가 설정되지 않았습니다.');
    }
    if (authenticated && _accessToken == null) {
      throw const PulseApiException('로그인이 필요합니다.', statusCode: 401);
    }

    final request = http.Request(method, _endpoint(path));
    request.headers['Content-Type'] = 'application/json';
    if (authenticated) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (body != null) request.body = jsonEncode(body);
    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? '서버 요청에 실패했습니다.'
          : '서버 요청에 실패했습니다.';
      throw PulseApiException(message, statusCode: response.statusCode);
    }
    return decoded;
  }

  Uri _endpoint(String path) {
    final normalizedBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    if (normalizedBase.startsWith('/')) {
      return Uri.base.resolve('$normalizedBase/$normalizedPath');
    }
    return Uri.parse('$normalizedBase/$normalizedPath');
  }
}
