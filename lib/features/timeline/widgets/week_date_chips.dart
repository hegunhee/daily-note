import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/util/schedule_labels.dart';
import 'package:greenlist/shared/widgets/app_press_scale.dart';

/// 고른 날짜가 들어 있는 한 주(월~일)를 칩 7개로 보여 줍니다.
///
/// 고른 날은 primary 로 채우고, 오늘은 주황 점, 일정이 있는 날은 초록 점을 찍습니다.
class WeekDateChips extends StatelessWidget {
  const WeekDateChips({
    required this.selected,
    required this.today,
    required this.hasSchedules,
    required this.onSelected,
    super.key,
  });

  final DateTime selected;

  final DateTime today;

  /// 그날 일정이 있는지 여부
  final bool Function(DateTime day) hasSchedules;

  final ValueChanged<DateTime> onSelected;

  static const _height = 64.0;

  @override
  Widget build(BuildContext context) {
    final monday = DateTime(
      selected.year,
      selected.month,
      selected.day - (selected.weekday - DateTime.monday),
    );
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm - 2),
          Expanded(
            child: _DateChip(
              day: DateTime(monday.year, monday.month, monday.day + i),
              selected: selected,
              today: today,
              hasSchedules: hasSchedules,
              onSelected: onSelected,
            ),
          ),
        ],
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.day,
    required this.selected,
    required this.today,
    required this.hasSchedules,
    required this.onSelected,
  });

  final DateTime day;

  final DateTime selected;

  final DateTime today;

  final bool Function(DateTime day) hasSchedules;

  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = DateUtils.isSameDay(day, selected);
    final isToday = DateUtils.isSameDay(day, today);
    final dot = isToday
        ? colors.accent
        : !hasSchedules(day)
        ? null
        : isSelected
        ? colors.onPrimary
        : colors.primary;

    return Semantics(
      selected: isSelected,
      button: true,
      label: fullDateLabel(context, day),
      excludeSemantics: true,
      child: AppPressScale(
        onTap: () => onSelected(day),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: WeekDateChips._height,
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: isSelected ? null : Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekdayLabel(context, day),
                style: AppTypography.labelSm.copyWith(
                  color: isSelected ? colors.onPrimary : colors.textTertiary,
                ),
              ),
              FittedBox(
                child: Text(
                  '${day.day}',
                  style: AppTypography.timeMd.copyWith(
                    color: isSelected ? colors.onPrimary : colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                height: 6,
                child: dot == null
                    ? null
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: dot,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox.square(dimension: 5),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
