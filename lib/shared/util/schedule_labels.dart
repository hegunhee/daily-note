import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_status.dart';

/// `09:30` 처럼 24시간제로 적은 시각
String timeLabel(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

/// `09:00 - 10:30`
String timeRangeLabel(Schedule schedule) =>
    '${timeLabel(schedule.startTime)} - ${timeLabel(schedule.endTime)}';

/// `1시간 30분` · `45분` · `2시간`
String durationLabel(int minutes) {
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

/// `5/14`
String shortDateLabel(BuildContext context, DateTime date) =>
    DateFormat.Md(_locale(context)).format(date);

/// `수` 같은 짧은 요일
String weekdayLabel(BuildContext context, DateTime date) =>
    DateFormat.E(_locale(context)).format(date);

/// 상태 배지 문구
String statusLabel(ScheduleStatus status) =>
    'schedule.status.${status.name}'.tr();
