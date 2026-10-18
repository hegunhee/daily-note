import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';

/// 세부 작업 진행률을 보여 주는 6px 가로 진행 바
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({required this.value, this.color, super.key});

  /// 채운 비율. 0~1 밖의 값은 잘라 그립니다.
  final double value;

  /// 채운 부분의 색. null이면 `primary`
  final Color? color;

  static const _height = 6.0;
  static const _radius = BorderRadius.all(Radius.circular(_height / 2));

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: _radius,
      child: SizedBox(
        width: double.infinity,
        height: _height,
        child: ColoredBox(
          color: colors.border,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1).toDouble(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color ?? colors.primary,
                borderRadius: _radius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
