/// 일정의 진행 상태. 세부 작업 완료율과 별개로 완료 처리 여부와 현재 시각으로 정합니다.
enum ScheduleStatus {
  /// 사용자가 완료 처리함
  done,

  /// 시작 전
  upcoming,

  /// 지금 시작~종료 사이
  inProgress,

  /// 종료 시각이 지났지만 완료 처리하지 않음
  past,
}
