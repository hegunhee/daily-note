import 'package:flutter/material.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/models/schedule_book.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:greenlist/shared/repositories/schedule_repository.dart';

/// 시안이 오늘로 그린 날짜·시각 (2025년 5월 14일 수요일 11:30, 두 번째 일정 진행 중)
final designNow = DateTime(2025, 5, 14, 11, 30);

/// 로컬 DB 대신 메모리에 일정을 들고 있는 저장소
class FakeScheduleRepository implements ScheduleRepository {
  FakeScheduleRepository([ScheduleBook? book])
    : book = book ?? const ScheduleBook();

  ScheduleBook book;

  /// true면 쓰기마다 예외를 던집니다 (저장 실패 재현).
  var failWrites = false;

  void _check() {
    if (failWrites) {
      throw StateError('저장 실패');
    }
  }

  @override
  Future<ScheduleBook> load() async => book;

  @override
  Future<void> saveScheduleWithTasks(
    Schedule schedule,
    List<SubTask> subTasks,
  ) async {
    _check();
    book = book.copyWith(
      schedules: [
        ...book.schedules.where((s) => s.id != schedule.id),
        schedule,
      ],
      subTasks: [
        ...book.subTasks.where((t) => t.scheduleId != schedule.id),
        ...subTasks,
      ],
    );
  }

  @override
  Future<void> saveSchedule(Schedule schedule) async {
    _check();
    book = book.copyWith(
      schedules: [
        ...book.schedules.where((s) => s.id != schedule.id),
        schedule,
      ],
    );
  }

  @override
  Future<void> deleteSchedule(String id) async {
    _check();
    book = book.copyWith(
      schedules: [...book.schedules.where((s) => s.id != id)],
      subTasks: [...book.subTasks.where((t) => t.scheduleId != id)],
    );
  }

  @override
  Future<void> saveSubTask(SubTask task) async {
    _check();
    book = book.copyWith(
      subTasks: [...book.subTasks.where((t) => t.id != task.id), task],
    );
  }

  @override
  Future<void> deleteSubTask(String id) async {
    _check();
    book = book.copyWith(
      subTasks: [...book.subTasks.where((t) => t.id != id)],
    );
  }
}

/// 테스트용 일정
Schedule testSchedule({
  required String id,
  DateTime? date,
  DateTime? endDate,
  TimeOfDay start = const TimeOfDay(hour: 9, minute: 0),
  TimeOfDay end = const TimeOfDay(hour: 10, minute: 0),
  String title = '일정',
  String memo = '',
  bool isCompleted = false,
}) {
  final at = date ?? DateUtils.dateOnly(designNow);
  return Schedule(
    id: id,
    title: title,
    date: at,
    endDate: endDate,
    startTime: start,
    endTime: end,
    memo: memo,
    isCompleted: isCompleted,
    createdAt: at,
    updatedAt: at,
  );
}

/// 테스트용 세부 작업
SubTask testTask({
  required String id,
  required String scheduleId,
  String title = '작업',
  int sortOrder = 0,
  bool isCompleted = false,
}) => SubTask(
  id: id,
  scheduleId: scheduleId,
  title: title,
  sortOrder: sortOrder,
  isCompleted: isCompleted,
  createdAt: designNow,
  updatedAt: designNow,
);

/// 시안(`docs/design/screens/timeline`)의 하루: 완료한 회의, 진행 중인 설계, 대기 중인 리뷰
ScheduleBook designBook() => ScheduleBook(
  schedules: [
    testSchedule(
      id: 'review',
      title: '프로덕트 백로그 우선순위 리뷰',
      start: const TimeOfDay(hour: 14, minute: 0),
      end: const TimeOfDay(hour: 15, minute: 30),
    ),
    testSchedule(
      id: 'meeting',
      title: '주간 디자인 시스템 스프린트 미팅',
      memo: '슬랙 #design-team 채널에 회의록 아카이빙 완료',
      isCompleted: true,
    ),
    testSchedule(
      id: 'wireframe',
      title: 'Greenlist 모바일 상세 화면 와이어프레임 설계',
      start: const TimeOfDay(hour: 11, minute: 0),
      end: const TimeOfDay(hour: 12, minute: 30),
      memo: '피그마 프로토타입 2차 링크 첨부 예정',
    ),
    testSchedule(
      id: 'tomorrow',
      title: '내일 일정',
      date: DateTime(2025, 5, 15),
    ),
  ],
  subTasks: [
    for (final (index, title) in ['토큰 대비 검토', '컴포넌트 정리', '피드백 공유'].indexed)
      testTask(
        id: 'meeting-$index',
        scheduleId: 'meeting',
        title: title,
        sortOrder: index,
        isCompleted: true,
      ),
    testTask(
      id: 'wire-0',
      scheduleId: 'wireframe',
      title: '체크 인터랙션 정리',
      isCompleted: true,
    ),
    testTask(
      id: 'wire-1',
      scheduleId: 'wireframe',
      title: '하단 플로팅 버튼 배치',
      sortOrder: 1,
      isCompleted: true,
    ),
    testTask(
      id: 'wire-2',
      scheduleId: 'wireframe',
      title: '빈 상태 가이드 작성',
      sortOrder: 2,
    ),
    testTask(id: 'review-0', scheduleId: 'review', title: '로드맵 검토'),
    testTask(
      id: 'review-1',
      scheduleId: 'review',
      title: '스프린트 티켓 생성',
      sortOrder: 1,
    ),
  ],
);
