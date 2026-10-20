import 'package:flutter/material.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_status.dart';
import 'package:greenlist/shared/models/sub_task.dart';

/// 0시부터 [time]까지의 분
int minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

/// 종료 시각이 시작 시각보다 늦은지 여부. 같은 시각이나 자정을 넘기는 범위는 막습니다.
bool isValidTimeRange(TimeOfDay start, TimeOfDay end) =>
    minutesOf(end) > minutesOf(start);

/// [from]부터 [to]까지의 달력 날짜 수. 일광 절약 시간으로 하루가 23·25시간이어도 1일로 셉니다.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// 종료 시점(날짜·시각)이 시작 시점보다 늦은지 여부
///
/// 같은 날이면 [isValidTimeRange]와 같고, 종료 날짜가 뒤면 시각과 상관없이 늦습니다.
bool isValidPeriod({
  required DateTime startDate,
  required TimeOfDay start,
  required DateTime endDate,
  required TimeOfDay end,
}) {
  final days = daysBetween(startDate, endDate);
  return days > 0 || (days == 0 && isValidTimeRange(start, end));
}

/// 일정이 하루를 넘겨 이어지는지 여부
bool isMultiDay(Schedule schedule) =>
    daysBetween(schedule.date, schedule.endDate) > 0;

/// 일정의 길이(분). 며칠에 걸친 일정은 시작부터 종료까지 전부 셉니다.
int durationMinutes(Schedule schedule) =>
    daysBetween(schedule.date, schedule.endDate) * Duration.minutesPerDay +
    minutesOf(schedule.endTime) -
    minutesOf(schedule.startTime);

/// [day]가 일정의 시작 날짜부터 종료 날짜 사이에 드는지 여부
bool coversDay(Schedule schedule, DateTime day) =>
    daysBetween(schedule.date, day) >= 0 &&
    daysBetween(day, schedule.endDate) >= 0;

/// 일정이 걸친 날짜 전부 (시작 날짜부터 하루씩)
List<DateTime> daysOf(Schedule schedule) => [
  for (var i = 0; i <= daysBetween(schedule.date, schedule.endDate); i++)
    DateTime(schedule.date.year, schedule.date.month, schedule.date.day + i),
];

/// [day]에 걸친 일정을 그날 시작 시각이 이른 순으로 돌려줍니다.
///
/// 전날부터 이어지는 일정은 그날 0시에 시작한 것으로 보고 맨 위에 둡니다. 시작이 같으면
/// 먼저 끝나는 일정, 그것도 같으면 먼저 만든 일정이 위입니다.
List<Schedule> schedulesOn(List<Schedule> schedules, DateTime day) {
  int startOn(Schedule s) =>
      DateUtils.isSameDay(s.date, day) ? minutesOf(s.startTime) : 0;
  int endOn(Schedule s) => DateUtils.isSameDay(s.endDate, day)
      ? minutesOf(s.endTime)
      : Duration.minutesPerDay;
  return [
    for (final schedule in schedules)
      if (coversDay(schedule, day)) schedule,
  ]..sort((a, b) {
    final start = startOn(a).compareTo(startOn(b));
    if (start != 0) {
      return start;
    }
    final end = endOn(a).compareTo(endOn(b));
    return end != 0 ? end : a.createdAt.compareTo(b.createdAt);
  });
}

/// [scheduleId] 일정의 세부 작업을 정한 순서대로 돌려줍니다.
List<SubTask> subTasksOf(List<SubTask> subTasks, String scheduleId) => [
  for (final task in subTasks)
    if (task.scheduleId == scheduleId) task,
]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

/// [schedules]에 딸린 세부 작업 전체 (그날 진행 상황용)
List<SubTask> subTasksOfAll(List<SubTask> subTasks, List<Schedule> schedules) {
  final ids = {for (final schedule in schedules) schedule.id};
  return [
    for (final task in subTasks)
      if (ids.contains(task.scheduleId)) task,
  ];
}

/// 완료한 세부 작업 수
int completedCount(List<SubTask> tasks) =>
    tasks.where((task) => task.isCompleted).length;

/// 완료 작업 수 / 전체 작업 수. 작업이 없으면 0입니다.
double progressOf(List<SubTask> tasks) =>
    tasks.isEmpty ? 0 : completedCount(tasks) / tasks.length;

/// 화면에 적는 진행률(%)
///
/// 반올림하되, 다 끝내지 않았는데 100%로 보이지 않게 99%에서 멈춥니다.
int progressPercent(List<SubTask> tasks) {
  final percent = (progressOf(tasks) * 100).round();
  return percent == 100 && !isAllDone(tasks) ? 99 : percent;
}

/// 세부 작업이 하나 이상 있고 모두 완료했는지 여부
bool isAllDone(List<SubTask> tasks) =>
    tasks.isNotEmpty && tasks.every((task) => task.isCompleted);

/// [now] 기준 일정의 진행 상태
///
/// 완료 처리한 일정은 시각과 상관없이 완료입니다. 시작 날짜의 시작 시각에 진행 중이 되고
/// 종료 날짜의 종료 시각에 지난 일정이 됩니다.
ScheduleStatus statusOf(Schedule schedule, DateTime now) {
  if (schedule.isCompleted) {
    return ScheduleStatus.done;
  }
  final start = _at(schedule.date, schedule.startTime);
  final end = _at(schedule.endDate, schedule.endTime);
  if (now.isBefore(start)) {
    return ScheduleStatus.upcoming;
  }
  return now.isBefore(end) ? ScheduleStatus.inProgress : ScheduleStatus.past;
}

DateTime _at(DateTime day, TimeOfDay time) =>
    DateTime(day.year, day.month, day.day, time.hour, time.minute);

/// 새 세부 작업이 맨 아래에 오도록 쓸 순서 값
int nextSortOrder(List<SubTask> tasks) => tasks.isEmpty
    ? 0
    : tasks.map((task) => task.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
