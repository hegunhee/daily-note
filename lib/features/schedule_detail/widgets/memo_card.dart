import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/controllers/schedule_controller.dart';
import 'package:greenlist/shared/models/schedule.dart';
import 'package:greenlist/shared/widgets/app_card.dart';
import 'package:greenlist/shared/widgets/inline_error_text.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 일정 메모 보기·고치기. 편집을 누르면 그 자리에서 입력칸으로 바뀝니다.
class MemoCard extends HookConsumerWidget {
  const MemoCard({required this.schedule, super.key});

  final Schedule schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final editing = useState(false);
    final saving = useState(false);
    final failed = useState(false);
    final controller = useTextEditingController();

    void startEditing() {
      controller.text = schedule.memo;
      failed.value = false;
      editing.value = true;
    }

    Future<void> save() async {
      saving.value = true;
      failed.value = false;
      try {
        await ref
            .read(scheduleProvider.notifier)
            .updateMemo(schedule.id, controller.text);
        editing.value = false;
      } on Object {
        failed.value = true;
      } finally {
        saving.value = false;
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 20, color: colors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'schedule_detail.memo.title'.tr(),
                  style: AppTypography.headlineSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (!editing.value)
                TextButton.icon(
                  onPressed: startEditing,
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  label: Text('schedule_detail.memo.edit'.tr()),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (editing.value) ...[
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 3,
              maxLines: 8,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
              style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'schedule_detail.memo.hint'.tr(),
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
            if (failed.value) ...[
              const SizedBox(height: AppSpacing.sm),
              InlineErrorText('common.save_failed'.tr()),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: saving.value ? null : () => editing.value = false,
                  child: Text('common.cancel'.tr()),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: saving.value ? null : save,
                  child: Text('common.save'.tr()),
                ),
              ],
            ),
          ] else
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  schedule.memo.isEmpty
                      ? 'schedule_detail.memo.empty'.tr()
                      : schedule.memo,
                  style: AppTypography.bodyMd.copyWith(
                    color: schedule.memo.isEmpty
                        ? colors.textSecondary
                        : colors.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
