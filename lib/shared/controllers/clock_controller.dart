import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 지금 시각을 돌려주는 함수 Provider. 테스트에서 시각을 고정할 때 바꿔 끼웁니다.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// 화면들이 함께 보는 날짜 Provider
final selectedDateProvider = NotifierProvider<SelectedDateController, DateTime>(
  SelectedDateController.new,
);

/// 메인 화면에서 보는 날짜를 관리하는 컨트롤러. 상태는 그날 0시입니다.
class SelectedDateController extends Notifier<DateTime> {
  @override
  DateTime build() => DateUtils.dateOnly(ref.watch(clockProvider)());

  /// 날짜를 [days]만큼 옮깁니다. (-1 이전 날, +1 다음 날)
  void shift(int days) {
    state = DateTime(state.year, state.month, state.day + days);
  }

  /// [date]로 옮깁니다.
  void select(DateTime date) {
    state = DateUtils.dateOnly(date);
  }

  /// 오늘로 옮깁니다.
  void goToday() {
    state = DateUtils.dateOnly(ref.read(clockProvider)());
  }
}
