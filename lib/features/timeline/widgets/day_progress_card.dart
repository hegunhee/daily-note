import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:greenlist/shared/widgets/app_badge.dart';
import 'package:greenlist/shared/widgets/app_card.dart';
import 'package:greenlist/shared/widgets/app_progress_bar.dart';

/// 그날 일정들의 세부 작업 전체 진행 상황
class DayProgressCard extends StatelessWidget {
  const DayProgressCard({
    required this.tasks,
    required this.isToday,
    super.key,
  });

  /// 그날 일정에 딸린 세부 작업 전체
  final List<SubTask> tasks;

  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final done = completedCount(tasks);
    final badge = isAllDone(tasks)
        ? 'done'
        : done == 0
        ? 'ready'
        : 'going';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isToday
                      ? 'timeline.progress.title_today'.tr()
                      : 'timeline.progress.title_other'.tr(),
                  style: AppTypography.headlineSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              AppBadge('timeline.progress.badge.$badge'.tr()),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'timeline.progress.summary'.tr(
                    namedArgs: {'total': '${tasks.length}', 'done': '$done'},
                  ),
                  style: AppTypography.bodySm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${progressPercent(tasks)}%',
                style: AppTypography.timeSm.copyWith(color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(value: progressOf(tasks)),
        ],
      ),
    );
  }
}
