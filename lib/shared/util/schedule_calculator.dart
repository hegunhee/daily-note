import 'package:flutter/material.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_status.dart';
import 'package:greenlist/shared/models/sub_task.dart';

/// 0시부터 [time]까지의 분
int minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

/// 종료 시각이 시작 시각보다 늦은지 여부. 같은 시각이나 자정을 넘기는 범위는 막습니다.
bool isValidTimeRange(TimeOfDay start, TimeOfDay end) =>
    minutesOf(end) > minutesOf(start);

/// 일정의 길이(분)
int durationMinutes(Schedule schedule) =>
    minutesOf(schedule.endTime) - minutesOf(schedule.startTime);

/// [day]의 일정을 시작 시각이 이른 순으로 돌려줍니다.
///
/// 시작 시각이 같으면 먼저 끝나는 일정, 그것도 같으면 먼저 만든 일정이 위입니다.
List<Schedule> schedulesOn(List<Schedule> schedules, DateTime day) => [
  for (final schedule in schedules)
    if (DateUtils.isSameDay(schedule.date, day)) schedule,
]..sort(_byTime);

int _byTime(Schedule a, Schedule b) {
  final start = minutesOf(a.startTime).compareTo(minutesOf(b.startTime));
  if (start != 0) {
    return start;
  }
  final end = minutesOf(a.endTime).compareTo(minutesOf(b.endTime));
  return end != 0 ? end : a.createdAt.compareTo(b.createdAt);
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
/// 완료 처리한 일정은 시각과 상관없이 완료입니다. 시작 시각에 진행 중이 되고 종료
/// 시각에 지난 일정이 됩니다.
ScheduleStatus statusOf(Schedule schedule, DateTime now) {
  if (schedule.isCompleted) {
    return ScheduleStatus.done;
  }
  final day = DateUtils.dateOnly(schedule.date);
  final start = day.add(Duration(minutes: minutesOf(schedule.startTime)));
  final end = day.add(Duration(minutes: minutesOf(schedule.endTime)));
  if (now.isBefore(start)) {
    return ScheduleStatus.upcoming;
  }
  return now.isBefore(end) ? ScheduleStatus.inProgress : ScheduleStatus.past;
}

/// 새 세부 작업이 맨 아래에 오도록 쓸 순서 값
int nextSortOrder(List<SubTask> tasks) => tasks.isEmpty
    ? 0
    : tasks.map((task) => task.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
