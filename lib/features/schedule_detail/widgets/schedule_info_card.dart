import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_status.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:greenlist/shared/util/schedule_labels.dart';
import 'package:greenlist/shared/widgets/app_badge.dart';
import 'package:greenlist/shared/widgets/app_card.dart';

/// 일정 제목과 날짜·시각·소요 시간
class ScheduleInfoCard extends StatelessWidget {
  const ScheduleInfoCard({
    required this.schedule,
    required this.status,
    super.key,
  });

  final Schedule schedule;

  final ScheduleStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final done = status == ScheduleStatus.done;
    return AppCard(
      accentColor: status == ScheduleStatus.inProgress ? colors.accent : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            schedule.title,
            style: AppTypography.headlineMd.copyWith(
              color: done ? colors.textTertiary : colors.textPrimary,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: colors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'schedule_detail.date'.tr(),
                    child: Text(
                      fullDateLabel(context, schedule.date),
                      style: AppTypography.bodyLg.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'schedule_detail.time'.tr(),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          timeRangeLabel(schedule),
                          style: AppTypography.timeSm.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        AppBadge(
                          durationLabel(durationMinutes(schedule)),
                          background: colors.surface,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;

  final String label;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: colors.onPrimaryTint),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              child,
            ],
          ),
        ),
      ],
    );
  }
}
