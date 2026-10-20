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

  test('며칠에 걸친 일정은 기간 안의 날마다 보이고, 이어지는 날에는 맨 위에 선다', () {
    final goal = testSchedule(
      id: 'goal',
      date: DateTime(2025, 5, 13),
      endDate: DateTime(2025, 5, 15),
      start: const TimeOfDay(hour: 20, minute: 0),
    );
    final book = designBook();
    final schedules = [...book.schedules, goal];

    expect(schedulesOn(schedules, DateTime(2025, 5, 12)), isEmpty);
    expect(schedulesOn(schedules, DateTime(2025, 5, 13)).map((s) => s.id), [
      'goal',
    ]);
    expect(schedulesOn(schedules, designNow).map((s) => s.id), [
      'goal',
      'meeting',
      'wireframe',
      'review',
    ]);
    expect(schedulesOn(schedules, DateTime(2025, 5, 15)).map((s) => s.id), [
      'goal',
      'tomorrow',
    ]);
    expect(schedulesOn(schedules, DateTime(2025, 5, 16)), isEmpty);
  });

  test('종료 날짜가 뒤면 종료 시각이 시작 시각보다 일러도 올바른 기간이다', () {
    const nine = TimeOfDay(hour: 9, minute: 0);
    const eight = TimeOfDay(hour: 8, minute: 0);
    final day = DateTime(2025, 5, 14);

    expect(
      isValidPeriod(
        startDate: day,
        start: nine,
        endDate: DateTime(2025, 5, 15),
        end: eight,
      ),
      isTrue,
    );
    expect(
      isValidPeriod(startDate: day, start: nine, endDate: day, end: eight),
      isFalse,
    );
    expect(
      isValidPeriod(
        startDate: day,
        start: eight,
        endDate: DateTime(2025, 5, 13),
        end: nine,
      ),
      isFalse,
    );
  });

  test('며칠에 걸친 일정은 시작 날짜부터 종료 날짜의 종료 시각까지 진행 중이다', () {
    final goal = testSchedule(
      id: 'goal',
      date: DateTime(2025, 5, 13),
      endDate: DateTime(2025, 5, 15),
      start: const TimeOfDay(hour: 20, minute: 0),
      end: const TimeOfDay(hour: 9, minute: 0),
    );

    expect(statusOf(goal, DateTime(2025, 5, 13, 19)), ScheduleStatus.upcoming);
    expect(statusOf(goal, DateTime(2025, 5, 14, 3)), ScheduleStatus.inProgress);
    expect(statusOf(goal, DateTime(2025, 5, 15, 9)), ScheduleStatus.past);
    expect(durationMinutes(goal), (24 + 13) * 60);
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
