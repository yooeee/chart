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
        final columns = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 680
                ? 2
                : 1;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            const Text(
              'SIGNAL LIBRARY',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '6개 보조지표 사용 가이드',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '계산 방식·해석·주의점을 확인하고 차트 작업공간의 선택 상태에 추가할 수 있습니다.',
              style: TextStyle(color: AppColors.body, fontSize: 12),
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
                      '선택 상태와 설명은 구현되어 있습니다. TradingView 차트에 자체 계산선을 렌더링하려면 Advanced Charts 라이선스와 시세 Datafeed 연동이 추가로 필요합니다.',
                      style: TextStyle(color: AppColors.label, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? .9 : 1.03,
              ),
              itemCount: IndicatorGuideEntry.entries.length,
              itemBuilder: (context, index) {
                final entry = IndicatorGuideEntry.entries[index];
                return _IndicatorGuideCard(
                  entry: entry,
                  selected: controller.activeIndicators.contains(entry.id),
                  onToggle: () => controller.toggleIndicator(entry.id),
                );
              },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    fontSize: 9,
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            entry.formula,
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            entry.summary,
            style: const TextStyle(color: AppColors.body, fontSize: 11, height: 1.45),
          ),
          const SizedBox(height: 9),
          _GuideDetail(label: '해석', text: entry.interpretation),
          const SizedBox(height: 7),
          _GuideDetail(label: '주의', text: entry.caution),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onToggle,
              icon: Icon(
                selected ? Icons.remove_circle_outline : Icons.add_circle_outline,
                size: 16,
              ),
              label: Text(selected ? '차트 선택에서 해제' : '차트 선택에 추가'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: BorderSide(
                  color: selected ? AppColors.green : AppColors.border,
                ),
                shape: const RoundedRectangleBorder(),
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
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
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(color: AppColors.body, fontSize: 10, height: 1.4),
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
