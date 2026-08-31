import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/workspace_models.dart';
import '../controllers/pulse_workspace_controller.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key, required this.controller});

  final PulseWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALERT CENTER',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '가격·지표 알림',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _createAlert(context),
                icon: const Icon(Icons.add_alert_outlined, size: 17),
                label: const Text('알림 만들기'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            color: controller.apiConfigured
                ? const Color(0xffeefaf2)
                : const Color(0xfffff7df),
            child: Row(
              children: [
                Icon(
                  controller.apiConfigured
                      ? Icons.dns_outlined
                      : Icons.pause_circle_outline,
                  size: 17,
                  color: controller.apiConfigured
                      ? AppColors.green
                      : const Color(0xffa56b00),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.apiConfigured
                        ? '백엔드 주소가 연결되어 있습니다. 실제 자동 판정은 시세 공급자 설정 후 활성화됩니다.'
                        : '현재 규칙은 기기에 저장됩니다. 자동 감시를 시작하려면 백엔드 주소와 시세 API를 연결해야 합니다.',
                    style: const TextStyle(color: AppColors.label, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: controller.alerts.isEmpty
                ? _EmptyAlerts(onCreate: () => _createAlert(context))
                : ListView.separated(
                    itemCount: controller.alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final alert = controller.alerts[index];
                      return _AlertRuleCard(
                        alert: alert,
                        onToggle: () => controller.toggleAlert(alert),
                        onTest: () => controller.testAlert(alert),
                        onDelete: () => controller.removeAlert(alert),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _createAlert(BuildContext context) async {
    final draft = await showDialog<_AlertDraft>(
      context: context,
      builder: (context) => _CreateAlertDialog(
        initialSymbol: controller.selectedMarket.tradingViewSymbol,
      ),
    );
    if (draft == null) return;
    await controller.addAlert(
      name: draft.name,
      symbol: draft.symbol,
      type: draft.type,
      targetPrice: draft.targetPrice,
      indicatorId: draft.indicatorId,
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, size: 36, color: AppColors.muted),
            const SizedBox(height: 10),
            const Text(
              '아직 만든 알림이 없습니다.',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '목표 가격 또는 6개 지표 신호를 기준으로 규칙을 만들어 보세요.',
              style: TextStyle(color: AppColors.body, fontSize: 11),
            ),
            const SizedBox(height: 14),
            TextButton(onPressed: onCreate, child: const Text('첫 알림 만들기')),
          ],
        ),
      ),
    );
  }
}

class _AlertRuleCard extends StatelessWidget {
  const _AlertRuleCard({
    required this.alert,
    required this.onToggle,
    required this.onTest,
    required this.onDelete,
  });

  final SavedPriceAlert alert;
  final VoidCallback onToggle;
  final VoidCallback onTest;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final condition = switch (alert.type) {
      PriceAlertType.priceAbove => '${alert.targetPrice} 이상 도달',
      PriceAlertType.priceBelow => '${alert.targetPrice} 이하 도달',
      PriceAlertType.indicatorBuy => '${_indicatorName(alert.indicatorId)} 매수 신호',
      PriceAlertType.indicatorSell => '${_indicatorName(alert.indicatorId)} 매도 신호',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            color: alert.enabled
                ? const Color(0xffeefaf2)
                : const Color(0xfff2f4f5),
            child: Icon(
              Icons.notifications_active_outlined,
              size: 18,
              color: alert.enabled ? AppColors.green : AppColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.name,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${alert.symbol}  ·  $condition',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.body, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '알림 테스트',
            onPressed: onTest,
            icon: const Icon(Icons.play_circle_outline, size: 19),
          ),
          Switch.adaptive(
            value: alert.enabled,
            activeTrackColor: AppColors.green,
            onChanged: (_) => onToggle(),
          ),
          IconButton(
            tooltip: '삭제',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 19, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  String _indicatorName(String? id) => IndicatorGuideEntry.entries
      .firstWhere(
        (entry) => entry.id == id,
        orElse: () => IndicatorGuideEntry.entries.first,
      )
      .name;
}

class _AlertDraft {
  const _AlertDraft({
    required this.name,
    required this.symbol,
    required this.type,
    this.targetPrice,
    this.indicatorId,
  });

  final String name;
  final String symbol;
  final PriceAlertType type;
  final double? targetPrice;
  final String? indicatorId;
}

class _CreateAlertDialog extends StatefulWidget {
  const _CreateAlertDialog({required this.initialSymbol});

  final String initialSymbol;

  @override
  State<_CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<_CreateAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;
  final _targetPriceController = TextEditingController();
  PriceAlertType _type = PriceAlertType.priceAbove;
  String _indicatorId = IndicatorGuideEntry.entries.first.id;

  bool get _isPriceAlert =>
      _type == PriceAlertType.priceAbove ||
      _type == PriceAlertType.priceBelow;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '새 알림');
    _symbolController = TextEditingController(text: widget.initialSymbol);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _targetPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('가격·지표 알림 만들기'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '알림 이름'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? '이름을 입력하세요.' : null,
                ),
                TextFormField(
                  controller: _symbolController,
                  decoration: const InputDecoration(labelText: 'TradingView 심볼'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '심볼을 입력하세요.'
                      : null,
                ),
                DropdownButtonFormField<PriceAlertType>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: '조건'),
                  items: PriceAlertType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_alertTypeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _type = value ?? _type),
                ),
                if (_isPriceAlert)
                  TextFormField(
                    controller: _targetPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: '목표 가격'),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      return price == null || price <= 0 ? '0보다 큰 가격을 입력하세요.' : null;
                    },
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _indicatorId,
                    decoration: const InputDecoration(labelText: '보조지표'),
                    items: IndicatorGuideEntry.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.id,
                            child: Text(entry.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _indicatorId = value ?? _indicatorId),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.ink,
            shape: const RoundedRectangleBorder(),
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _AlertDraft(
        name: _nameController.text.trim(),
        symbol: _symbolController.text.trim(),
        type: _type,
        targetPrice: _isPriceAlert
            ? double.parse(_targetPriceController.text.trim())
            : null,
        indicatorId: _isPriceAlert ? null : _indicatorId,
      ),
    );
  }

  String _alertTypeLabel(PriceAlertType type) => switch (type) {
        PriceAlertType.priceAbove => '가격 이상 도달',
        PriceAlertType.priceBelow => '가격 이하 도달',
        PriceAlertType.indicatorBuy => '지표 매수 신호',
        PriceAlertType.indicatorSell => '지표 매도 신호',
      };
}
