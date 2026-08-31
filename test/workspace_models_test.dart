import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_chart/features/workspace/domain/entities/workspace_models.dart';

void main() {
  test('chart preferences preserve the last workspace state', () {
    final source = ChartWorkspacePreferences(
      symbol: 'NASDAQ:NVDA',
      interval: '60',
      theme: ChartThemePreference.dark,
      activeIndicators: const {'rsiPulse', 'macdMomentum'},
      updatedAt: DateTime.utc(2026, 8, 31),
    );

    final restored = ChartWorkspacePreferences.fromJson(source.toJson());

    expect(restored.symbol, 'NASDAQ:NVDA');
    expect(restored.interval, '60');
    expect(restored.theme, ChartThemePreference.dark);
    expect(restored.activeIndicators, {'rsiPulse', 'macdMomentum'});
  });

  test('alert rules can be stored locally and restored', () {
    final source = SavedPriceAlert(
      id: 'local-test',
      name: 'BTC 목표가',
      symbol: 'BINANCE:BTCUSDT',
      type: PriceAlertType.priceAbove,
      targetPrice: 100000,
      enabled: true,
      createdAt: DateTime.utc(2026, 8, 31),
    );

    final restored = SavedPriceAlert.fromJson(source.toJson());

    expect(restored.id, source.id);
    expect(restored.type, PriceAlertType.priceAbove);
    expect(restored.targetPrice, 100000);
    expect(restored.enabled, isTrue);
  });
}
