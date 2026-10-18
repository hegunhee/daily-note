import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_book.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:hive_ce/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 일정 저장소 Provider
final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepository(),
);

/// 일정과 세부 작업을 기기의 로컬 DB(Hive)에 읽고 씁니다.
///
/// 일정·세부 작업을 상자 하나씩에 id를 키로, `toJson()` 맵을 값으로 저장합니다.
class ScheduleRepository {
  static const _schedules = 'schedules';
  static const _subTasks = 'sub_tasks';

  Future<Box<Map<dynamic, dynamic>>> _box(String name) => Hive.openBox(name);

  /// 저장된 일정과 세부 작업 전체를 읽습니다.
  Future<ScheduleBook> load() async {
    List<Map<String, dynamic>> rows(Box<Map<dynamic, dynamic>> box) => [
      for (final row in box.values) Map<String, dynamic>.from(row),
    ];
    return ScheduleBook(
      schedules: rows(await _box(_schedules)).map(Schedule.fromJson).toList(),
      subTasks: rows(await _box(_subTasks)).map(SubTask.fromJson).toList(),
    );
  }

  /// 일정 하나와 그 세부 작업 목록을 저장합니다.
  ///
  /// [subTasks]가 그 일정의 세부 작업 전부입니다. 목록에서 빠진 작업은 지웁니다.
  Future<void> saveScheduleWithTasks(
    Schedule schedule,
    List<SubTask> subTasks,
  ) async {
    final tasks = await _box(_subTasks);
    final kept = {for (final task in subTasks) task.id};
    final removed = [
      for (final MapEntry(:key, :value) in tasks.toMap().entries)
        if (value['scheduleId'] == schedule.id && !kept.contains(key)) key,
    ];
    await tasks.deleteAll(removed);
    await tasks.putAll({for (final task in subTasks) task.id: task.toJson()});
    await (await _box(_schedules)).put(schedule.id, schedule.toJson());
  }

  /// 일정 하나만 고쳐 저장합니다 (메모·완료 처리).
  Future<void> saveSchedule(Schedule schedule) async {
    await (await _box(_schedules)).put(schedule.id, schedule.toJson());
  }

  /// 일정 하나와 그 세부 작업을 모두 지웁니다.
  Future<void> deleteSchedule(String id) async {
    final tasks = await _box(_subTasks);
    await tasks.deleteAll([
      for (final MapEntry(:key, :value) in tasks.toMap().entries)
        if (value['scheduleId'] == id) key,
    ]);
    await (await _box(_schedules)).delete(id);
  }

  /// 세부 작업 하나를 더하거나 고쳐 저장합니다.
  Future<void> saveSubTask(SubTask task) async {
    await (await _box(_subTasks)).put(task.id, task.toJson());
  }

  /// 세부 작업 하나를 지웁니다.
  Future<void> deleteSubTask(String id) async {
    await (await _box(_subTasks)).delete(id);
  }
}
