import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenlist/shared/models/schedule_status.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';

import '../helpers/fake_schedule_repository.dart';

void main() {
  test('그날 일정만 시작 시각이 이른 순으로 고른다', () {
    final book = designBook();

    final day = schedulesOn(book.schedules, designNow);

    expect(day.map((s) => s.id), ['meeting', 'wireframe', 'review']);
  });

  test('시작 시각이 같으면 먼저 끝나는 일정이 위다', () {
    final long = testSchedule(
      id: 'long',
      end: const TimeOfDay(hour: 12, minute: 0),
    );
    final short = testSchedule(id: 'short');

    expect(schedulesOn([long, short], designNow).map((s) => s.id), [
      'short',
      'long',
    ]);
  });

  test('세부 작업이 없으면 진행률은 0%이고 완료로 보지 않는다', () {
    expect(progressOf([]), 0);
    expect(progressPercent([]), 0);
    expect(isAllDone([]), isFalse);
  });

  test('진행률은 완료 수 / 전체 수이고, 다 끝내기 전에는 100%로 보이지 않는다', () {
    final tasks = [
      for (var i = 0; i < 200; i++)
        testTask(id: '$i', scheduleId: 's', isCompleted: i > 0),
    ];

    expect(progressPercent(tasks.sublist(0, 3)), 67);
    // 199/200 = 99.5% 는 반올림하면 100% 지만 하나가 남았습니다.
    expect(progressPercent(tasks), 99);
    expect(isAllDone(tasks), isFalse);
    expect(progressPercent(tasks.sublist(1)), 100);
    expect(isAllDone(tasks.sublist(1)), isTrue);
  });

  test('종료 시각은 시작 시각보다 늦어야 한다', () {
    const nine = TimeOfDay(hour: 9, minute: 0);
    expect(isValidTimeRange(nine, const TimeOfDay(hour: 9, minute: 1)), isTrue);
    expect(isValidTimeRange(nine, nine), isFalse);
    expect(
      isValidTimeRange(nine, const TimeOfDay(hour: 8, minute: 59)),
      isFalse,
    );
  });

  test('시작 시각에 진행 중이 되고 종료 시각에 지난 일정이 된다', () {
    final schedule = testSchedule(id: 's');
    final day = DateUtils.dateOnly(designNow);

    expect(
      statusOf(schedule, day.add(const Duration(hours: 8, minutes: 59))),
      ScheduleStatus.upcoming,
    );
    expect(
      statusOf(schedule, day.add(const Duration(hours: 9))),
      ScheduleStatus.inProgress,
    );
    expect(
      statusOf(schedule, day.add(const Duration(hours: 10))),
      ScheduleStatus.past,
    );
  });

  test('완료 처리한 일정은 세부 작업이 남아도, 시각이 언제든 완료다', () {
    final done = testSchedule(id: 's', isCompleted: true);

    expect(statusOf(done, DateUtils.dateOnly(designNow)), ScheduleStatus.done);
  });

  test('새 세부 작업은 지운 작업이 있어도 맨 아래 순서를 받는다', () {
    final tasks = [
      testTask(id: 'a', scheduleId: 's'),
      testTask(id: 'c', scheduleId: 's', sortOrder: 2),
    ];

    expect(nextSortOrder(tasks), 3);
    expect(nextSortOrder([]), 0);
  });
}
