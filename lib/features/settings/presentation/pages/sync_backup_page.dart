import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class SyncBackupPage extends StatelessWidget {
  const SyncBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.mdSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.mdOnSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.md,
            AppDimensions.pagePaddingH,
            AppDimensions.xxl,
          ),
          children: [
            Align(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.mdPrimaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.cloud,
                    size: 48,
                    color: AppColors.mdPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              l10n.syncBackupHeadline,
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              l10n.syncBackupBody,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),
            _TrustCard(
              title: l10n.syncBackupFreeTitle,
              icon: LucideIcons.shield,
              bullets: <String>[
                l10n.syncBackupFreeBulletCsv,
                l10n.syncBackupFreeBulletBackup,
                l10n.syncBackupFreeBulletPreview,
                l10n.syncBackupFreeBulletReset,
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            _TrustCard(
              title: l10n.syncBackupPremiumTitle,
              icon: LucideIcons.sparkles,
              bullets: <String>[
                l10n.syncBackupPremiumBulletCloud,
                l10n.syncBackupPremiumBulletSharing,
                l10n.syncBackupPremiumBulletPdf,
                l10n.syncBackupPremiumBulletPricing,
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
                      l10n.syncBackupTrustMessage,
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
              key: AppTestKeys.syncBackupViewPricing,
              child: AppButton.filledLg(
                label: l10n.syncBackupViewPricing,
                fullWidth: true,
                onPressed: () => context.push(AppRoutes.pricing),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            AppButton.text(
              label: l10n.syncBackupContinueLocal,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({
    required this.title,
    required this.icon,
    required this.bullets,
  });

  final String title;
  final IconData icon;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.mdSurfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.mdPrimary, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          for (final bullet in bullets) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    LucideIcons.check,
                    size: 16,
                    color: AppColors.mdPrimary,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    bullet,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ),
                ),
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
