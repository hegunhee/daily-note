import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/widgets/app_card.dart';

/// 일정이 없는 날의 안내 카드 (`docs/design/screens/empty`)
class TimelineEmptyCard extends StatelessWidget {
  const TimelineEmptyCard({required this.isToday, this.action, super.key});

  final bool isToday;

  /// 안내 아래에 둘 버튼 (선택)
  final Widget? action;

  static const _illustrationSize = 148.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          SizedBox.square(
            dimension: _illustrationSize,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_note_rounded,
                      size: 64,
                      color: colors.primary,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.accentTint,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.wb_sunny_outlined,
                        size: 20,
                        color: colors.onAccentTint,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'timeline.empty.title'.tr(),
            textAlign: TextAlign.center,
            style: AppTypography.headlineSm.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isToday
                ? 'timeline.empty.body_today'.tr()
                : 'timeline.empty.body_other'.tr(),
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xl),
            SizedBox(width: double.infinity, child: action),
          ],
        ],
      ),
    );
  }
}
