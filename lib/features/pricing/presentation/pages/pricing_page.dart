import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pricingPageTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.lg,
            AppDimensions.pagePaddingH,
            AppDimensions.xxl,
          ),
          children: [
            Text(l10n.pricingHeadline, style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppDimensions.sm),
            Text(
              l10n.pricingBody,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            _TierCard(
              title: l10n.pricingFreeTitle,
              subtitle: l10n.pricingFreeSubtitle,
              accentColor: AppColors.mdPrimary,
              backgroundColor: AppColors.mdPrimaryContainer,
              icon: LucideIcons.shield,
              bullets: <String>[
                l10n.pricingFreeBulletUnlimitedDebts,
                l10n.pricingFreeBulletStrategies,
                l10n.pricingFreeBulletPayments,
                l10n.pricingFreeBulletExport,
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            _TierCard(
              title: l10n.pricingPremiumTitle,
              subtitle: l10n.pricingPremiumSubtitle,
              accentColor: AppColors.mdSecondary,
              backgroundColor: AppColors.mdSecondaryContainer,
              icon: LucideIcons.cloud,
              bullets: <String>[
                l10n.pricingPremiumBulletCloud,
                l10n.pricingPremiumBulletSharing,
                l10n.pricingPremiumBulletPdf,
                l10n.pricingPremiumBulletPricing,
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
                      l10n.pricingTrustMessage,
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
                label: l10n.pricingContinueFree,
                fullWidth: true,
                onPressed: context.pop,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              l10n.pricingMvpNotice,
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
