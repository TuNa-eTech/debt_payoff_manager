import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DebtOptionsSheet extends StatelessWidget {
  const DebtOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Drag handle
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
          
          // Title
          Text('Chase Sapphire', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          
          // Option 1
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(LucideIcons.pencil, size: 24, color: AppColors.mdOnSurfaceVariant),
                  const SizedBox(width: 16),
                  Text('Chỉnh sửa khoản nợ', style: AppTextStyles.bodyLarge),
                ],
              ),
            ),
          ),
          
          // Option 2
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(LucideIcons.archive, size: 24, color: AppColors.mdOnSurfaceVariant),
                  const SizedBox(width: 16),
                  Text('Lưu trữ (Đã trả xong)', style: AppTextStyles.bodyLarge),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.mdOutlineVariant),
          const SizedBox(height: 8),
          
          // Option 3
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(LucideIcons.trash2, size: 24, color: AppColors.mdError),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Xoá khoản nợ', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.mdError, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      const Text('Hành động này không thể hoàn tác', style: TextStyle(color: AppColors.mdError, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DebtOptionsSheet(),
    );
  }
}
