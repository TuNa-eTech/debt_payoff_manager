import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/app_locale_picker_sheet.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../domain/entities/user_settings.dart';
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100),
                      // Icon
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: AppColors.mdPrimaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.mdOutlineVariant,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.leaf, // Forest green + leaf metaphor
                            size: 32,
                            color: AppColors.mdOnPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        l10n.welcomeTitle,
                        style: AppTextStyles.headlineLarge.copyWith(
                          // 40sp
                          letterSpacing: -1.5,
                          height: 1.15,
                          color: AppColors.mdOnSurface.withValues(
                            alpha: 0.95,
                          ), // #000000F2
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Subtitle
                      Text(
                        l10n.welcomeSubtitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: const Color(0xFF615D59), // #615D59
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                  24,
                  24,
                  24,
                  48,
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
                    const SizedBox(height: 16),
                    // Trust Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTrustBadge(
                          LucideIcons.shield,
                          l10n.welcomeTrustLocalFirst,
                        ),
                        const SizedBox(width: 20),
                        _buildTrustBadge(
                          LucideIcons.ban,
                          l10n.welcomeTrustNoBankSync,
                        ),
                        const SizedBox(width: 20),
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
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.mdOnSurfaceVariant,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
