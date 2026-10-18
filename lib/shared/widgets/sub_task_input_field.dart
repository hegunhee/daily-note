import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';

/// 새 세부 작업 이름을 받는 입력칸. Enter 나 확인 버튼으로 더하고 칸을 비웁니다.
///
/// 이어서 여러 개를 적을 수 있게, 더한 뒤에도 키보드를 닫지 않습니다.
class SubTaskInputField extends HookWidget {
  const SubTaskInputField({required this.onAdd, this.focusNode, super.key});

  /// 다듬은 이름을 받습니다. 비어 있으면 부르지 않습니다.
  final ValueChanged<String> onAdd;

  /// 바깥의 "작업 추가" 버튼이 이 칸으로 옮겨 올 때 씁니다.
  final FocusNode? focusNode;

  static const maxLength = 60;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = useTextEditingController();
    final ownFocus = useFocusNode();
    final focus = focusNode ?? ownFocus;
    final text = useValueListenable(controller);
    final canAdd = text.text.trim().isNotEmpty;

    void submit() {
      final name = controller.text.trim();
      if (name.isEmpty) {
        return;
      }
      onAdd(name);
      controller.clear();
      focus.requestFocus();
    }

    return TextField(
      controller: controller,
      focusNode: focus,
      maxLength: maxLength,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => submit(),
      style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        counterText: '',
        hintText: 'sub_task.input_hint'.tr(),
        hintStyle: AppTypography.bodyMd.copyWith(color: colors.textTertiary),
        fillColor: colors.surfaceLow,
        prefixIcon: Icon(
          Icons.add_circle_outline_rounded,
          color: colors.primary,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: TextButton(
            onPressed: canAdd ? submit : null,
            child: Text('sub_task.add_confirm'.tr()),
          ),
        ),
      ),
    );
  }
}
