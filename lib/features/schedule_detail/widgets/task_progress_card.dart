import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:greenlist/shared/widgets/app_card.dart';
import 'package:greenlist/shared/widgets/app_progress_bar.dart';

/// 한 일정의 세부 작업 진행률과 남은 작업 안내
class TaskProgressCard extends StatelessWidget {
  const TaskProgressCard({required this.tasks, super.key});

  final List<SubTask> tasks;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final done = completedCount(tasks);
    final allDone = isAllDone(tasks);
    final hint = tasks.isEmpty
        ? 'schedule_detail.progress.hint_empty'.tr()
        : allDone
        ? 'schedule_detail.progress.hint_done'.tr()
        : 'schedule_detail.progress.hint_remaining'.tr(
            args: ['${tasks.length - done}'],
          );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                allDone ? Icons.task_alt_rounded : Icons.donut_large_rounded,
                size: 20,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'schedule_detail.progress.title'.tr(),
                  style: AppTypography.headlineSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${progressPercent(tasks)}%',
                style: AppTypography.timeMd.copyWith(color: colors.primary),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'schedule_detail.progress.count'.tr(
                  args: ['$done', '${tasks.length}'],
                ),
                style: AppTypography.labelMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressBar(value: progressOf(tasks)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  hint,
                  style: AppTypography.bodySm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
