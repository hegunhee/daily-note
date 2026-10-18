import 'package:flutter/material.dart';
import 'package:greenlist/shared/util/schedule_calculator.dart';

/// 일정 입력에서 저장을 막는 사유
enum ScheduleFormError {
  /// 제목이 비어 있음
  title,

  /// 종료 시각이 시작 시각보다 늦지 않음
  timeRange,
}

/// 입력값에서 저장을 막는 사유를 모두 찾습니다. 비어 있으면 저장할 수 있습니다.
Set<ScheduleFormError> validateSchedule({
  required String title,
  required TimeOfDay start,
  required TimeOfDay end,
}) => {
  if (title.trim().isEmpty) ScheduleFormError.title,
  if (!isValidTimeRange(start, end)) ScheduleFormError.timeRange,
};
