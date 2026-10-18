import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenlist/core/themes/app_theme.dart';
import 'package:greenlist/features/timeline/screens/timeline_screen.dart';
import 'package:greenlist/shared/models/schedule_book.dart';

import '../helpers/pump_app.dart';

/// 하루 일정이 한 화면에 다 그려지는 크기
const _tall = Size(390, 2000);

void main() {
  testWidgets('고른 날의 일정만 시작 시각순으로 보이고, 날짜를 옮기면 그날 일정으로 바뀐다', (
    tester,
  ) async {
    await pumpApp(tester, const TimelineScreen());

    final meeting = find.text('주간 디자인 시스템 스프린트 미팅');
    final wireframe = find.text('Greenlist 모바일 상세 화면 와이어프레임 설계');
    expect(meeting, findsOneWidget);
    expect(find.text('내일 일정'), findsNothing);
    expect(
      tester.getTopLeft(meeting).dy,
      lessThan(tester.getTopLeft(wireframe).dy),
    );

    await tester.tap(find.byTooltip('다음 날'));
    await tester.pumpAndSettle();
    expect(find.text('내일 일정'), findsOneWidget);
    expect(meeting, findsNothing);

    await tester.tap(find.text('오늘'));
    await tester.pumpAndSettle();
    expect(meeting, findsOneWidget);
    expect(find.text('오늘의 일정'), findsOneWidget);
  });

  testWidgets('세부 작업을 체크하면 저장되고 그날 진행률이 바로 바뀐다', (tester) async {
    final repository = await pumpApp(
      tester,
      const TimelineScreen(),
      size: _tall,
    );
    // 회의 3/3 + 설계 2/3 + 리뷰 0/2 = 5/8
    expect(find.text('전체 8개 중 5개 완료'), findsOneWidget);
    expect(find.text('63%'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('빈 상태 가이드 작성'));
    await tester.pump();

    expect(find.text('전체 8개 중 6개 완료'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(
      repository.book.subTasks.firstWhere((t) => t.id == 'wire-2').isCompleted,
      isTrue,
    );
  });

  testWidgets('지금 진행 중인 일정에 NOW 를 붙인다', (tester) async {
    await pumpApp(tester, const TimelineScreen(), size: _tall);

    // 11:30 은 설계(11:00-12:30) 진행 중, 리뷰(14:00)는 대기 중입니다.
    expect(find.text('NOW'), findsOneWidget);
    expect(find.text('대기 중'), findsOneWidget);
    expect(find.text('완료됨'), findsOneWidget);
  });

  testWidgets('일정을 지우기 전에 묻고, 지우면 목록에서 사라진다', (tester) async {
    final repository = await pumpApp(tester, const TimelineScreen());

    await tester.tap(find.byTooltip('더 보기').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('일정 삭제'));
    await tester.pumpAndSettle();
    expect(find.textContaining('일정을 삭제할까요?'), findsOneWidget);

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.text('주간 디자인 시스템 스프린트 미팅'), findsNothing);
    expect(repository.book.scheduleById('meeting'), isNull);
    expect(
      repository.book.subTasks.where((t) => t.scheduleId == 'meeting'),
      isEmpty,
    );
  });

  testWidgets('일정이 없는 날은 빈 상태를 보여 주고, 작은 화면·다크 테마에서도 넘치지 않는다', (
    tester,
  ) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await pumpApp(
        tester,
        const TimelineScreen(),
        book: const ScheduleBook(),
        theme: theme,
        size: const Size(320, 640),
      );
      expect(find.text('등록된 일정이 없습니다'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await pumpApp(
        tester,
        const TimelineScreen(),
        theme: theme,
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
