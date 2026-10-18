import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenlist/core/themes/app_theme.dart';
import 'package:greenlist/shared/controllers/clock_controller.dart';
import 'package:greenlist/shared/models/schedule_book.dart';
import 'package:greenlist/shared/repositories/schedule_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'fake_schedule_repository.dart';

/// 시안의 하루([designBook])와 시각([designNow])으로 [home]을 한국어로 띄웁니다.
Future<FakeScheduleRepository> pumpApp(
  WidgetTester tester,
  Widget home, {
  ScheduleBook? book,
  ThemeData? theme,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * tester.view.devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  final repository = FakeScheduleRepository(book ?? designBook());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scheduleRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => designNow),
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        locale: const Locale('ko'),
        supportedLocales: const [Locale('ko'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
