import 'package:flutter/painting.dart';

/// 앱 전체에서 사용되는 텍스트 스타일을 정의하는 클래스
///
/// `docs/design/DESIGN.md` 의 타이포 토큰을 그대로 옮겼습니다. 시안의 Inter 대신, 라틴·숫자가
/// Inter 기반이면서 한글을 함께 그리는 Pretendard 하나만 번들합니다. 시각·날짜 숫자는
/// 갱신될 때 자리가 흔들리지 않게 고정폭 숫자(tnum)가 켜진 `time*` 토큰으로 적습니다.
class AppTypography {
  const AppTypography._();

  /// 기본 폰트 패밀리
  static const fontFamily = 'Pretendard';

  static const _tabular = [FontFeature.tabularFigures()];

  /// Headline/XL (32px, Bold, 줄 높이 40)
  static const headlineXl = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.64,
    fontFamily: fontFamily,
  );

  /// Headline/LG — 화면 제목 (26px, Bold, 줄 높이 34)
  static const headlineLg = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 34 / 26,
    letterSpacing: -0.39,
    fontFamily: fontFamily,
  );

  /// Headline/MD — 카드 제목·일정 제목 (20px, SemiBold, 줄 높이 28)
  static const headlineMd = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.2,
    fontFamily: fontFamily,
  );

  /// Headline/SM — 섹션 제목·버튼 라벨 (18px, SemiBold, 줄 높이 24)
  static const headlineSm = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    fontFamily: fontFamily,
  );

  /// Body/LG — 작업 이름 (16px, Medium, 줄 높이 24)
  static const bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: -0.08,
    fontFamily: fontFamily,
  );

  /// Body/MD (14px, Regular, 줄 높이 20)
  static const bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    fontFamily: fontFamily,
  );

  /// Body/SM — 메모·보조 정보 (13px, Regular, 줄 높이 18)
  static const bodySm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    fontFamily: fontFamily,
  );

  /// Label/LG — 입력칸 제목·텍스트 버튼 (14px, SemiBold, 줄 높이 20)
  static const labelLg = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    fontFamily: fontFamily,
  );

  /// Label/MD — 상태 배지 (12px, SemiBold, 줄 높이 16)
  static const labelMd = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.24,
    fontFamily: fontFamily,
  );

  /// Label/SM — 요일 (11px, Medium, 줄 높이 14)
  static const labelSm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    letterSpacing: 0.33,
    fontFamily: fontFamily,
  );

  /// 입력 폼의 큰 시각 (24px, SemiBold, 줄 높이 32)
  static const timeLg = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    fontFeatures: _tabular,
    fontFamily: fontFamily,
  );

  /// 날짜 칩의 숫자 (20px, SemiBold, 줄 높이 28)
  static const timeMd = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    fontFeatures: _tabular,
    fontFamily: fontFamily,
  );

  /// 일정 카드의 시각·진행률 (14px, SemiBold, 줄 높이 20)
  static const timeSm = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    fontFeatures: _tabular,
    fontFamily: fontFamily,
  );
}
