import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenlist/core/themes/app_colors.dart';
import 'package:greenlist/core/themes/app_spacing.dart';
import 'package:greenlist/core/themes/app_typography.dart';
import 'package:greenlist/shared/models/sub_task.dart';
import 'package:greenlist/shared/widgets/app_checkbox.dart';
import 'package:greenlist/shared/widgets/app_tap_row.dart';

/// 세부 작업 한 줄: 체크박스 · 이름(누르면 고치기) · 지우기
///
/// 완료한 작업은 옅은 초록 바탕에 취소선으로 그립니다.
class SubTaskTile extends StatelessWidget {
  const SubTaskTile({
    required this.task,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
    super.key,
  });

  final SubTask task;

  final VoidCallback onToggle;

  final VoidCallback onRename;

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final done = task.isCompleted;
    final radius = BorderRadius.circular(AppRadius.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: done ? colors.primaryTint : colors.surface,
        borderRadius: radius,
        border: Border.all(color: done ? colors.primaryTint : colors.border),
      ),
      child: Row(
        children: [
          AppCheckbox(
            checked: done,
            onChanged: onToggle,
            semanticLabel: task.title,
          ),
          Expanded(
            child: AppTapRow(
              onTap: onRename,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  task.title,
                  style: AppTypography.bodyMd.copyWith(
                    color: done ? colors.textTertiary : colors.textPrimary,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: colors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'sub_task.delete'.tr(),
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded, size: 20),
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
