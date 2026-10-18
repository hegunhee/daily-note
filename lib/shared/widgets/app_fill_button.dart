import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';

/// [AppFillButton]의 색상 variant.
enum AppFillVariant {
  /// primary 색 채움 — 화면의 주 동작
  primary,

  /// 흰 바탕과 1px 테두리 — 주 동작 옆의 보조 동작
  secondary,
}

/// 높이 48의 채움 버튼.
///
/// [onPressed]가 null이면 비활성으로 그립니다.
class AppFillButton extends StatelessWidget {
  const AppFillButton({
    required this.label,
    this.variant = AppFillVariant.primary,
    this.icon,
    this.onPressed,
    super.key,
  });

  /// 버튼에 표시할 텍스트
  final String label;

  /// 색상 variant
  final AppFillVariant variant;

  /// 라벨 앞 아이콘 (선택)
  final IconData? icon;

  /// 탭 콜백
  final VoidCallback? onPressed;

  static const _height = 48.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    final primary = variant == AppFillVariant.primary;
    final background = !enabled
        ? colors.border
        : primary
        ? colors.primary
        : colors.surface;
    final foreground = !enabled
        ? colors.textTertiary
        : primary
        ? colors.onPrimary
        : colors.textPrimary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: primary || !enabled
          ? BorderSide.none
          : BorderSide(color: colors.border),
    );

    return Material(
      color: background,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashFactory: NoSplash.splashFactory,
        highlightColor: primary
            ? colors.onPrimaryTint.withValues(alpha: 0.4)
            : colors.background,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: foreground, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLg.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
