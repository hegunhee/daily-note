import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';

/// 되돌릴 수 없는 삭제 전에 한 번 더 묻습니다. 지우기로 하면 true입니다.
Future<bool> confirmDelete(
  BuildContext context, {
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'common.delete'.tr(),
            style: TextStyle(color: context.colors.error),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// 확인만 받으면 되는 안내를 띄웁니다. 실패를 알릴 작업 영역이 없을 때만 씁니다.
Future<void> showNotice(BuildContext context, {required String message}) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );

/// 한 줄 이름을 고치는 다이얼로그. 고친 이름을 돌려주고, 취소하거나 비우면 null입니다.
Future<String?> promptRename(
  BuildContext context, {
  required String title,
  required String initial,
  int maxLength = 60,
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: maxLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text('common.save'.tr()),
        ),
      ],
    ),
  );
  // 다이얼로그가 닫히는 애니메이션이 끝난 뒤 정리합니다.
  WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  final name = result?.trim();
  return name == null || name.isEmpty ? null : name;
}
