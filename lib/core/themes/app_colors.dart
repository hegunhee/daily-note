import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_palette.dart';

/// 앱 전체에서 사용되는 색상을 정의하는 ThemeExtension
///
/// 화면은 `context.colors` 로만 색을 읽습니다. 원시 값은 [AppPalette]에 있습니다.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceLow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.onPrimary,
    required this.primaryTint,
    required this.onPrimaryTint,
    required this.accent,
    required this.accentTint,
    required this.onAccentTint,
    required this.error,
    required this.errorTint,
    required this.border,
    required this.scrim,
    required this.shadow,
  });

  /// 화면 바탕
  final Color background;

  /// 카드·시트 바탕
  final Color surface;

  /// 카드 안의 입력칸·묶음 바탕
  final Color surfaceLow;

  /// 기본 텍스트 색상
  final Color textPrimary;

  /// 보조 텍스트 색상 (날짜·설명)
  final Color textSecondary;

  /// 시각·완료된 작업·비활성 아이콘
  final Color textTertiary;

  /// 주 동작·선택·완료 표시
  final Color primary;

  /// primary 배경 위의 텍스트·아이콘 색
  final Color onPrimary;

  /// primary 옅은 바탕 (완료된 줄·메모·배지)
  final Color primaryTint;

  /// [primaryTint] 위의 텍스트 색
  final Color onPrimaryTint;

  /// 지금 진행 중인 일정 표시 (왼쪽 띠·타임라인 점)
  final Color accent;

  /// accent 옅은 바탕 (NOW 배지·진행 중 메모)
  final Color accentTint;

  /// [accentTint] 위나 흰 바탕 위의 accent 글자
  final Color onAccentTint;

  /// 오류 상태 표시 색상
  final Color error;

  /// error 옅은 바탕
  final Color errorTint;

  /// 1px 테두리·구분선·진행 바 트랙
  final Color border;

  /// 모달 뒤를 덮는 dim
  final Color scrim;

  /// 떠 있는 버튼의 옅은 그림자
  final Color shadow;

  /// 밝은 테마용 기본 컬러 정의
  static const light = AppColors(
    background: AppPalette.background,
    surface: AppPalette.surface,
    surfaceLow: AppPalette.surfaceLow,
    textPrimary: AppPalette.foreground,
    textSecondary: AppPalette.foregroundVariant,
    textTertiary: AppPalette.tertiary,
    primary: AppPalette.primary,
    onPrimary: AppPalette.onPrimary,
    primaryTint: AppPalette.primaryTint,
    onPrimaryTint: AppPalette.onPrimaryTint,
    accent: AppPalette.accent,
    accentTint: AppPalette.accentTint,
    onAccentTint: AppPalette.onAccentTint,
    error: AppPalette.error,
    errorTint: AppPalette.errorTint,
    border: AppPalette.border,
    scrim: AppPalette.scrim,
    shadow: AppPalette.shadow,
  );

  /// 다크 테마용 기본 컬러 정의
  ///
  /// 시안에 다크 화면이 없어 디자인 토큰의 inverse · fixed-dim 값에서 유도했습니다.
  static const dark = AppColors(
    background: AppPalette.darkBackground,
    surface: AppPalette.darkSurface,
    surfaceLow: AppPalette.darkSurfaceLow,
    textPrimary: AppPalette.darkForeground,
    textSecondary: AppPalette.darkForegroundVariant,
    textTertiary: AppPalette.darkTertiary,
    primary: AppPalette.darkPrimary,
    onPrimary: AppPalette.darkOnPrimary,
    primaryTint: AppPalette.darkPrimaryTint,
    onPrimaryTint: AppPalette.darkOnPrimaryTint,
    accent: AppPalette.darkAccent,
    accentTint: AppPalette.darkAccentTint,
    onAccentTint: AppPalette.darkOnAccentTint,
    error: AppPalette.darkError,
    errorTint: AppPalette.darkErrorTint,
    border: AppPalette.darkBorder,
    scrim: AppPalette.darkScrim,
    shadow: AppPalette.darkScrim,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLow,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? primary,
    Color? onPrimary,
    Color? primaryTint,
    Color? onPrimaryTint,
    Color? accent,
    Color? accentTint,
    Color? onAccentTint,
    Color? error,
    Color? errorTint,
    Color? border,
    Color? scrim,
    Color? shadow,
  }) => AppColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceLow: surfaceLow ?? this.surfaceLow,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    primaryTint: primaryTint ?? this.primaryTint,
    onPrimaryTint: onPrimaryTint ?? this.onPrimaryTint,
    accent: accent ?? this.accent,
    accentTint: accentTint ?? this.accentTint,
    onAccentTint: onAccentTint ?? this.onAccentTint,
    error: error ?? this.error,
    errorTint: errorTint ?? this.errorTint,
    border: border ?? this.border,
    scrim: scrim ?? this.scrim,
    shadow: shadow ?? this.shadow,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      onPrimaryTint: Color.lerp(onPrimaryTint, other.onPrimaryTint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      onAccentTint: Color.lerp(onAccentTint, other.onAccentTint, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
      border: Color.lerp(border, other.border, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// BuildContext 확장을 통해 AppColors에 쉽게 접근할 수 있도록 합니다.
extension AppColorsExtension on BuildContext {
  /// AppColors에 쉽게 접근하기 위한 getter
  AppColors get colors {
    return Theme.of(this).extension<AppColors>() ?? AppColors.light;
  }
}
