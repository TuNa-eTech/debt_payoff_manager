import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';

class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
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
                  l10n.homeEmptyTitle,
                  style: AppTextStyles.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  l10n.homeEmptySubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xl),
                AppButton.filledLg(
                  label: l10n.commonAddDebt,
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
                  l10n.whatCanYouDoNow,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppDimensions.md),
                _FeatureRow(
                  icon: LucideIcons.creditCard,
                  title: l10n.homeFeatureMultiDebtTitle,
                  subtitle: l10n.homeFeatureMultiDebtSubtitle,
                ),
                const SizedBox(height: AppDimensions.md),
                _FeatureRow(
                  icon: LucideIcons.pencil,
                  title: l10n.homeFeatureEditAnytimeTitle,
                  subtitle: l10n.homeFeatureEditAnytimeSubtitle,
                ),
                const SizedBox(height: AppDimensions.md),
                _FeatureRow(
                  icon: LucideIcons.shield,
                  title: l10n.homeFeatureLocalFirstTitle,
                  subtitle: l10n.homeFeatureLocalFirstSubtitle,
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
              Text(
                title,
                style: AppTextStyles.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
