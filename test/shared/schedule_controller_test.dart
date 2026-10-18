import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenlist/shared/controllers/clock_controller.dart';
import 'package:greenlist/shared/controllers/schedule_controller.dart';
import 'package:greenlist/shared/repositories/schedule_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../helpers/fake_schedule_repository.dart';

void main() {
  late FakeScheduleRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeScheduleRepository(designBook());
    container = ProviderContainer(
      overrides: [
        scheduleRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => designNow),
      ],
    );
    addTearDown(container.dispose);
  });

  ScheduleController controller() => container.read(scheduleProvider.notifier);

  test('체크를 저장하지 못하면 화면에 먼저 반영한 완료 표시를 되돌린다', () async {
    await container.read(scheduleProvider.future);
    repository.failWrites = true;

    await expectLater(controller().toggleSubTask('wire-2'), throwsStateError);

    final task = container
        .read(scheduleProvider)
        .requireValue
        .subTasks
        .firstWhere((t) => t.id == 'wire-2');
    expect(task.isCompleted, isFalse);
  });

  test('종료 시각이 시작보다 이르면 저장하지 않는다', () async {
    await container.read(scheduleProvider.future);
    final invalid = testSchedule(
      id: 'new',
      start: const TimeOfDay(hour: 10, minute: 0),
      end: const TimeOfDay(hour: 9, minute: 0),
    );

    await expectLater(
      controller().saveScheduleWithTasks(invalid, const []),
      throwsArgumentError,
    );

    expect(repository.book.scheduleById('new'), isNull);
  });

  test('일정을 지우면 상태에서도 그 세부 작업이 사라진다', () async {
    await container.read(scheduleProvider.future);

    await controller().deleteSchedule('wireframe');

    final book = container.read(scheduleProvider).requireValue;
    expect(book.scheduleById('wireframe'), isNull);
    expect(book.subTasks.where((t) => t.scheduleId == 'wireframe'), isEmpty);
  });

  test('일정 완료 처리는 세부 작업의 완료 여부를 바꾸지 않는다', () async {
    await container.read(scheduleProvider.future);

    await controller().setScheduleCompleted('review', completed: true);

    final book = container.read(scheduleProvider).requireValue;
    expect(book.scheduleById('review')!.isCompleted, isTrue);
    expect(
      book.subTasks.where((t) => t.scheduleId == 'review' && t.isCompleted),
      isEmpty,
    );
  });
}
