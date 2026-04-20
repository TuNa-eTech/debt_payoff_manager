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
import '../../../../core/widgets/app_chip.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import '../../cubit/onboarding_cubit.dart';
import '../../cubit/onboarding_state.dart';
import '../../services/onboarding_analytics.dart';
import '../onboarding_navigation.dart';
import '../widgets/onboarding_step_tracker.dart';

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

    return OnboardingStepTracker(
      screen: OnboardingAnalyticsScreen.ahaMoment,
      child: PopScope(
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
                    final payoffDate = plan?.projectedDebtFreeDate;
                    final projectedInterest = plan?.totalInterestProjected ?? 0;
                    final interestSaved = plan?.totalInterestSaved ?? 0;

                    final screenHeight = MediaQuery.sizeOf(context).height;
                    final isCompact = screenHeight < 700;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 0,
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
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.lg,
                              vertical: isCompact ? AppDimensions.xs : AppDimensions.sm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isCompact)
                                  Align(
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: AppColors.mdOnPrimary.withValues(
                                          alpha: 0.14,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.sparkles,
                                        size: AppDimensions.iconXl,
                                        color: AppColors.mdOnPrimary,
                                      ),
                                    ),
                                  )
                                else
                                  Align(
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.mdOnPrimary.withValues(
                                          alpha: 0.14,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.sparkles,
                                        size: AppDimensions.iconSm + 8,
                                        color: AppColors.mdOnPrimary,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: isCompact ? AppDimensions.sm : AppDimensions.md),
                                Text(
                                  trackedDebts.isEmpty
                                      ? 'Bạn chưa có khoản nợ nào trong kế hoạch.'
                                      : payoffDate == null
                                      ? 'Kế hoạch của bạn đang recast.'
                                      : 'Bạn có thể debt-free vào ${AppFormatters.formatMonthYear(payoffDate)}.',
                                  style: (isCompact
                                          ? AppTextStyles.headlineSmall
                                          : AppTextStyles.headlineMedium)
                                      .copyWith(
                                    color: AppColors.mdOnPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (!isCompact) ...[
                                  const SizedBox(height: AppDimensions.sm),
                                  Text(
                                    trackedDebts.isEmpty
                                        ? 'Hãy quay lại bước trước để thêm ít nhất một khoản nợ.'
                                        : 'Kế hoạch đã được recast. Checklist tháng này đã sẵn sàng.',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.mdOnPrimary.withValues(
                                        alpha: 0.84,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                SizedBox(height: isCompact ? AppDimensions.sm : AppDimensions.lg),
                                AppCard(
                                  color: AppColors.mdOnPrimary,
                                  borderRadius: AppDimensions.radius2xl,
                                  padding: const EdgeInsets.all(
                                    AppDimensions.lg,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Tóm tắt hiện tại',
                                            style: AppTextStyles.titleMedium,
                                          ),
                                          const Spacer(),
                                          if (plan != null)
                                            AppChip.status(
                                              label: plan.strategy.label,
                                              icon: LucideIcons.sparkles,
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: isCompact ? AppDimensions.sm : AppDimensions.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _SummaryStat(
                                              label: 'Tổng dư nợ',
                                              value: AppFormatters.formatCents(
                                                totalBalance,
                                              ),
                                              isCompact: isCompact,
                                            ),
                                          ),
                                          Expanded(
                                            child: _SummaryStat(
                                              label: 'Debt-free date',
                                              value: payoffDate == null
                                                  ? 'Đang recast'
                                                  : AppFormatters.formatShortMonthYear(
                                                      payoffDate,
                                                    ),
                                              isCompact: isCompact,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isCompact ? AppDimensions.xs : AppDimensions.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _SummaryStat(
                                              label: 'Khoản theo dõi',
                                              value: '${trackedDebts.length}',
                                              isCompact: isCompact,
                                            ),
                                          ),
                                          Expanded(
                                            child: _SummaryStat(
                                              label: 'Extra / tháng',
                                              value: AppFormatters.formatCents(
                                                plan?.extraMonthlyAmount ?? 0,
                                              ),
                                              isCompact: isCompact,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isCompact ? AppDimensions.xs : AppDimensions.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _SummaryStat(
                                              label: 'Projected interest',
                                              value: AppFormatters.formatCents(
                                                projectedInterest,
                                              ),
                                              isCompact: isCompact,
                                            ),
                                          ),
                                          Expanded(
                                            child: _SummaryStat(
                                              label: 'Saved vs minimum',
                                              value: AppFormatters.formatCents(
                                                interestSaved,
                                              ),
                                              emphasize: true,
                                              isCompact: isCompact,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isCompact ? AppDimensions.xs : AppDimensions.md),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(
                                          isCompact ? AppDimensions.sm : AppDimensions.md,
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
                                                isCompact
                                                    ? 'Dữ liệu lưu local. Không cần tài khoản.'
                                                    : 'Dữ liệu của bạn đã được lưu local trên thiết bị. Từ đây bạn có thể vào Monthly Action View để check off payment thật và xem timeline recast ngay.',
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
                          padding: EdgeInsets.fromLTRB(
                            AppDimensions.lg,
                            isCompact ? AppDimensions.sm : AppDimensions.lg,
                            AppDimensions.lg,
                            AppDimensions.lg,
                          ),
                          child: SizedBox(
                            key: AppTestKeys.onboardingComplete,
                            child: AppButton.filledLg(
                              label: trackedDebts.isEmpty
                                  ? 'Quay lại thêm khoản nợ'
                                  : 'Mở Monthly Action View',
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
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.isCompact = false,
  });

  final String label;
  final String value;
  final bool emphasize;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          value,
          style: (isCompact
                  ? AppTextStyles.titleMedium
                  : AppTextStyles.titleLarge)
              .copyWith(
            color: emphasize ? AppColors.mdPrimary : AppColors.mdOnSurface,
          ),
        ),
      ],
    );
  }
}
