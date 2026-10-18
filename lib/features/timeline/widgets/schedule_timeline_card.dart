import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_layout.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_status.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:greenlist/shared/util/schedule_labels.dart';
import 'package:greenlist/shared/widgets/app_badge.dart';
import 'package:greenlist/shared/widgets/app_card.dart';
import 'package:greenlist/shared/widgets/app_checkbox.dart';
import 'package:greenlist/shared/widgets/app_press_scale.dart';
import 'package:greenlist/shared/widgets/schedule_actions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 일정 카드 메뉴의 항목
enum _MenuAction { edit, toggleCompleted, delete }

/// 타임라인의 한 줄: 왼쪽 상태 점과 세로선, 오른쪽 일정 카드
///
/// 진행 중인 일정은 주황 띠·점·NOW 배지로, 완료한 일정은 취소선으로 구분합니다.
class ScheduleTimelineCard extends ConsumerWidget {
  const ScheduleTimelineCard({
    required this.schedule,
    required this.tasks,
    required this.status,
    required this.isLast,
    this.onOpen,
    this.onEdit,
    super.key,
  });

  final Schedule schedule;

  /// 이 일정의 세부 작업 (정렬된 순서)
  final List<SubTask> tasks;

  final ScheduleStatus status;

  /// 마지막 줄이면 아래로 세로선을 잇지 않습니다.
  final bool isLast;

  /// 카드를 눌렀을 때 (상세 화면)
  final VoidCallback? onOpen;

  /// 메뉴의 수정 (null이면 메뉴에서 뺍니다)
  final VoidCallback? onEdit;

  static const _railWidth = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _railWidth,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                _StatusNode(status: status),
                Expanded(
                  child: isLast
                      ? const SizedBox.shrink()
                      : Center(
                          child: Container(width: 2, color: colors.border),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: AppPressScale(
                onTap: onOpen,
                child: AppCard(
                  accentColor: status == ScheduleStatus.inProgress
                      ? colors.accent
                      : null,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.lg,
                  ),
                  child: _CardBody(
                    schedule: schedule,
                    tasks: tasks,
                    status: status,
                    onEdit: onEdit,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBody extends ConsumerWidget {
  const _CardBody({
    required this.schedule,
    required this.tasks,
    required this.status,
    required this.onEdit,
  });

  final Schedule schedule;

  final List<SubTask> tasks;

  final ScheduleStatus status;

  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final live = status == ScheduleStatus.inProgress;
    final done = status == ScheduleStatus.done;
    final timeColor = live ? colors.onAccentTint : colors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 좁은 화면에서는 배지가 시각 아래 줄로 내려갑니다.
            Expanded(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded, size: 15, color: timeColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        timeRangeLabel(schedule),
                        style: AppTypography.timeSm.copyWith(color: timeColor),
                      ),
                    ],
                  ),
                  _StatusBadge(status: status),
                ],
              ),
            ),
            _MenuButton(schedule: schedule, onEdit: onEdit),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Text(
            schedule.title,
            style: AppTypography.bodyLg.copyWith(
              fontWeight: done ? FontWeight.w400 : FontWeight.w600,
              color: done ? colors.textTertiary : colors.textPrimary,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: colors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        _TaskSummary(tasks: tasks, live: live),
        if (tasks.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          for (final task in tasks)
            _TaskRow(
              task: task,
              onToggle: () => toggleSubTask(context, ref, task.id),
            ),
        ],
        if (schedule.memo.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _MemoPreview(memo: schedule.memo, live: live),
          ),
        ],
      ],
    );
  }
}

class _StatusNode extends StatelessWidget {
  const _StatusNode({required this.status});

  final ScheduleStatus status;

  static const _size = 40.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color background, Widget child) = switch (status) {
      ScheduleStatus.done => (
        colors.primaryTint,
        Icon(
          Icons.check_circle_outline_rounded,
          size: 22,
          color: colors.primary,
        ),
      ),
      ScheduleStatus.inProgress => (
        colors.accentTint,
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: 16),
        ),
      ),
      ScheduleStatus.upcoming => (
        colors.surface,
        Icon(Icons.circle_outlined, size: 20, color: colors.textTertiary),
      ),
      ScheduleStatus.past => (
        colors.surfaceLow,
        Icon(Icons.history_rounded, size: 20, color: colors.textTertiary),
      ),
    };
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ScheduleStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color background, Color foreground) = switch (status) {
      ScheduleStatus.inProgress => (colors.accentTint, colors.onAccentTint),
      ScheduleStatus.upcoming => (colors.primaryTint, colors.onPrimaryTint),
      ScheduleStatus.done || ScheduleStatus.past => (
        colors.surfaceLow,
        colors.textSecondary,
      ),
    };
    return AppBadge(
      statusLabel(status),
      background: background,
      foreground: foreground,
    );
  }
}

class _MenuButton extends ConsumerWidget {
  const _MenuButton({required this.schedule, required this.onEdit});

  final Schedule schedule;

  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return PopupMenuButton<_MenuAction>(
      tooltip: 'schedule.menu.more'.tr(),
      icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary),
      constraints: const BoxConstraints(minWidth: 160),
      padding: EdgeInsets.zero,
      iconSize: 20,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(AppLayout.minTouchTarget),
      ),
      color: colors.surface,
      onSelected: (action) => switch (action) {
        _MenuAction.edit => onEdit?.call(),
        _MenuAction.toggleCompleted => toggleScheduleCompleted(
          context,
          ref,
          schedule,
        ),
        _MenuAction.delete => confirmDeleteSchedule(context, ref, schedule),
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          PopupMenuItem(
            value: _MenuAction.edit,
            child: Text('schedule.menu.edit'.tr()),
          ),
        PopupMenuItem(
          value: _MenuAction.toggleCompleted,
          child: Text(
            schedule.isCompleted
                ? 'schedule.menu.uncomplete'.tr()
                : 'schedule.menu.complete'.tr(),
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.delete,
          child: Text(
            'schedule.menu.delete'.tr(),
            style: TextStyle(color: colors.error),
          ),
        ),
      ],
    );
  }
}

class _TaskSummary extends StatelessWidget {
  const _TaskSummary({required this.tasks, required this.live});

  final List<SubTask> tasks;

  final bool live;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (tasks.isEmpty) {
      return Text(
        'schedule.no_tasks'.tr(),
        style: AppTypography.labelMd.copyWith(color: colors.textTertiary),
      );
    }
    final allDone = isAllDone(tasks);
    final color = live && !allDone ? colors.onAccentTint : colors.primary;
    final count = 'schedule.tasks_done'.tr(
      args: ['${completedCount(tasks)}', '${tasks.length}'],
    );
    return Row(
      children: [
        if (allDone) ...[
          Icon(Icons.task_alt_rounded, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            allDone ? '${'schedule.all_done'.tr()} · $count' : count,
            style: AppTypography.labelMd.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onToggle});

  final SubTask task;

  final VoidCallback onToggle;

  static const double _inset =
      (AppLayout.minTouchTarget - AppCheckbox.size) / 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // 체크박스는 44px 탭 영역 가운데에 그려집니다. 상자가 제목과 같은 선에 서도록
    // 남는 여백만큼 줄 전체를 왼쪽으로 당깁니다(탭 영역도 함께 옮겨집니다).
    return Transform.translate(
      offset: const Offset(-_inset, 0),
      child: Row(
        children: [
          AppCheckbox(
            checked: task.isCompleted,
            onChanged: onToggle,
            semanticLabel: task.title,
          ),
          Expanded(
            child: Text(
              task.title,
              style: AppTypography.bodySm.copyWith(
                color: task.isCompleted
                    ? colors.textTertiary
                    : colors.textPrimary,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoPreview extends StatelessWidget {
  const _MemoPreview({required this.memo, required this.live});

  final String memo;

  final bool live;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: live ? colors.accentTint : colors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 16,
              color: colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                memo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
