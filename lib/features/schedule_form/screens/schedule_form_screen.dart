import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/features/schedule_form/models/schedule_form_error.dart';
import 'package:greenlist/features/schedule_form/widgets/form_section.dart';
import 'package:greenlist/features/schedule_form/widgets/time_field_card.dart';
import 'package:greenlist/shared/controllers/clock_controller.dart';
import 'package:greenlist/shared/controllers/schedule_controller.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:greenlist/shared/util/new_id.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:greenlist/shared/util/schedule_labels.dart';
import 'package:greenlist/shared/widgets/app_badge.dart';
import 'package:greenlist/shared/widgets/app_content_width.dart';
import 'package:greenlist/shared/widgets/app_dialogs.dart';
import 'package:greenlist/shared/widgets/app_fill_button.dart';
import 'package:greenlist/shared/widgets/app_press_scale.dart';
import 'package:greenlist/shared/widgets/app_tap_row.dart';
import 'package:greenlist/shared/widgets/inline_error_text.dart';
import 'package:greenlist/shared/widgets/sub_task_input_field.dart';
import 'package:greenlist/shared/widgets/sub_task_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 일정 등록·수정 — 제목·날짜·시각·세부 작업·메모를 한 번에 저장합니다.
///
/// [schedule]을 주면 그 일정을 고칩니다. 시안: `docs/design/screens/schedule_form`
class ScheduleFormScreen extends HookConsumerWidget {
  const ScheduleFormScreen({this.schedule, this.initialDate, super.key});

  /// 고칠 일정. null이면 새 일정을 만듭니다.
  final Schedule? schedule;

  /// 새 일정의 처음 날짜. null이면 오늘입니다.
  final DateTime? initialDate;

  static const titleMaxLength = 60;

  /// 아래에서 올라오는 전체 화면으로 여는 route
  static Route<void> route({Schedule? schedule, DateTime? initialDate}) =>
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            ScheduleFormScreen(schedule: schedule, initialDate: initialDate),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 고치는 일정의 세부 작업으로 입력값을 채워야 해서, 일정을 다 읽은 뒤에 폼을 만듭니다.
    final book = ref.watch(scheduleProvider).value;
    if (book == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _ScheduleForm(
      schedule: schedule,
      initialDate: initialDate,
      initialTasks: schedule == null
          ? const []
          : subTasksOf(book.subTasks, schedule!.id),
    );
  }
}

class _ScheduleForm extends HookConsumerWidget {
  const _ScheduleForm({
    required this.schedule,
    required this.initialDate,
    required this.initialTasks,
  });

  final Schedule? schedule;

  final DateTime? initialDate;

  /// 고치는 일정의 세부 작업 (새 일정이면 빈 목록)
  final List<SubTask> initialTasks;

  static const int titleMaxLength = ScheduleFormScreen.titleMaxLength;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final editing = schedule;
    final now = ref.read(clockProvider)();
    final today = DateUtils.dateOnly(now);
    final id = useMemoized(() => editing?.id ?? newId());
    final defaultDate = DateUtils.dateOnly(initialDate ?? today);
    final defaultStart = useMemoized(
      () =>
          _defaultStart(now, isToday: DateUtils.isSameDay(defaultDate, today)),
    );

    final title = useTextEditingController(text: editing?.title);
    final memo = useTextEditingController(text: editing?.memo);
    final date = useState(editing?.date ?? defaultDate);
    final start = useState(editing?.startTime ?? defaultStart);
    final end = useState(
      editing?.endTime ??
          TimeOfDay(hour: defaultStart.hour + 1, minute: defaultStart.minute),
    );
    final tasks = useState(initialTasks);
    final triedSave = useState(false);
    final saving = useState(false);
    final saveFailed = useState(false);
    final taskInputFocus = useFocusNode();
    useListenable(title);

    final errors = validateSchedule(
      title: title.text,
      start: start.value,
      end: end.value,
    );
    // 시간 범위는 고르는 즉시, 제목은 저장을 한 번 눌러 본 뒤부터 알립니다.
    final timeError = errors.contains(ScheduleFormError.timeRange);
    final titleError =
        triedSave.value && errors.contains(ScheduleFormError.title);

    void reset() {
      title.clear();
      memo.clear();
      date.value = defaultDate;
      start.value = defaultStart;
      end.value = TimeOfDay(
        hour: defaultStart.hour + 1,
        minute: defaultStart.minute,
      );
      tasks.value = const [];
      triedSave.value = false;
      saveFailed.value = false;
    }

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: date.value,
        firstDate: DateTime(today.year - 5),
        lastDate: DateTime(today.year + 5, 12, 31),
      );
      if (picked != null) {
        date.value = picked;
      }
    }

    Future<void> pickTime(ValueNotifier<TimeOfDay> target) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: target.value,
      );
      if (picked != null) {
        target.value = picked;
      }
    }

    void addTask(String name) {
      tasks.value = [
        ...tasks.value,
        SubTask(
          id: newId(),
          scheduleId: id,
          title: name,
          sortOrder: nextSortOrder(tasks.value),
          createdAt: now,
          updatedAt: now,
        ),
      ];
    }

    void replaceTask(SubTask task) {
      tasks.value = [
        for (final other in tasks.value) other.id == task.id ? task : other,
      ];
    }

    Future<void> renameTask(SubTask task) async {
      final name = await promptRename(
        context,
        title: 'sub_task.rename_title'.tr(),
        initial: task.title,
      );
      if (name != null && name != task.title) {
        replaceTask(task.copyWith(title: name, updatedAt: now));
      }
    }

    Future<void> save() async {
      if (saving.value) {
        return;
      }
      triedSave.value = true;
      if (errors.isNotEmpty) {
        return;
      }
      saving.value = true;
      saveFailed.value = false;
      final savedAt = ref.read(clockProvider)();
      final draft = Schedule(
        id: id,
        title: title.text.trim(),
        date: date.value,
        startTime: start.value,
        endTime: end.value,
        memo: memo.text.trim(),
        isCompleted: editing?.isCompleted ?? false,
        createdAt: editing?.createdAt ?? savedAt,
        updatedAt: savedAt,
      );
      try {
        await ref.read(scheduleProvider.notifier).saveScheduleWithTasks(draft, [
          for (final (index, task) in tasks.value.indexed)
            task.copyWith(sortOrder: index),
        ]);
        // 저장한 일정이 바로 보이게 메인 화면을 그 날짜로 옮깁니다.
        ref.read(selectedDateProvider.notifier).select(draft.date);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } on Object {
        saveFailed.value = true;
        saving.value = false;
      }
    }

    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    // 오늘이 금요일 전일 때만 이번 주 금요일을 따로 보여 줍니다.
    final friday = today.weekday < DateTime.friday
        ? DateTime(
            today.year,
            today.month,
            today.day + DateTime.friday - today.weekday,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing == null
              ? 'schedule_form.title_new'.tr()
              : 'schedule_form.title_edit'.tr(),
        ),
        actions: [
          if (editing == null)
            TextButton(
              onPressed: reset,
              child: Text('schedule_form.reset'.tr()),
            ),
          const SizedBox(width: AppSpacing.sm),
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
            FormSection(
              label: 'schedule_form.field_title'.tr(),
              required: true,
              trailing: Text(
                '${title.text.characters.length}/$titleMaxLength',
                style: AppTypography.labelSm.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: title,
                    maxLength: titleMaxLength,
                    textInputAction: TextInputAction.next,
                    style: AppTypography.bodyLg.copyWith(
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'schedule_form.title_hint'.tr(),
                      errorText: titleError ? '' : null,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                    ),
                  ),
                  if (titleError) ...[
                    const SizedBox(height: AppSpacing.xs),
                    InlineErrorText('schedule_form.error.title'.tr()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FormSection(
              label: 'schedule_form.field_date'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateField(
                    date: date.value,
                    isToday: DateUtils.isSameDay(date.value, today),
                    onTap: pickDate,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _QuickDateChip(
                        label: 'schedule_form.quick.today'.tr(
                          args: [shortDateLabel(today)],
                        ),
                        selected: DateUtils.isSameDay(date.value, today),
                        onTap: () => date.value = today,
                      ),
                      _QuickDateChip(
                        label: 'schedule_form.quick.tomorrow'.tr(
                          args: [shortDateLabel(tomorrow)],
                        ),
                        selected: DateUtils.isSameDay(date.value, tomorrow),
                        onTap: () => date.value = tomorrow,
                      ),
                      if (friday != null &&
                          !DateUtils.isSameDay(friday, tomorrow))
                        _QuickDateChip(
                          label: 'schedule_form.quick.friday'.tr(),
                          selected: DateUtils.isSameDay(date.value, friday),
                          onTap: () => date.value = friday,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FormSection(
              label: 'schedule_form.field_time'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TimeFieldCard(
                          label: 'schedule_form.start'.tr(),
                          time: start.value,
                          onTap: () => pickTime(start),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TimeFieldCard(
                          label: 'schedule_form.end'.tr(),
                          time: end.value,
                          hasError: timeError,
                          onTap: () => pickTime(end),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (timeError)
                    InlineErrorText('schedule_form.error.time_range'.tr())
                  else
                    AppBadge(
                      'schedule_form.duration'.tr(
                        args: [
                          durationLabel(
                            minutesOf(end.value) - minutesOf(start.value),
                          ),
                        ],
                      ),
                      icon: Icons.timelapse_rounded,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FormSection(
              label: 'schedule_form.field_tasks'.tr(
                args: ['${tasks.value.length}'],
              ),
              trailing: TextButton.icon(
                onPressed: taskInputFocus.requestFocus,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('sub_task.add'.tr()),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final task in tasks.value) ...[
                    SubTaskTile(
                      key: ValueKey(task.id),
                      task: task,
                      onToggle: () => replaceTask(
                        task.copyWith(
                          isCompleted: !task.isCompleted,
                          updatedAt: now,
                        ),
                      ),
                      onRename: () => renameTask(task),
                      // 저장 전이라 되돌릴 수 있어 묻지 않고 뺍니다.
                      onDelete: () => tasks.value = [
                        ...tasks.value.where((other) => other.id != task.id),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  SubTaskInputField(onAdd: addTask, focusNode: taskInputFocus),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FormSection(
              label: 'schedule_form.field_memo'.tr(),
              trailing: Text(
                'schedule_form.optional'.tr(),
                style: AppTypography.labelSm.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              child: TextField(
                controller: memo,
                minLines: 3,
                maxLines: 8,
                maxLength: 500,
                keyboardType: TextInputType.multiline,
                style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'schedule_form.memo_hint'.tr(),
                  hintStyle: AppTypography.bodyMd.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(
        saving: saving.value,
        failed: saveFailed.value,
        onSave: save,
      ),
    );
  }

  /// 새 일정의 처음 시작 시각: 오늘이면 다음 정각, 다른 날이면 오전 9시.
  ///
  /// 한 시간짜리 일정이 자정을 넘지 않게 22시를 넘기지 않습니다.
  static TimeOfDay _defaultStart(DateTime now, {required bool isToday}) {
    if (!isToday) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    final next = now.hour + 1;
    return TimeOfDay(hour: next > 22 ? 22 : next, minute: 0);
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;

  final bool isToday;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: AppTapRow(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          fullDateLabel(context, date),
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLg.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: AppSpacing.sm),
                        AppBadge('common.today'.tr()),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.expand_more_rounded, color: colors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickDateChip extends StatelessWidget {
  const _QuickDateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;

  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: AppPressScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surfaceLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: selected ? colors.onPrimary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 화면 아래에 고정된 저장 버튼. 저장에 실패하면 버튼 위에 안내합니다.
class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.saving,
    required this.failed,
    required this.onSave,
  });

  final bool saving;

  final bool failed;

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: AppContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.gutter,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (failed) ...[
                  InlineErrorText('common.save_failed'.tr()),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AppFillButton(
                  label: 'schedule_form.save'.tr(),
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: saving ? null : onSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
