import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';

/// 화면 바탕 위에 놓이는 흰 카드
///
/// 디자인 가이드의 Level 1 표면: 그림자 없이 1px 테두리로만 구분합니다.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.accentColor,
    super.key,
  });

  final Widget child;

  final EdgeInsetsGeometry padding;

  /// 바탕색. null이면 `surface`
  final Color? color;

  /// 주면 왼쪽에 3px 강조 띠를 그립니다 (진행 중인 일정).
  final Color? accentColor;

  static const _accentWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg);
    final accent = accentColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: accent == null
            ? Padding(padding: padding, child: child)
            : DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: accent, width: _accentWidth),
                  ),
                ),
                child: Padding(padding: padding, child: child),
              ),
      ),
    );
  }
}
