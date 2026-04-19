import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Free vs Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.lg,
            AppDimensions.pagePaddingH,
            AppDimensions.xxl,
          ),
          children: [
            Text(
              'Local-first trước. Premium chỉ mở khi thật sự thêm giá trị.',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Bản MVP hiện tại vẫn giữ đầy đủ core payoff flow miễn phí. Premium là lộ trình tiếp theo cho cloud backup, PDF report và shared planning.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            const _TierCard(
              title: 'Free',
              subtitle: 'Có sẵn trong MVP',
              accentColor: AppColors.mdPrimary,
              backgroundColor: AppColors.mdPrimaryContainer,
              icon: LucideIcons.shield,
              bullets: <String>[
                'Nhập và chỉnh sửa không giới hạn khoản nợ',
                'Snowball / Avalanche + living timeline',
                'Payment logging + monthly action view',
                'CSV export + local backup/restore + clear all',
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            const _TierCard(
              title: 'Premium',
              subtitle: 'Stub để chuẩn bị monetization, chưa có IAP',
              accentColor: AppColors.mdSecondary,
              backgroundColor: AppColors.mdSecondaryContainer,
              icon: LucideIcons.cloud,
              bullets: <String>[
                'Cloud backup giữa nhiều thiết bị',
                'Partner sharing và scenario comparison',
                'PDF report để in hoặc gửi cố vấn tài chính',
                'Pricing minh bạch, không trial mập mờ',
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            AppCard(
              color: AppColors.mdSurfaceContainerLow,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.badgeCheck,
                    color: AppColors.mdPrimary,
                    size: AppDimensions.iconMd,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Text(
                      'Cam kết trust không đổi khi lên Premium: không bank linking, không auto-charge mập mờ, và local export vẫn luôn khả dụng.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            SizedBox(
              key: AppTestKeys.pricingContinueFree,
              child: AppButton.filledLg(
                label: 'Tiếp tục với bản miễn phí',
                fullWidth: true,
                onPressed: context.pop,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Premium chưa mở trong bản MVP này.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.backgroundColor,
    required this.icon,
    required this.bullets,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final Color backgroundColor;
  final IconData icon;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: backgroundColor.withValues(alpha: 0.55),
      borderRadius: AppDimensions.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleLarge),
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
          ),
          const SizedBox(height: AppDimensions.lg),
          for (final bullet in bullets) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.check, size: 16, color: accentColor),
                const SizedBox(width: AppDimensions.sm),
                Expanded(child: Text(bullet, style: AppTextStyles.bodyMedium)),
              ],
            ),
            if (bullet != bullets.last)
              const SizedBox(height: AppDimensions.sm),
          ],
        ],
      ),
    );
  }
}
