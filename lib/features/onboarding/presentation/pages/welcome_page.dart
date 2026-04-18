import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../cubit/onboarding_cubit.dart';
import '../../cubit/onboarding_state.dart';

/// Onboarding welcome page.
///
/// Feature 1.0: "Welcome — một nút duy nhất: Thêm khoản nợ đầu tiên"
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'Kiểm soát nợ,\ngiải phóng tương lai.',
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
                      'Tạo kế hoạch trả nợ cá nhân hoá trong 3 phút.\n'
                      'Không tài khoản. Không chạm ngân hàng.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: const Color(0xFF615D59), // #615D59
                        height: 1.5,
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
                  AppButton.filledLg(
                    label: 'Thêm khoản nợ đầu tiên',
                    icon: LucideIcons.plus,
                    fullWidth: true,
                    onPressed: () async {
                      await context.read<OnboardingCubit>().goToStep(
                            OnboardingStep.addDebt,
                          );
                      if (!context.mounted) return;
                      context.go(AppRoutes.debtEntry);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Trust Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTrustBadge(LucideIcons.shield, 'Local-first'),
                      const SizedBox(width: 20),
                      _buildTrustBadge(LucideIcons.ban, 'Không sync bank'),
                      const SizedBox(width: 20),
                      _buildTrustBadge(LucideIcons.lock, 'Miễn phí'),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
