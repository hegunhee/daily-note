import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_layout.dart';
import 'package:greenlist/core/themes/app_spacing.dart';

/// 22px 체크박스. 탭 영역은 최소 44×44 입니다.
///
/// 꺼져 있으면 1.5px 테두리, 켜지면 primary 채움에 흰 체크를 그립니다.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.checked,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  final bool checked;

  /// 탭 콜백. null이면 누를 수 없습니다.
  final VoidCallback? onChanged;

  /// 스크린 리더가 읽을 이름 (작업 이름)
  final String semanticLabel;

  /// 그려지는 상자의 한 변
  static const size = 22.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      checked: checked,
      label: semanticLabel,
      button: true,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onChanged,
        radius: AppLayout.minTouchTarget / 2,
        child: SizedBox.square(
          dimension: AppLayout.minTouchTarget,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: checked ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.checkbox),
                border: checked
                    ? null
                    : Border.all(color: colors.textTertiary, width: 1.5),
              ),
              child: checked
                  ? Icon(Icons.check_rounded, size: 16, color: colors.onPrimary)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
