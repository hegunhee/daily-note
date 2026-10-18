import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';

/// 앱 전체에서 사용되는 테마 설정을 정의하는 클래스
class AppTheme {
  /// 라이트 모드 테마 설정을 반환합니다.
  static ThemeData get lightTheme => _theme(Brightness.light, AppColors.light);

  /// 다크 모드 테마 설정을 반환합니다.
  static ThemeData get darkTheme => _theme(Brightness.dark, AppColors.dark);

  static ThemeData _theme(Brightness brightness, AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primaryTint,
        onPrimaryContainer: colors.onPrimaryTint,
        secondary: colors.accent,
        onSecondary: colors.onPrimary,
        error: colors.error,
        onError: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.textTertiary,
        outlineVariant: colors.border,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: _appBarTheme(colors),
      dividerColor: colors.border,
      inputDecorationTheme: _inputTheme(colors),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  /// 본문이 앱바 아래로 스크롤돼도 앱바 색이 변하지 않게 하는 앱바 테마입니다.
  ///
  /// Material 3 기본값은 스크롤 시 브랜드 색 틴트를 덧입힙니다. 여기서 한 번 꺼 두어
  /// 화면마다 따로 끄지 않습니다.
  static AppBarThemeData _appBarTheme(AppColors colors) {
    return AppBarThemeData(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTypography.headlineSm.copyWith(
        color: colors.textPrimary,
      ),
    );
  }

  /// 디자인 가이드의 입력칸: 흰 바탕, 1px 테두리, 초점이 오면 1.5px primary 테두리.
  static InputDecorationThemeData _inputTheme(AppColors colors) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationThemeData(
      filled: true,
      fillColor: colors.surface,
      hintStyle: AppTypography.bodyLg.copyWith(color: colors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      enabledBorder: border(colors.border),
      focusedBorder: border(colors.primary, 1.5),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error, 1.5),
      border: border(colors.border),
    );
  }

  /// 테마 밝기에 맞는 상태바·내비게이션 바 스타일을 반환합니다.
  static SystemUiOverlayStyle overlayStyleFor(Brightness brightness) {
    final iconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // 안드로이드는 아이콘 밝기를 받습니다.
      statusBarIconBrightness: iconBrightness,
      // iOS는 배경 밝기를 받아 반대색 글자를 그립니다.
      statusBarBrightness: brightness,
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }

  /// [MaterialApp.builder]에 넣어 앱 루트에 [overlayStyleFor]를 까는 빌더입니다.
  static Widget withSystemOverlay(BuildContext context, Widget? child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleFor(Theme.of(context).brightness),
      child: child!,
    );
  }
}
