import 'package:greenlist/shared/controllers/clock_controller.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_book.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:greenlist/shared/repositories/schedule_repository.dart';
import 'package:greenlist/shared/util/new_id.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 일정 Provider
final scheduleProvider =
    AsyncNotifierProvider<ScheduleController, ScheduleBook>(
      ScheduleController.new,
    );

/// 로컬 DB의 일정과 세부 작업을 읽고 고치는 컨트롤러
///
/// 저장에 성공한 뒤 상태를 바꿉니다. 체크박스는 누르는 즉시 보여야 해서 먼저 바꾸고,
/// 저장에 실패하면 되돌린 뒤 예외를 다시 던집니다.
class ScheduleController extends AsyncNotifier<ScheduleBook> {
  @override
  Future<ScheduleBook> build() => ref.read(scheduleRepositoryProvider).load();

  ScheduleRepository get _repository => ref.read(scheduleRepositoryProvider);

  DateTime _now() => ref.read(clockProvider)();

  /// 일정과 그 세부 작업 목록을 함께 저장합니다. 같은 id 의 일정이 있으면 고칩니다.
  ///
  /// [subTasks]가 그 일정의 세부 작업 전부입니다.
  Future<void> saveScheduleWithTasks(
    Schedule schedule,
    List<SubTask> subTasks,
  ) async {
    if (!isValidTimeRange(schedule.startTime, schedule.endTime)) {
      throw ArgumentError('종료 시각은 시작 시각보다 늦어야 합니다.');
    }
    final book = await future;
    await _repository.saveScheduleWithTasks(schedule, subTasks);
    state = AsyncData(
      book.copyWith(
        schedules: _upsert(book.schedules, schedule, (s) => s.id),
        subTasks: [
          ...book.subTasks.where((task) => task.scheduleId != schedule.id),
          ...subTasks,
        ],
      ),
    );
  }

  /// 일정과 그 세부 작업을 모두 지웁니다.
  Future<void> deleteSchedule(String id) async {
    final book = await future;
    await _repository.deleteSchedule(id);
    state = AsyncData(
      book.copyWith(
        schedules: [...book.schedules.where((s) => s.id != id)],
        subTasks: [...book.subTasks.where((task) => task.scheduleId != id)],
      ),
    );
  }

  /// 일정을 완료 처리하거나 되돌립니다. 세부 작업의 완료 여부는 건드리지 않습니다.
  Future<void> setScheduleCompleted(String id, {required bool completed}) =>
      _updateSchedule(
        id,
        (schedule) => schedule.copyWith(isCompleted: completed),
      );

  /// 일정의 메모를 고칩니다.
  Future<void> updateMemo(String id, String memo) =>
      _updateSchedule(id, (schedule) => schedule.copyWith(memo: memo.trim()));

  Future<void> _updateSchedule(
    String id,
    Schedule Function(Schedule) change,
  ) async {
    final book = await future;
    final schedule = book.scheduleById(id);
    if (schedule == null) {
      return;
    }
    final updated = change(schedule).copyWith(updatedAt: _now());
    await _repository.saveSchedule(updated);
    state = AsyncData(
      book.copyWith(schedules: _upsert(book.schedules, updated, (s) => s.id)),
    );
  }

  /// 일정 맨 아래에 세부 작업을 더합니다. 이름이 비어 있으면 더하지 않습니다.
  Future<void> addSubTask(String scheduleId, String title) async {
    final name = title.trim();
    if (name.isEmpty) {
      return;
    }
    final book = await future;
    final now = _now();
    final task = SubTask(
      id: newId(),
      scheduleId: scheduleId,
      title: name,
      sortOrder: nextSortOrder(subTasksOf(book.subTasks, scheduleId)),
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveSubTask(task);
    state = AsyncData(book.copyWith(subTasks: [...book.subTasks, task]));
  }

  /// 세부 작업의 이름을 고칩니다. 이름이 비어 있으면 고치지 않습니다.
  Future<void> renameSubTask(String id, String title) async {
    final name = title.trim();
    if (name.isEmpty) {
      return;
    }
    final book = await future;
    final task = _taskById(book, id);
    if (task == null || task.title == name) {
      return;
    }
    final updated = task.copyWith(title: name, updatedAt: _now());
    await _repository.saveSubTask(updated);
    state = AsyncData(
      book.copyWith(subTasks: _upsert(book.subTasks, updated, (t) => t.id)),
    );
  }

  /// 세부 작업의 완료·미완료를 바꿉니다. 화면에 먼저 반영하고 저장합니다.
  Future<void> toggleSubTask(String id) async {
    final book = await future;
    final task = _taskById(book, id);
    if (task == null) {
      return;
    }
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: _now(),
    );
    state = AsyncData(
      book.copyWith(subTasks: _upsert(book.subTasks, updated, (t) => t.id)),
    );
    try {
      await _repository.saveSubTask(updated);
    } on Object {
      state = AsyncData(book);
      rethrow;
    }
  }

  /// 세부 작업 하나를 지웁니다.
  Future<void> deleteSubTask(String id) async {
    final book = await future;
    await _repository.deleteSubTask(id);
    state = AsyncData(
      book.copyWith(subTasks: [...book.subTasks.where((t) => t.id != id)]),
    );
  }

  SubTask? _taskById(ScheduleBook book, String id) {
    for (final task in book.subTasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  /// [item]과 id가 같은 항목을 바꾸고, 없으면 끝에 더합니다.
  List<T> _upsert<T>(List<T> list, T item, String Function(T) idOf) {
    final id = idOf(item);
    final index = list.indexWhere((other) => idOf(other) == id);
    return index < 0
        ? [...list, item]
        : [...list.sublist(0, index), item, ...list.sublist(index + 1)];
  }
}
