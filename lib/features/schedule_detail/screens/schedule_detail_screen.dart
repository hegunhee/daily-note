import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/features/schedule_detail/widgets/memo_card.dart';
import 'package:greenlist/features/schedule_detail/widgets/schedule_info_card.dart';
import 'package:greenlist/features/schedule_detail/widgets/task_progress_card.dart';
import 'package:greenlist/features/schedule_form/screens/schedule_form_screen.dart';
import 'package:greenlist/shared/controllers/clock_controller.dart';
import 'package:greenlist/shared/controllers/schedule_controller.dart';
import 'package:greenlist/shared/hooks/use_now.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_status.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:greenlist/shared/util/schedule_labels.dart';
import 'package:greenlist/shared/widgets/app_badge.dart';
import 'package:greenlist/shared/widgets/app_card.dart';
import 'package:greenlist/shared/widgets/app_content_width.dart';
import 'package:greenlist/shared/widgets/app_dialogs.dart';
import 'package:greenlist/shared/widgets/app_fill_button.dart';
import 'package:greenlist/shared/widgets/schedule_actions.dart';
import 'package:greenlist/shared/widgets/sub_task_input_field.dart';
import 'package:greenlist/shared/widgets/sub_task_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 상세 화면 메뉴의 항목
enum _DetailMenuAction { delete }

/// 일정 상세 — 진행률을 보며 세부 작업과 메모를 그 자리에서 관리합니다.
///
/// 시안: `docs/design/screens/schedule_detail`
class ScheduleDetailScreen extends HookConsumerWidget {
  const ScheduleDetailScreen({required this.scheduleId, super.key});

  final String scheduleId;

  static Route<void> route(String scheduleId) => MaterialPageRoute(
    builder: (_) => ScheduleDetailScreen(scheduleId: scheduleId),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(scheduleProvider).value;
    final now = useNow(ref.watch(clockProvider));
    final schedule = book?.scheduleById(scheduleId);
    if (book == null || schedule == null) {
      // 지워진 일정이면 아무것도 그리지 않습니다. 지운 쪽에서 화면을 닫습니다.
      return const Scaffold(body: SizedBox.shrink());
    }
    final tasks = subTasksOf(book.subTasks, scheduleId);
    final status = statusOf(schedule, now);

    Future<void> deleteSchedule() async {
      if (await confirmDeleteSchedule(context, ref, schedule) &&
          context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('schedule_detail.title'.tr()),
        actions: [
          IconButton(
            tooltip: 'schedule_detail.edit'.tr(),
            onPressed: () => Navigator.of(
              context,
            ).push(ScheduleFormScreen.route(schedule: schedule)),
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<_DetailMenuAction>(
            tooltip: 'schedule.menu.more'.tr(),
            icon: const Icon(Icons.more_vert_rounded),
            color: context.colors.surface,
            onSelected: (action) => switch (action) {
              _DetailMenuAction.delete => deleteSchedule(),
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _DetailMenuAction.delete,
                child: Text(
                  'schedule.menu.delete'.tr(),
                  style: TextStyle(color: context.colors.error),
                ),
              ),
            ],
          ),
        ],
      ),
      body: AppContentWidth(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.sm,
            AppSpacing.gutter,
            AppSpacing.xxl,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(status: status),
            ),
            const SizedBox(height: AppSpacing.md),
            ScheduleInfoCard(schedule: schedule, status: status),
            const SizedBox(height: AppSpacing.md),
            TaskProgressCard(tasks: tasks),
            const SizedBox(height: AppSpacing.md),
            _TasksCard(scheduleId: scheduleId, tasks: tasks),
            const SizedBox(height: AppSpacing.md),
            MemoCard(schedule: schedule),
          ],
        ),
      ),
      bottomNavigationBar: _ActionBar(schedule: schedule),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ScheduleStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (
      Color background,
      Color foreground,
      IconData icon,
    ) = switch (status) {
      ScheduleStatus.inProgress => (
        colors.accentTint,
        colors.onAccentTint,
        Icons.circle,
      ),
      ScheduleStatus.upcoming => (
        colors.primaryTint,
        colors.onPrimaryTint,
        Icons.schedule_rounded,
      ),
      ScheduleStatus.done => (
        colors.primaryTint,
        colors.onPrimaryTint,
        Icons.check_rounded,
      ),
      ScheduleStatus.past => (
        colors.surfaceLow,
        colors.textSecondary,
        Icons.history_rounded,
      ),
    };
    return AppBadge(
      statusLabel(status),
      icon: icon,
      background: background,
      foreground: foreground,
    );
  }
}

class _TasksCard extends ConsumerWidget {
  const _TasksCard({required this.scheduleId, required this.tasks});

  final String scheduleId;

  final List<SubTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final controller = ref.read(scheduleProvider.notifier);

    /// 저장에 실패하면 알릴 자리가 없어 안내 창을 띄웁니다.
    Future<void> guard(Future<void> Function() action) async {
      try {
        await action();
      } on Object {
        if (context.mounted) {
          await showNotice(context, message: 'common.save_failed'.tr());
        }
      }
    }

    Future<void> rename(SubTask task) async {
      final name = await promptRename(
        context,
        title: 'sub_task.rename_title'.tr(),
        initial: task.title,
      );
      if (name != null) {
        await guard(() => controller.renameSubTask(task.id, name));
      }
    }

    Future<void> delete(SubTask task) async {
      final confirmed = await confirmDelete(
        context,
        message: 'sub_task.delete_confirm'.tr(args: [task.title]),
      );
      if (confirmed) {
        await guard(() => controller.deleteSubTask(task.id));
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, size: 20, color: colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'schedule_detail.tasks'.tr(args: ['${tasks.length}']),
                style: AppTypography.headlineSm.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final task in tasks) ...[
            SubTaskTile(
              key: ValueKey(task.id),
              task: task,
              onToggle: () => toggleSubTask(context, ref, task.id),
              onRename: () => rename(task),
              onDelete: () => delete(task),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SubTaskInputField(
            onAdd: (name) =>
                guard(() => controller.addSubTask(scheduleId, name)),
          ),
        ],
      ),
    );
  }
}

/// 화면 아래의 일정 수정 · 완료 처리 버튼
class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.schedule});

  final Schedule schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: AppContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppFillButton(
                    label: 'schedule_detail.edit'.tr(),
                    icon: Icons.edit_calendar_outlined,
                    variant: AppFillVariant.secondary,
                    onPressed: () => Navigator.of(
                      context,
                    ).push(ScheduleFormScreen.route(schedule: schedule)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 3,
                  child: AppFillButton(
                    label: schedule.isCompleted
                        ? 'schedule_detail.uncomplete'.tr()
                        : 'schedule_detail.complete'.tr(),
                    icon: schedule.isCompleted
                        ? Icons.undo_rounded
                        : Icons.check_circle_outline_rounded,
                    variant: schedule.isCompleted
                        ? AppFillVariant.secondary
                        : AppFillVariant.primary,
                    onPressed: () =>
                        toggleScheduleCompleted(context, ref, schedule),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
