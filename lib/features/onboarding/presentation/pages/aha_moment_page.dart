import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import '../../cubit/onboarding_cubit.dart';
import '../../cubit/onboarding_state.dart';
import '../onboarding_navigation.dart';

class AhaMomentPage extends StatelessWidget {
  const AhaMomentPage({super.key});

  Future<void> _handleBack(BuildContext context) async {
    await navigateToOnboardingStep(
      context,
      step: OnboardingStep.extraAmount,
      route: AppRoutes.extraAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final planRepository = getIt.get<PlanRepository>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.mdPrimary,
        body: SafeArea(
          child: StreamBuilder<Plan?>(
            stream: planRepository.watchCurrentPlan(),
            builder: (context, planSnapshot) {
              return BlocBuilder<DebtsCubit, DebtsState>(
                builder: (context, debtsState) {
                  if (debtsState.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mdOnPrimary,
                      ),
                    );
                  }

                  final debts = debtsState.debts;
                  final trackedDebts = debts
                      .where((debt) => debt.currentBalance > 0)
                      .toList();
                  final totalBalance = trackedDebts.fold<int>(
                    0,
                    (sum, debt) => sum + debt.currentBalance,
                  );
                  final plan = planSnapshot.data;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: AppDimensions.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              key: AppTestKeys.onboardingAhaBack,
                              onPressed: () => _handleBack(context),
                              icon: const Icon(
                                LucideIcons.arrowLeft,
                                color: AppColors.mdOnPrimary,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.lg,
                            vertical: AppDimensions.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.mdOnPrimary.withValues(
                                      alpha: 0.14,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.sparkles,
                                    size: AppDimensions.iconXxl,
                                    color: AppColors.mdOnPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.lg),
                              Text(
                                trackedDebts.isEmpty
                                    ? 'Bạn chưa có khoản nợ nào trong kế hoạch.'
                                    : 'Kế hoạch cơ bản của bạn đã sẵn sàng.',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.mdOnPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.md),
                              Text(
                                trackedDebts.isEmpty
                                    ? 'Hãy quay lại bước trước để thêm ít nhất một khoản nợ.'
                                    : 'Chúng tôi đã lưu khoản nợ, chiến lược và ngân sách extra của bạn. Phần mô phỏng chi tiết sẽ xuất hiện sau khi timeline projection được bật.',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.mdOnPrimary.withValues(
                                    alpha: 0.84,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.xl),
                              AppCard(
                                color: AppColors.mdOnPrimary,
                                borderRadius: AppDimensions.radius2xl,
                                padding: const EdgeInsets.all(AppDimensions.xl),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tóm tắt hiện tại',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: AppDimensions.lg),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _SummaryStat(
                                            label: 'Tổng dư nợ',
                                            value: AppFormatters.formatCents(
                                              totalBalance,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: _SummaryStat(
                                            label: 'Khoản đang theo dõi',
                                            value: '${trackedDebts.length}',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppDimensions.lg),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _SummaryStat(
                                            label: 'Chiến lược',
                                            value:
                                                plan?.strategy.label ??
                                                'Snowball',
                                            emphasize: true,
                                          ),
                                        ),
                                        Expanded(
                                          child: _SummaryStat(
                                            label: 'Extra / tháng',
                                            value: AppFormatters.formatCents(
                                              plan?.extraMonthlyAmount ?? 0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppDimensions.lg),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(
                                        AppDimensions.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.mdPrimaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusMd,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            LucideIcons.shield,
                                            size: AppDimensions.iconMd,
                                            color: AppColors.mdPrimary,
                                          ),
                                          const SizedBox(
                                            width: AppDimensions.sm,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Dữ liệu của bạn đã được lưu local trên thiết bị. Bạn không cần tạo tài khoản để bắt đầu.',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color: AppColors
                                                        .mdOnPrimaryContainer,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.lg),
                        child: SizedBox(
                          key: AppTestKeys.onboardingComplete,
                          child: AppButton.filledLg(
                            label: trackedDebts.isEmpty
                                ? 'Quay lại thêm khoản nợ'
                                : 'Vào màn hình chính',
                            trailingIcon: trackedDebts.isEmpty
                                ? null
                                : LucideIcons.arrowRight,
                            fullWidth: true,
                            onPressed: () async {
                              if (trackedDebts.isEmpty) {
                                await navigateToOnboardingStep(
                                  context,
                                  step: OnboardingStep.addDebt,
                                  route: AppRoutes.debtEntry,
                                );
                                return;
                              }
                              await context
                                  .read<OnboardingCubit>()
                                  .completeOnboarding();
                              if (!context.mounted) return;
                              context.go(AppRoutes.home);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: emphasize ? AppColors.mdPrimary : AppColors.mdOnSurface,
          ),
        ),
      ],
    );
  }
}
