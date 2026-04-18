import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Teaser Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.mdSurfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mdPrimary.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.mdPrimaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.sparkles, color: AppColors.mdPrimary, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tiết kiệm hàng ngàn đô la',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhập khoản nợ của bạn để mở khóa lộ trình thanh toán độc quyền, giúp trả nợ nhanh hơn với phương pháp Snowball.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // CTA Wrap
          Column(
            children: [
              AppButton.filledLg(
                label: 'Bắt đầu tạo kế hoạch',
                icon: LucideIcons.arrowRight, 
                fullWidth: true,
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              Text(
                'Hoặc thêm nhanh',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.mdOnSurfaceVariant),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _QuickAddChip(icon: LucideIcons.creditCard, label: 'Thẻ tín dụng'),
                  SizedBox(width: 8),
                  _QuickAddChip(icon: LucideIcons.car, label: 'Vay mua xe'),
                ],
              ),
              const SizedBox(height: 8),
              const _QuickAddChip(icon: LucideIcons.graduationCap, label: 'Vay sinh viên'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.mdPrimary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant)),
        ],
      ),
    );
  }
}
