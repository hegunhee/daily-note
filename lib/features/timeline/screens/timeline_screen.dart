import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/features/schedule_detail/screens/schedule_detail_screen.dart';
import 'package:greenlist/features/schedule_form/screens/schedule_form_screen.dart';
import 'package:greenlist/features/timeline/widgets/day_progress_card.dart';
import 'package:greenlist/features/timeline/widgets/schedule_timeline_card.dart';
import 'package:greenlist/features/timeline/widgets/timeline_empty_card.dart';
import 'package:greenlist/features/timeline/widgets/week_date_chips.dart';
import 'package:greenlist/shared/controllers/clock_controller.dart';
import 'package:greenlist/shared/controllers/schedule_controller.dart';
import 'package:greenlist/shared/hooks/use_now.dart';
import 'package:greenlist/shared/models/schedule_book.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:greenlist/shared/util/schedule_labels.dart';
import 'package:greenlist/shared/widgets/app_content_width.dart';
import 'package:greenlist/shared/widgets/app_error_view.dart';
import 'package:greenlist/shared/widgets/app_fill_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 메인 화면 — 고른 날짜의 일정을 시작 시각순 세로 타임라인으로 보여 줍니다.
///
/// 시안: `docs/design/screens/timeline` · `empty`
class TimelineScreen extends HookConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(scheduleProvider);
    final colors = context.colors;
    return Scaffold(
      floatingActionButton: book.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => _openNew(context, ref),
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 2,
              highlightElevation: 2,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'timeline.add'.tr(),
                style: AppTypography.labelLg.copyWith(color: colors.onPrimary),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: switch (book) {
          // 다시 읽는 동안에도 읽어 둔 값을 그대로 보여 줍니다.
          AsyncValue(:final value?) => _TimelineBody(book: value),
          AsyncError() => AppErrorView(
            message: 'common.load_failed'.tr(),
            onRetry: () => ref.invalidate(scheduleProvider),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

/// 지금 보는 날짜로 새 일정 입력을 엽니다.
void _openNew(BuildContext context, WidgetRef ref) {
  Navigator.of(
    context,
  ).push(ScheduleFormScreen.route(initialDate: ref.read(selectedDateProvider)));
}

class _TimelineBody extends HookConsumerWidget {
  const _TimelineBody({required this.book});

  final ScheduleBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final now = useNow(ref.watch(clockProvider));
    final today = DateUtils.dateOnly(now);
    final selected = ref.watch(selectedDateProvider);
    final dates = ref.read(selectedDateProvider.notifier);
    final isToday = DateUtils.isSameDay(selected, today);
    final schedules = schedulesOn(book.schedules, selected);
    final scheduledDays = {
      for (final schedule in book.schedules) DateUtils.dateOnly(schedule.date),
    };

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selected,
        firstDate: DateTime(today.year - 5),
        lastDate: DateTime(today.year + 5, 12, 31),
      );
      if (picked != null) {
        dates.select(picked);
      }
    }

    return AppContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          // 아래에 떠 있는 버튼에 마지막 카드가 가리지 않게 비워 둡니다.
          AppSpacing.xxl * 3,
        ),
        children: [
          _BrandBar(onPickDate: pickDate),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  fullDateLabel(context, selected),
                  style: AppTypography.bodySm.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'timeline.prev_day'.tr(),
                onPressed: () => dates.shift(-1),
                icon: const Icon(Icons.chevron_left_rounded),
                color: colors.textSecondary,
              ),
              TextButton(
                onPressed: isToday ? null : dates.goToday,
                child: Text('timeline.go_today'.tr()),
              ),
              IconButton(
                tooltip: 'timeline.next_day'.tr(),
                onPressed: () => dates.shift(1),
                icon: const Icon(Icons.chevron_right_rounded),
                color: colors.textSecondary,
              ),
            ],
          ),
          Text(
            isToday ? 'timeline.title_today'.tr() : 'timeline.title_other'.tr(),
            style: AppTypography.headlineLg.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'timeline.greeting'.tr(),
            style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          WeekDateChips(
            selected: selected,
            today: today,
            hasSchedules: scheduledDays.contains,
            onSelected: dates.select,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (schedules.isEmpty)
            TimelineEmptyCard(
              isToday: isToday,
              action: AppFillButton(
                label: 'timeline.add_first'.tr(),
                icon: Icons.add_rounded,
                onPressed: () => _openNew(context, ref),
              ),
            )
          else ...[
            DayProgressCard(
              tasks: subTasksOfAll(book.subTasks, schedules),
              isToday: isToday,
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final (index, schedule) in schedules.indexed)
              ScheduleTimelineCard(
                key: ValueKey(schedule.id),
                schedule: schedule,
                tasks: subTasksOf(book.subTasks, schedule.id),
                status: statusOf(schedule, now),
                isLast: index == schedules.length - 1,
                onOpen: () => Navigator.of(
                  context,
                ).push(ScheduleDetailScreen.route(schedule.id)),
                onEdit: () => Navigator.of(
                  context,
                ).push(ScheduleFormScreen.route(schedule: schedule)),
              ),
          ],
        ],
      ),
    );
  }
}

/// 맨 위의 로고·앱 이름과 날짜 고르기 버튼
class _BrandBar extends StatelessWidget {
  const _BrandBar({required this.onPickDate});

  final VoidCallback onPickDate;

  static const _logoSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Container(
            width: _logoSize,
            height: _logoSize,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(Icons.check_rounded, color: colors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'common.app_name'.tr(),
                  style: AppTypography.headlineSm.copyWith(
                    color: colors.primary,
                  ),
                ),
                Text(
                  'timeline.brand_caption'.tr(),
                  style: AppTypography.labelSm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'timeline.pick_date'.tr(),
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
