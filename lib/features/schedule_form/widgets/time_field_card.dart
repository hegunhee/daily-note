import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/util/schedule_labels.dart';
import 'package:greenlist/shared/widgets/app_tap_row.dart';

/// 시작·종료 시각 한 칸. 누르면 시각 고르기를 엽니다.
class TimeFieldCard extends StatelessWidget {
  const TimeFieldCard({
    required this.label,
    required this.time,
    required this.onTap,
    this.hasError = false,
    super.key,
  });

  /// `시작` · `종료`
  final String label;

  final TimeOfDay time;

  final VoidCallback onTap;

  /// 잘못된 시간 범위면 테두리를 오류 색으로 그립니다.
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius,
            border: Border.all(
              color: hasError ? colors.error : colors.border,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Semantics(
            button: true,
            label: label,
            child: AppTapRow(
              onTap: onTap,
              borderRadius: radius,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            timeLabel(time),
                            style: AppTypography.timeLg.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
