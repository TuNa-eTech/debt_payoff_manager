import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/enums/debt_status.dart';

class DebtOptionsSheet extends StatelessWidget {
  const DebtOptionsSheet({
    super.key,
    required this.debt,
    required this.onEdit,
    this.onArchiveToggle,
    required this.onDelete,
  });

  final Debt debt;
  final VoidCallback onEdit;
  final VoidCallback? onArchiveToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final canArchive =
        debt.status == DebtStatus.paidOff || debt.status == DebtStatus.archived;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.mdSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mdOutlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(debt.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          _SheetAction(
            icon: LucideIcons.pencil,
            label: 'Chỉnh sửa khoản nợ',
            onTap: onEdit,
          ),
          if (canArchive)
            _SheetAction(
              icon: debt.status == DebtStatus.archived
                  ? LucideIcons.archiveRestore
                  : LucideIcons.archive,
              label: debt.status == DebtStatus.archived
                  ? 'Bỏ lưu trữ'
                  : 'Lưu trữ khoản nợ',
              onTap: onArchiveToggle,
            ),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.mdOutlineVariant),
          const SizedBox(height: 8),
          _SheetAction(
            icon: LucideIcons.trash2,
            iconColor: AppColors.mdError,
            label: 'Xóa khoản nợ',
            labelColor: AppColors.mdError,
            subtitle: 'Bạn vẫn có thể khôi phục ngay sau khi xóa.',
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required Debt debt,
    required VoidCallback onEdit,
    VoidCallback? onArchiveToggle,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DebtOptionsSheet(
        debt: debt,
        onEdit: () {
          Navigator.pop(context);
          onEdit();
        },
        onArchiveToggle: onArchiveToggle == null
            ? null
            : () {
                Navigator.pop(context);
                onArchiveToggle();
              },
        onDelete: () {
          Navigator.pop(context);
          onDelete();
        },
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.labelColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? AppColors.mdOnSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: labelColor ?? AppColors.mdOnSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: labelColor ?? AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
