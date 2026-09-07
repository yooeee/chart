import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/workspace_models.dart';
import '../controllers/pulse_workspace_controller.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key, required this.controller});

  final PulseWorkspaceController controller;

  @override
  Widget build(BuildContext context) {

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ALERT CENTER', style: TextStyle(color: AppColors.greenInk, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
            SizedBox(height: 8),
            Text('나의 알림', style: TextStyle(color: AppColors.ink, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
          ])),
          FilledButton.icon(
            onPressed: () => _createAlert(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('새 알림'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.ink, foregroundColor: Colors.white),
          ),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xfffff7df), borderRadius: BorderRadius.circular(8)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xff9a6810)),
            const SizedBox(width: 10),
            Expanded(child: Text(
              controller.apiConfigured
                ? '자동 감시의 작동 여부는 현재 확인할 수 없습니다. 알림 규칙을 저장하고 테스트할 수 있습니다.'
                : '알림 규칙은 이 기기에 저장됩니다. 현재 자동 감시는 제공되지 않습니다.',
              style: const TextStyle(color: AppColors.label, fontSize: 14, height: 1.6),
            )),
          ]),
        ),
        const SizedBox(height: 16),
        if (controller.alerts.isEmpty)
          _EmptyAlerts(onCreate: () => _createAlert(context))
        else
          for (final alert in controller.alerts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AlertRuleCard(
                alert: alert,
                onToggle: () => controller.toggleAlert(alert),
                onTest: () => controller.testAlert(alert),
                onDelete: () => controller.removeAlert(alert),
              ),
            ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
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
              '관심종목의 목표 가격이나 지표 조건을 저장해 보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.body, fontSize: 14),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white,
        border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: alert.enabled ? AppColors.greenWash : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.notifications_active_outlined, size: 20,
              color: alert.enabled ? AppColors.greenInk : AppColors.muted),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(alert.name, style: const TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w700))),
          Semantics(
            label: '알림 활성화',
            child: Switch.adaptive(value: alert.enabled, activeTrackColor: AppColors.greenInk, onChanged: (_) => onToggle()),
          ),
        ]),
        const SizedBox(height: 14),
        Text('${alert.symbol} · $condition', style: const TextStyle(color: AppColors.body, fontSize: 14, height: 1.6)),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 6),
        Wrap(alignment: WrapAlignment.end, spacing: 8, children: [
          TextButton.icon(onPressed: onTest,
            icon: const Icon(Icons.play_circle_outline_rounded, size: 18), label: const Text('테스트')),
          TextButton.icon(onPressed: onDelete,
            style: TextButton.styleFrom(foregroundColor: AppColors.body),
            icon: const Icon(Icons.delete_outline_rounded, size: 18), label: const Text('삭제')),
        ]),
      ]),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
