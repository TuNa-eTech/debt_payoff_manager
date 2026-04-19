import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            color: AppColors.mdSurface,
            borderRadius: AppDimensions.radius2xl,
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.mdPrimaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.walletCards,
                    color: AppColors.mdOnPrimaryContainer,
                    size: AppDimensions.iconXxl,
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                Text(
                  'Chưa có khoản nợ nào',
                  style: AppTextStyles.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'Thêm khoản nợ đầu tiên để app bắt đầu lưu dữ liệu và dựng kế hoạch trả nợ của bạn.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xl),
                AppButton.filledLg(
                  label: 'Thêm khoản nợ',
                  icon: LucideIcons.plus,
                  fullWidth: true,
                  onPressed: () => context.push(AppRoutes.addDebt),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          AppCard(
            color: AppColors.mdSurfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn có thể làm gì ngay bây giờ?',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppDimensions.md),
                const _FeatureRow(
                  icon: LucideIcons.creditCard,
                  title: 'Nhập nhiều loại nợ',
                  subtitle:
                      'Credit card, student loan, car loan, mortgage và hơn thế nữa.',
                ),
                const SizedBox(height: AppDimensions.md),
                const _FeatureRow(
                  icon: LucideIcons.pencil,
                  title: 'Chỉnh sửa bất kỳ lúc nào',
                  subtitle:
                      'Mọi thay đổi đều được lưu local và phản ánh lại trong danh sách nợ.',
                ),
                const SizedBox(height: AppDimensions.md),
                const _FeatureRow(
                  icon: LucideIcons.shield,
                  title: 'Local-first',
                  subtitle:
                      'Bạn không cần tài khoản để bắt đầu và dữ liệu ở lại trên thiết bị.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.mdPrimaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(
            icon,
            size: AppDimensions.iconMd,
            color: AppColors.mdPrimary,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleSmall),
              const SizedBox(height: AppDimensions.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mdOnSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
