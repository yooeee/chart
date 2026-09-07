import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/workspace_models.dart';
import '../controllers/pulse_workspace_controller.dart';

class IndicatorGuidePage extends StatelessWidget {
  const IndicatorGuidePage({
    super.key,
    required this.controller,
  });

  final PulseWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final enlarged = MediaQuery.textScalerOf(context).scale(14) > 20;
        final columns = !enlarged && constraints.maxWidth >= 1100
            ? 3
            : !enlarged && constraints.maxWidth >= 760
                ? 2
                : 1;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'INDICATOR GUIDE',
              style: TextStyle(
                color: AppColors.greenInk,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '분석에 필요한 여섯 가지 관점',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '지표의 계산 방식과 해석을 살펴보고, 나의 분석 설정에 저장하세요.',
              style: TextStyle(color: AppColors.body, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xfffff7df),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 17, color: Color(0xffa56b00)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '선택한 지표는 저장됩니다. 차트 내 지표 표시는 아직 지원하지 않습니다.',
                      style: TextStyle(color: AppColors.label, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final entry in IndicatorGuideEntry.entries)
                  SizedBox(
                    width: (constraints.maxWidth - 48 - (columns - 1) * 16) / columns,
                    child: _IndicatorGuideCard(
                      entry: entry,
                      selected: controller.activeIndicators.contains(entry.id),
                      onToggle: () => controller.toggleIndicator(entry.id),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _IndicatorGuideCard extends StatelessWidget {
  const _IndicatorGuideCard({
    required this.entry,
    required this.selected,
    required this.onToggle,
  });

  final IndicatorGuideEntry entry;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.green : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 7, height: 7, color: _accentFor(entry.id)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.category.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, size: 17, color: AppColors.green),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.name,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            entry.formula,
            style: const TextStyle(
              color: AppColors.greenInk,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            entry.summary,
            style: const TextStyle(color: AppColors.body, fontSize: 14, height: 1.655),
          ),
          const SizedBox(height: 9),
          _GuideDetail(label: '해석', text: entry.interpretation),
          const SizedBox(height: 7),
          _GuideDetail(label: '주의', text: entry.caution),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onToggle,
              icon: Icon(
                selected ? Icons.remove_circle_outline : Icons.add_circle_outline,
                size: 16,
              ),
              label: Text(selected ? '선택 해제' : '내 지표에 추가'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: BorderSide(
                  color: selected ? AppColors.green : AppColors.border,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _accentFor(String id) => switch (id) {
        'trendRibbon' => AppColors.green,
        'rsiPulse' => const Color(0xff9d8cff),
        'macdMomentum' => const Color(0xff7eafff),
        'bollingerSqueeze' => const Color(0xff62b5ff),
        'volumePressure' => const Color(0xffffc857),
        _ => const Color(0xffff8f70),
      };
}

class _GuideDetail extends StatelessWidget {
  const _GuideDetail({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.body, fontSize: 14, height: 1.4),
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}
