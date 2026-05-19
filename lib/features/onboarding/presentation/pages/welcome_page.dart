import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/app_locale_picker_sheet.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../cubit/onboarding_state.dart';
import '../../services/onboarding_analytics.dart';
import '../onboarding_navigation.dart';
import '../widgets/onboarding_step_tracker.dart';

/// Onboarding welcome page.
///
/// Feature 1.0: "Welcome — một nút duy nhất: Thêm khoản nợ đầu tiên"
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settingsRepository = getIt<SettingsRepository>();

    return OnboardingStepTracker(
      screen: OnboardingAnalyticsScreen.welcome,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.pagePaddingH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.xl * 2),
                      // Icon
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: AppColors.mdPrimaryContainer,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius2xl,
                          ),
                          border: Border.all(color: AppColors.mdOutlineVariant),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.leaf, // Forest green + leaf metaphor
                            size: 32,
                            color: AppColors.mdOnPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      // Title
                      Text(
                        l10n.welcomeTitle,
                        style: AppTextStyles.headlineLarge.copyWith(
                          height: 1.15,
                          color: AppColors.mdOnSurface.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      // Subtitle
                      Text(
                        l10n.welcomeSubtitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.mdOnSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.mdSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                          border: Border.all(color: AppColors.mdOutlineVariant),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.calendarCheck,
                              size: AppDimensions.iconMd,
                              color: AppColors.mdPrimary,
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: Text(
                                l10n.welcomeValuePreview,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.mdOnSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          key: AppTestKeys.welcomeChangeLanguage,
                          child: AppButton.text(
                            label: l10n.welcomeChangeLanguage,
                            icon: LucideIcons.languages,
                            onPressed: () {
                              final settings = context.readSettings;
                              if (settings == null) return;
                              showAppLocalePickerSheet(
                                context,
                                selectedLocaleCode: settings.localeCode,
                                onSelected: (localeCode) {
                                  return settingsRepository.updateSettings(
                                    settings.copyWith(
                                      localeCode:
                                          AppLocale.resolveSupportedLocaleCode(
                                            localeCode,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Action Area
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.lg,
                  AppDimensions.lg,
                  AppDimensions.lg,
                  AppDimensions.xl + AppDimensions.md,
                ), // Bottom padding for home indicator
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      key: AppTestKeys.welcomeAddFirstDebt,
                      child: AppButton.filledLg(
                        label: l10n.welcomeAddFirstDebt,
                        icon: LucideIcons.plus,
                        fullWidth: true,
                        onPressed: () => navigateToOnboardingStep(
                          context,
                          step: OnboardingStep.addDebt,
                          route: AppRoutes.debtEntry,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    // Trust Badges
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppDimensions.md,
                      runSpacing: AppDimensions.sm,
                      children: [
                        _buildTrustBadge(
                          LucideIcons.shield,
                          l10n.welcomeTrustLocalFirst,
                        ),
                        _buildTrustBadge(
                          LucideIcons.ban,
                          l10n.welcomeTrustNoBankSync,
                        ),
                        _buildTrustBadge(
                          LucideIcons.lock,
                          l10n.welcomeTrustFree,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mdPrimary),
        const SizedBox(width: AppDimensions.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.mdOnSurfaceVariant,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
