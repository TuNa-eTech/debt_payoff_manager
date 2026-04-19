import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import '../../../debts/presentation/debt_ui_utils.dart';
import '../../cubit/onboarding_state.dart';
import '../../services/onboarding_analytics.dart';
import '../onboarding_navigation.dart';
import '../widgets/onboarding_step_tracker.dart';

class AddAnotherDebtPage extends StatelessWidget {
  const AddAnotherDebtPage({super.key});

  Future<void> _handleBack(BuildContext context) async {
    await navigateToOnboardingStep(
      context,
      step: OnboardingStep.addDebt,
      route: AppRoutes.debtEntry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepTracker(
      screen: OnboardingAnalyticsScreen.addAnother,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBack(context);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              key: AppTestKeys.onboardingAddAnotherBack,
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => _handleBack(context),
            ),
            title: const Text('Kiểm tra lại khoản nợ'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<DebtsCubit, DebtsState>(
                    builder: (context, state) {
                      final debts = state.debts;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.lg,
                          vertical: AppDimensions.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bước 2/4',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.mdOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: 0.5,
                              backgroundColor:
                                  AppColors.mdSurfaceContainerHighest,
                              color: AppColors.mdPrimary,
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 4,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              debts.isEmpty
                                  ? 'Bạn chưa lưu khoản nợ nào.'
                                  : 'Bạn đã lưu ${debts.length} khoản nợ. Có thể thêm tiếp hoặc sang bước chọn chiến lược.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.mdOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (debts.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(AppDimensions.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.mdSurfaceContainerLow,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusLg,
                                  ),
                                  border: Border.all(
                                    color: AppColors.mdOutlineVariant,
                                  ),
                                ),
                                child: Text(
                                  'Hãy thêm ít nhất 1 khoản nợ để app có thể tiếp tục onboarding.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              )
                            else
                              ...debts.map(
                                (debt) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppDimensions.md,
                                  ),
                                  child: AppCard(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: debtTypeColor(
                                              debt.type,
                                            ).withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            debtTypeIcon(debt.type),
                                            color: debtTypeColor(debt.type),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                debt.name,
                                                style:
                                                    AppTextStyles.titleMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                debtSubtitle(debt),
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          AppFormatters.formatCents(
                                            debt.currentBalance,
                                          ),
                                          style: AppTextStyles.titleSmall
                                              .copyWith(
                                                fontFamily: 'Roboto Mono',
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  decoration: const BoxDecoration(
                    color: AppColors.mdSurface,
                    border: Border(
                      top: BorderSide(color: AppColors.mdOutlineVariant),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<DebtsCubit, DebtsState>(
                        builder: (context, state) {
                          return SizedBox(
                            key: AppTestKeys.onboardingAddAnotherContinue,
                            child: AppButton.filledLg(
                              label: 'Sang bước chọn chiến lược',
                              trailingIcon: LucideIcons.arrowRight,
                              fullWidth: true,
                              onPressed: state.debts.isEmpty
                                  ? null
                                  : () => navigateToOnboardingStep(
                                      context,
                                      step: OnboardingStep.selectStrategy,
                                      route: AppRoutes.strategySelection,
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        key: AppTestKeys.onboardingAddAnotherDebt,
                        child: AppButton.outlined(
                          label: 'Thêm một khoản nợ nữa',
                          fullWidth: true,
                          onPressed: () => navigateToOnboardingStep(
                            context,
                            step: OnboardingStep.addDebt,
                            route: AppRoutes.debtEntry,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
