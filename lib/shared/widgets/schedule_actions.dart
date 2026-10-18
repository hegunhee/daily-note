import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/shared/controllers/schedule_controller.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/widgets/app_dialogs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 일정을 지울지 묻고, 지우면 세부 작업도 함께 지웁니다. 지웠으면 true입니다.
Future<bool> confirmDeleteSchedule(
  BuildContext context,
  WidgetRef ref,
  Schedule schedule,
) async {
  final confirmed = await confirmDelete(
    context,
    message: 'schedule.delete_confirm'.tr(args: [schedule.title]),
  );
  if (!confirmed) {
    return false;
  }
  try {
    await ref.read(scheduleProvider.notifier).deleteSchedule(schedule.id);
    return true;
  } on Object {
    if (context.mounted) {
      await showNotice(context, message: 'common.delete_failed'.tr());
    }
    return false;
  }
}

/// 일정을 완료 처리하거나 되돌립니다. 실패하면 알립니다.
Future<void> toggleScheduleCompleted(
  BuildContext context,
  WidgetRef ref,
  Schedule schedule,
) async {
  try {
    await ref
        .read(scheduleProvider.notifier)
        .setScheduleCompleted(schedule.id, completed: !schedule.isCompleted);
  } on Object {
    if (context.mounted) {
      await showNotice(context, message: 'common.save_failed'.tr());
    }
  }
}

/// 세부 작업의 완료·미완료를 바꿉니다. 화면에는 바로 반영되고, 저장에 실패하면 되돌린 뒤 알립니다.
Future<void> toggleSubTask(
  BuildContext context,
  WidgetRef ref,
  String taskId,
) async {
  try {
    await ref.read(scheduleProvider.notifier).toggleSubTask(taskId);
  } on Object {
    if (context.mounted) {
      await showNotice(context, message: 'common.save_failed'.tr());
    }
  }
}
