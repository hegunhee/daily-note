import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_status.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';

/// `09:30` 처럼 24시간제로 적은 시각
String timeLabel(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

/// `09:00 - 10:30`. 며칠에 걸친 일정은 `5/14 09:00 - 5/16 18:00`
String timeRangeLabel(Schedule schedule) => isMultiDay(schedule)
    ? '${shortDateLabel(schedule.date)} ${timeLabel(schedule.startTime)} - '
          '${shortDateLabel(schedule.endDate)} ${timeLabel(schedule.endTime)}'
    : '${timeLabel(schedule.startTime)} - ${timeLabel(schedule.endTime)}';

/// `1시간 30분` · `45분` · `2시간` · `2일 3시간`
///
/// 하루를 넘기면 분은 빼고 일·시간만 적습니다.
String durationLabel(int minutes) {
  final days = minutes ~/ Duration.minutesPerDay;
  if (days > 0) {
    final hours = minutes % Duration.minutesPerDay ~/ 60;
    return hours == 0
        ? 'common.duration.days'.tr(args: ['$days'])
        : 'common.duration.days_hours'.tr(args: ['$days', '$hours']);
  }
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) {
    return 'common.duration.minutes'.tr(args: ['$rest']);
  }
  if (rest == 0) {
    return 'common.duration.hours'.tr(args: ['$hours']);
  }
  return 'common.duration.hours_minutes'.tr(args: ['$hours', '$rest']);
}

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// `2025년 5월 14일 수요일`
String fullDateLabel(BuildContext context, DateTime date) =>
    DateFormat.yMMMMEEEEd(_locale(context)).format(date);

/// `2025년 5월 14일 수요일`. 며칠에 걸친 일정은 `5월 14일 (수) - 5월 16일 (금)`
String dateRangeLabel(BuildContext context, Schedule schedule) {
  if (!isMultiDay(schedule)) {
    return fullDateLabel(context, schedule.date);
  }
  final format = DateFormat.MMMEd(_locale(context));
  return '${format.format(schedule.date)} - ${format.format(schedule.endDate)}';
}

/// `5/14` — 빠른 날짜 칩처럼 좁은 자리의 날짜. 로케일과 상관없이 같은 모양입니다.
String shortDateLabel(DateTime date) => '${date.month}/${date.day}';

/// `수` 같은 짧은 요일
String weekdayLabel(BuildContext context, DateTime date) =>
    DateFormat.E(_locale(context)).format(date);

/// 상태 배지 문구
String statusLabel(ScheduleStatus status) =>
    'schedule.status.${status.name}'.tr();
