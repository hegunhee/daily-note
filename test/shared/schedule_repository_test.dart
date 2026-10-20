import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenlist/shared/repositories/schedule_repository.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/fake_schedule_repository.dart';

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('schedule_repository_test');
    Hive.init(directory.path);
  });

  tearDown(() async {
    await Hive.close();
    directory.deleteSync(recursive: true);
  });

  /// 앱을 껐다 켠 것처럼 상자를 닫고 같은 경로에서 새 저장소로 읽습니다.
  Future<ScheduleRepository> reopen() async {
    await Hive.close();
    Hive.init(directory.path);
    return ScheduleRepository();
  }

  test('저장한 일정·세부 작업이 다시 열어도 날짜·시각·완료 여부까지 그대로 읽힌다', () async {
    final schedule = testSchedule(
      id: 'wireframe',
      start: const TimeOfDay(hour: 11, minute: 5),
      end: const TimeOfDay(hour: 12, minute: 30),
      memo: '메모',
    );
    await ScheduleRepository().saveScheduleWithTasks(schedule, [
      testTask(id: 't0', scheduleId: 'wireframe', isCompleted: true),
      testTask(id: 't1', scheduleId: 'wireframe', sortOrder: 1),
    ]);

    final book = await (await reopen()).load();

    final read = book.scheduleById('wireframe')!;
    expect(read.date, DateTime(2025, 5, 14));
    expect(read.startTime, const TimeOfDay(hour: 11, minute: 5));
    expect(read.endTime, const TimeOfDay(hour: 12, minute: 30));
    expect(read.memo, '메모');
    final tasks = subTasksOf(book.subTasks, 'wireframe');
    expect(tasks.map((t) => t.isCompleted), [true, false]);
  });

  test('기간을 넣기 전에 저장한 일정은 종료 날짜가 시작 날짜와 같은 하루짜리로 읽힌다', () async {
    final legacy = testSchedule(id: 'old').toJson()..remove('endDate');
    await (await Hive.openBox<Map<dynamic, dynamic>>(
      'schedules',
    )).put('old', legacy);
    final repository = ScheduleRepository();
    await repository.saveScheduleWithTasks(
      testSchedule(id: 'goal', endDate: DateTime(2025, 5, 20)),
      const [],
    );

    final book = await (await reopen()).load();

    expect(book.scheduleById('old')!.endDate, DateTime(2025, 5, 14));
    expect(book.scheduleById('goal')!.endDate, DateTime(2025, 5, 20));
  });

  test('일정을 다시 저장하면 목록에서 빠진 세부 작업은 지워진다', () async {
    final repository = ScheduleRepository();
    final schedule = testSchedule(id: 's');
    await repository.saveScheduleWithTasks(schedule, [
      testTask(id: 'keep', scheduleId: 's'),
      testTask(id: 'drop', scheduleId: 's', sortOrder: 1),
    ]);
    await repository.saveScheduleWithTasks(schedule, [
      testTask(id: 'keep', scheduleId: 's'),
    ]);

    final book = await (await reopen()).load();

    expect(book.subTasks.map((t) => t.id), ['keep']);
  });

  test('일정을 지우면 그 일정의 세부 작업만 함께 지워진다', () async {
    final repository = ScheduleRepository();
    await repository.saveScheduleWithTasks(testSchedule(id: 'a'), [
      testTask(id: 'a0', scheduleId: 'a'),
    ]);
    await repository.saveScheduleWithTasks(testSchedule(id: 'b'), [
      testTask(id: 'b0', scheduleId: 'b'),
    ]);

    await repository.deleteSchedule('a');
    final book = await (await reopen()).load();

    expect(book.schedules.map((s) => s.id), ['b']);
    expect(book.subTasks.map((t) => t.id), ['b0']);
  });
}
