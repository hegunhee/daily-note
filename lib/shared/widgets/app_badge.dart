import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';

/// 상태·소요 시간을 알리는 알약 배지
class AppBadge extends StatelessWidget {
  const AppBadge(
    this.label, {
    this.icon,
    this.background,
    this.foreground,
    super.key,
  });

  final String label;

  final IconData? icon;

  /// 바탕색. null이면 `primaryTint`
  final Color? background;

  /// 글자색. null이면 `onPrimaryTint`
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = foreground ?? colors.onPrimaryTint;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? colors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMd.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
