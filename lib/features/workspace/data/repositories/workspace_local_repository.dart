import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/workspace_models.dart';

class LocalWorkspaceSnapshot {
  const LocalWorkspaceSnapshot({
    required this.watchlistSymbols,
    required this.preferences,
    required this.alerts,
  });

  final List<String> watchlistSymbols;
  final ChartWorkspacePreferences preferences;
  final List<SavedPriceAlert> alerts;
}

class WorkspaceLocalRepository {
  WorkspaceLocalRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _watchlistKey = 'pulse.workspace.watchlist.v1';
  static const _preferencesKey = 'pulse.workspace.preferences.v1';
  static const _alertsKey = 'pulse.workspace.alerts.v1';

  final SharedPreferencesAsync _preferences;

  Future<LocalWorkspaceSnapshot> load() async {
    final watchlistJson = await _preferences.getString(_watchlistKey);
    final preferencesJson = await _preferences.getString(_preferencesKey);
    final alertsJson = await _preferences.getString(_alertsKey);

    return LocalWorkspaceSnapshot(
      watchlistSymbols: _readStringList(watchlistJson) ??
          const ['BINANCE:BTCUSDT', 'KRX:005930'],
      preferences: _readPreferences(preferencesJson),
      alerts: _readAlerts(alertsJson),
    );
  }

  Future<void> saveWatchlist(List<String> symbols) {
    return _preferences.setString(_watchlistKey, jsonEncode(symbols));
  }

  Future<void> savePreferences(ChartWorkspacePreferences preferences) {
    return _preferences.setString(
      _preferencesKey,
      jsonEncode(preferences.toJson()),
    );
  }

  Future<void> saveAlerts(List<SavedPriceAlert> alerts) {
    return _preferences.setString(
      _alertsKey,
      jsonEncode(alerts.map((alert) => alert.toJson()).toList()),
    );
  }

  List<String>? _readStringList(String? source) {
    if (source == null) return null;
    try {
      return (jsonDecode(source) as List<dynamic>).whereType<String>().toList();
    } on Object {
      return null;
    }
  }

  ChartWorkspacePreferences _readPreferences(String? source) {
    if (source == null) return ChartWorkspacePreferences.initial;
    try {
      return ChartWorkspacePreferences.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
    } on Object {
      return ChartWorkspacePreferences.initial;
    }
  }

  List<SavedPriceAlert> _readAlerts(String? source) {
    if (source == null) return [];
    try {
      return (jsonDecode(source) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(SavedPriceAlert.fromJson)
          .toList();
    } on Object {
      return [];
    }
  }
}
