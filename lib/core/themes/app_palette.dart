import 'package:flutter/material.dart';

/// 기획서와 디자인 가이드(`docs/design/DESIGN.md`)의 색을 옮긴 원시 토큰 모음.
///
/// 시맨틱 색상(AppColors)이 참조하는 색의 단일 출처입니다.
/// 원시 hex 리터럴은 이 파일에만 둡니다.
class AppPalette {
  const AppPalette._();

  /// Primary Green — 주 동작·선택·완료 표시 (기획서)
  static const primary = Color(0xFF24734A);

  /// On-Primary
  static const onPrimary = Color(0xFFFFFFFF);

  /// Primary 옅은 바탕 — 완료된 줄·메모·배지
  static const primaryTint = Color(0xFFE3F1E7);

  /// [primaryTint] 위의 글자 — Primary 를 누른 색(#1B5738)
  static const onPrimaryTint = Color(0xFF1B5738);

  /// Accent Orange — 지금 진행 중인 일정 표시 (기획서)
  static const accent = Color(0xFFF28C45);

  /// Accent 옅은 바탕 (Accent 10%를 흰 바탕에 얹은 색)
  static const accentTint = Color(0xFFFEF4EC);

  /// [accentTint] 위의 글자. Accent 그대로는 흰 바탕에서 대비가 모자라 Secondary(#984800)를 씁니다.
  static const onAccentTint = Color(0xFF984800);

  /// Base Canvas — 화면 바탕 (기획서)
  static const background = Color(0xFFF5F7F3);

  /// Surface Container — 카드·시트
  static const surface = Color(0xFFFFFFFF);

  /// 카드 안의 입력칸·묶음 바탕
  static const surfaceLow = Color(0xFFEFF3EC);

  /// Border Neutral — 1px 테두리·진행 바 트랙
  static const border = Color(0xFFE2E7DF);

  /// Neutral Foreground — 본문
  static const foreground = Color(0xFF24352A);

  /// Tertiary-Container — 보조 정보 글자 (Tertiary 보다 대비가 높음)
  static const foregroundVariant = Color(0xFF5E685F);

  /// Tertiary — 시각·완료된 글자·비활성 아이콘·체크박스 테두리
  static const tertiary = Color(0xFF788278);

  /// Error
  static const error = Color(0xFFBA1A1A);

  /// Error-Container
  static const errorTint = Color(0xFFFFDAD6);

  // --- 다크 테마 (시안에 다크가 없어 토큰의 inverse · fixed-dim 값에서 유도한 값) ---

  /// 다크 화면 바탕
  static const darkBackground = Color(0xFF111A14);

  /// 다크 카드
  static const darkSurface = Color(0xFF18231B);

  /// 다크 입력칸·묶음 바탕
  static const darkSurfaceLow = Color(0xFF1F2B22);

  /// 다크 테두리·진행 바 트랙
  static const darkBorder = Color(0xFF2F3D33);

  /// 다크 본문 — Inverse-On-Surface
  static const darkForeground = Color(0xFFE2F6E5);

  /// 다크 보조 글자 — Outline-Variant
  static const darkForegroundVariant = Color(0xFFBFC9BF);

  /// 다크 Tertiary
  static const darkTertiary = Color(0xFF8A958B);

  /// 다크 Primary — Inverse-Primary
  static const darkPrimary = Color(0xFF89D7A6);

  /// 다크 On-Primary — On-Primary-Fixed
  static const darkOnPrimary = Color(0xFF002110);

  /// 다크 Primary 옅은 바탕 — On-Primary-Fixed-Variant
  static const darkPrimaryTint = Color(0xFF1D4430);

  /// 다크 [darkPrimaryTint] 위의 글자 — Primary-Fixed
  static const darkOnPrimaryTint = Color(0xFFA5F4C0);

  /// 다크 Accent — Secondary-Fixed-Dim
  static const darkAccent = Color(0xFFFFB689);

  /// 다크 Accent 옅은 바탕
  static const darkAccentTint = Color(0xFF43291A);

  /// 다크 [darkAccentTint] 위의 글자 — Secondary-Fixed
  static const darkOnAccentTint = Color(0xFFFFDBC8);

  /// 다크 Error
  static const darkError = Color(0xFFFFB4AB);

  /// 다크 Error 옅은 바탕
  static const darkErrorTint = Color(0xFF5C1A16);

  // --- 투명도가 들어간 색 ---

  /// 모달 뒤를 덮는 dim (#24352A 40%)
  static const scrim = Color(0x6624352A);

  /// 다크 테마의 dim (검정 60%)
  static const darkScrim = Color(0x99000000);

  /// 떠 있는 버튼·하단 바의 옅은 그림자 (#24352A 8%)
  static const shadow = Color(0x1424352A);
}
