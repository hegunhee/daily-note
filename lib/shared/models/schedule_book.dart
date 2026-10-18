import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/sub_task.dart';

/// 저장된 일정과 세부 작업 전체
///
/// 일정을 지우면 그 세부 작업도 함께 지워야 해서 둘을 한 상태로 묶습니다.
class ScheduleBook {
  const ScheduleBook({this.schedules = const [], this.subTasks = const []});

  final List<Schedule> schedules;

  final List<SubTask> subTasks;

  Schedule? scheduleById(String id) {
    for (final schedule in schedules) {
      if (schedule.id == id) {
        return schedule;
      }
    }
    return null;
  }

  ScheduleBook copyWith({
    List<Schedule>? schedules,
    List<SubTask>? subTasks,
  }) => ScheduleBook(
    schedules: schedules ?? this.schedules,
    subTasks: subTasks ?? this.subTasks,
  );
}
