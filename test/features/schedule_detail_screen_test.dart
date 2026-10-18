import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenlist/features/schedule_detail/screens/schedule_detail_screen.dart';
import 'package:greenlist/features/timeline/screens/timeline_screen.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';
import 'package:greenlist/shared/widgets/app_checkbox.dart';

import '../helpers/pump_app.dart';

const _tall = Size(390, 2000);

void main() {
  testWidgets('남은 세부 작업을 체크하면 진행률이 바로 100%가 되고 저장된다', (tester) async {
    final repository = await pumpApp(
      tester,
      const ScheduleDetailScreen(scheduleId: 'wireframe'),
      size: _tall,
    );
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('남은 작업 1개를 완료하면 모든 작업이 끝나요.'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is AppCheckbox && w.semanticLabel == '빈 상태 가이드 작성',
      ),
    );
    await tester.pump();

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('모든 세부 작업을 완료했어요.'), findsOneWidget);
    expect(
      repository.book.subTasks.firstWhere((t) => t.id == 'wire-2').isCompleted,
      isTrue,
    );
  });

  testWidgets('세부 작업을 더하고, 이름을 고치고, 확인을 받아 지운다', (tester) async {
    final repository = await pumpApp(
      tester,
      const ScheduleDetailScreen(scheduleId: 'review'),
      size: _tall,
    );
    List<String> titles() => [
      for (final task in subTasksOf(repository.book.subTasks, 'review'))
        task.title,
    ];

    await tester.enterText(
      find.widgetWithText(TextField, '새로운 세부 작업 입력 후 Enter'),
      '회의실 예약',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(titles(), ['로드맵 검토', '스프린트 티켓 생성', '회의실 예약']);
    expect(find.text('세부 작업 (3)'), findsOneWidget);

    await tester.tap(find.text('로드맵 검토'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Q3 로드맵 검토');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(titles().first, 'Q3 로드맵 검토');

    await tester.tap(find.byTooltip('세부 작업 삭제').at(1));
    await tester.pumpAndSettle();
    expect(find.text("'스프린트 티켓 생성' 작업을 삭제할까요?"), findsOneWidget);
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(titles(), ['Q3 로드맵 검토', '회의실 예약']);
  });

  testWidgets('메모를 고쳐 저장하면 그 자리에 보이고 저장소에 남는다', (tester) async {
    final repository = await pumpApp(
      tester,
      const ScheduleDetailScreen(scheduleId: 'review'),
      size: _tall,
    );
    expect(find.text('아직 메모가 없어요. 편집을 눌러 적어 보세요.'), findsOneWidget);

    await tester.tap(find.text('편집'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '  개발팀 리드 참석  ');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.text('개발팀 리드 참석'), findsOneWidget);
    expect(repository.book.scheduleById('review')!.memo, '개발팀 리드 참석');
  });

  testWidgets('메인 화면에서 카드를 눌러 열고, 상세에서 지우면 목록으로 돌아온다', (tester) async {
    final repository = await pumpApp(
      tester,
      const TimelineScreen(),
      size: _tall,
    );

    await tester.tap(find.text('프로덕트 백로그 우선순위 리뷰'));
    await tester.pumpAndSettle();
    expect(find.byType(ScheduleDetailScreen), findsOneWidget);

    await tester.tap(find.byTooltip('더 보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('일정 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.byType(ScheduleDetailScreen), findsNothing);
    expect(find.text('프로덕트 백로그 우선순위 리뷰'), findsNothing);
    expect(repository.book.scheduleById('review'), isNull);
  });
}
