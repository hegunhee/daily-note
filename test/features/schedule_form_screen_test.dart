import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenlist/features/schedule_form/screens/schedule_form_screen.dart';
import 'package:greenlist/features/timeline/screens/timeline_screen.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';

import '../helpers/pump_app.dart';

const _tall = Size(390, 2000);

void main() {
  testWidgets('새 일정을 세부 작업과 함께 저장하면 메인 화면 시간순 자리에 보인다', (tester) async {
    final repository = await pumpApp(
      tester,
      const TimelineScreen(),
      size: _tall,
    );

    await tester.tap(find.text('새 일정 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '점심 산책');
    final taskInput = find.widgetWithText(TextField, '새로운 세부 작업 입력 후 Enter');
    await tester.enterText(taskInput, '물 챙기기');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.enterText(taskInput, '스트레칭');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('일정 저장하기'));
    await tester.pumpAndSettle();

    // 지금(11:30) 다음 정각인 12:00-13:00 으로 들어가 설계(11:00)와 리뷰(14:00) 사이에 섭니다.
    final walk = find.text('점심 산책');
    expect(walk, findsOneWidget);
    expect(
      tester.getTopLeft(walk).dy,
      greaterThan(
        tester.getTopLeft(find.text('Greenlist 모바일 상세 화면 와이어프레임 설계')).dy,
      ),
    );
    expect(
      tester.getTopLeft(walk).dy,
      lessThan(tester.getTopLeft(find.text('프로덕트 백로그 우선순위 리뷰')).dy),
    );
    final saved = repository.book.schedules.firstWhere(
      (s) => s.title == '점심 산책',
    );
    expect(saved.date, DateTime(2025, 5, 14));
    expect(subTasksOf(repository.book.subTasks, saved.id).map((t) => t.title), [
      '물 챙기기',
      '스트레칭',
    ]);
  });

  testWidgets('제목이 비어 있으면 저장하지 않고 제목 아래에 알린다', (tester) async {
    final repository = await pumpApp(
      tester,
      const ScheduleFormScreen(),
      size: _tall,
    );
    final before = repository.book.schedules.length;

    await tester.tap(find.text('일정 저장하기'));
    await tester.pumpAndSettle();

    expect(find.text('제목을 한 글자 이상 입력해 주세요.'), findsOneWidget);
    expect(repository.book.schedules, hasLength(before));
  });

  testWidgets('종료 시각을 시작보다 이르게 고르면 바로 알리고 저장을 막는다', (tester) async {
    final repository = await pumpApp(tester, const SizedBox(), size: _tall);
    final meeting = repository.book.scheduleById('meeting')!;
    await pumpApp(
      tester,
      ScheduleFormScreen(schedule: meeting),
      book: repository.book,
      size: _tall,
    );

    // 09:00-10:00 의 종료를 오전 8:00 으로 바꿉니다.
    await tester.tap(find.text('10:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), '8');
    await tester.enterText(fields.at(1), '00');
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('확인')),
    );
    await tester.pumpAndSettle();

    expect(find.text('종료 시간은 시작 시간보다 늦어야 해요.'), findsOneWidget);
    await tester.tap(find.text('일정 저장하기'));
    await tester.pumpAndSettle();
    expect(find.byType(ScheduleFormScreen), findsOneWidget);
  });

  testWidgets('수정에서 뺀 세부 작업은 저장하면 지워진다', (tester) async {
    final first = await pumpApp(tester, const SizedBox(), size: _tall);
    final wireframe = first.book.scheduleById('wireframe')!;
    final repository = await pumpApp(
      tester,
      ScheduleFormScreen(schedule: wireframe),
      book: first.book,
      size: _tall,
    );

    expect(find.text('세부 작업 (3)'), findsOneWidget);
    await tester.tap(find.byTooltip('세부 작업 삭제').first);
    await tester.pump();
    await tester.tap(find.text('일정 저장하기'));
    await tester.pumpAndSettle();

    expect(
      subTasksOf(repository.book.subTasks, 'wireframe').map((t) => t.id),
      ['wire-1', 'wire-2'],
    );
  });
}
