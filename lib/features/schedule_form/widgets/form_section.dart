import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';

/// 입력 폼의 한 묶음: 위에 제목(필수 표시·오른쪽 보조 문구)과 아래 내용
class FormSection extends StatelessWidget {
  const FormSection({
    required this.label,
    required this.child,
    this.required = false,
    this.trailing,
    super.key,
  });

  final String label;

  final Widget child;

  /// 제목 옆에 `*`를 붙입니다.
  final bool required;

  /// 제목 줄 오른쪽 (글자 수·작업 추가 버튼 등)
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 36,
          child: Row(
            children: [
              Text(
                label,
                style: AppTypography.labelLg.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: AppTypography.labelLg.copyWith(
                    color: colors.onAccentTint,
                  ),
                ),
              const Spacer(),
              ?trailing,
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
