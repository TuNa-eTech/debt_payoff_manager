import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/enums/strategy.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import '../../cubit/onboarding_cubit.dart';
import '../../cubit/onboarding_state.dart';
import '../onboarding_navigation.dart';

class StrategySelectionPage extends StatefulWidget {
  const StrategySelectionPage({super.key});

  @override
  State<StrategySelectionPage> createState() => _StrategySelectionPageState();
}

class _StrategySelectionPageState extends State<StrategySelectionPage> {
  final PlanRepository _planRepository = getIt.get<PlanRepository>();

  Plan? _plan;
  Strategy _selectedStrategy = Strategy.snowball;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final plan = await _planRepository.getCurrentPlan();
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _selectedStrategy = plan?.strategy ?? Strategy.snowball;
      _isLoading = false;
    });
  }

  Future<void> _handleBack() async {
    await navigateToOnboardingStep(
      context,
      step: OnboardingStep.addDebt,
      route: AppRoutes.addAnotherDebt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: AppTestKeys.onboardingStrategyBack,
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: _handleBack,
          ),
          title: const Text('Chọn chiến lược'),
        ),
        body: SafeArea(
          child: BlocBuilder<DebtsCubit, DebtsState>(
            builder: (context, debtsState) {
              final trackedDebts = debtsState.debts
                  .where((debt) => debt.currentBalance > 0)
                  .toList();

              if (_isLoading || debtsState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pagePaddingH,
                        vertical: AppDimensions.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bước 3/4',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          LinearProgressIndicator(
                            value: 0.75,
                            backgroundColor:
                                AppColors.mdSurfaceContainerHighest,
                            color: AppColors.mdPrimary,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                            minHeight: 4,
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          Text(
                            'Chọn cách app ưu tiên khoản nợ khi bạn bắt đầu trả thêm.',
                            style: AppTextStyles.headlineSmall,
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            trackedDebts.isEmpty
                                ? 'Bạn cần ít nhất một khoản nợ để chọn chiến lược.'
                                : 'Chiến lược được lưu ngay bây giờ. Timeline chi tiết và ngày hết nợ sẽ hiện khi phần mô phỏng kế hoạch được bật.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          if (trackedDebts.isEmpty)
                            AppCard(
                              color: AppColors.mdSurfaceContainerLow,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chưa có khoản nợ để áp dụng chiến lược',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  const SizedBox(height: AppDimensions.sm),
                                  Text(
                                    'Hãy thêm ít nhất một khoản nợ trước khi tiếp tục.',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  const SizedBox(height: AppDimensions.md),
                                  AppButton.outlined(
                                    label: 'Quay lại thêm khoản nợ',
                                    icon: LucideIcons.plus,
                                    onPressed: () => navigateToOnboardingStep(
                                      context,
                                      step: OnboardingStep.addDebt,
                                      route: AppRoutes.debtEntry,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            _StrategyCard(
                              key: AppTestKeys.onboardingStrategySnowball,
                              title: 'Snowball',
                              subtitle:
                                  'Ưu tiên khoản có số dư nhỏ nhất trước để tạo đà.',
                              detail:
                                  '${trackedDebts.length} khoản sẽ được sắp theo số dư tăng dần.',
                              badgeText: 'Tập trung vào động lực sớm',
                              badgeColor: AppColors.mdPrimaryContainer,
                              badgeTextColor: AppColors.mdOnPrimaryContainer,
                              icon: LucideIcons.snowflake,
                              isSelected:
                                  _selectedStrategy == Strategy.snowball,
                              onTap: () {
                                setState(
                                  () => _selectedStrategy = Strategy.snowball,
                                );
                              },
                            ),
                            const SizedBox(height: AppDimensions.md),
                            _StrategyCard(
                              key: AppTestKeys.onboardingStrategyAvalanche,
                              title: 'Avalanche',
                              subtitle:
                                  'Ưu tiên khoản có APR cao nhất để giảm lãi trước.',
                              detail:
                                  '${trackedDebts.length} khoản sẽ được sắp theo APR giảm dần.',
                              badgeText: 'Tập trung vào tối ưu chi phí',
                              badgeColor: AppColors.mdSecondaryContainer,
                              badgeTextColor: AppColors.mdOnSecondaryContainer,
                              icon: LucideIcons.trendingDown,
                              isSelected:
                                  _selectedStrategy == Strategy.avalanche,
                              onTap: () {
                                setState(
                                  () => _selectedStrategy = Strategy.avalanche,
                                );
                              },
                            ),
                            const SizedBox(height: AppDimensions.lg),
                            AppCard(
                              color: AppColors.mdSurfaceContainerLow,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    LucideIcons.shield,
                                    color: AppColors.mdPrimary,
                                    size: AppDimensions.iconMd,
                                  ),
                                  const SizedBox(width: AppDimensions.sm),
                                  Expanded(
                                    child: Text(
                                      'Bạn có thể đổi chiến lược bất kỳ lúc nào sau khi hoàn tất onboarding.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.mdOnSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
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
                    child: SizedBox(
                      key: AppTestKeys.onboardingStrategyContinue,
                      child: AppButton.filledLg(
                        label: 'Lưu chiến lược và tiếp tục',
                        trailingIcon: LucideIcons.arrowRight,
                        fullWidth: true,
                        loading: _isSaving,
                        onPressed: trackedDebts.isEmpty
                            ? null
                            : _saveAndContinue,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now().toUtc();
      final draft = (_plan ?? _createDraftPlan(now)).copyWith(
        strategy: _selectedStrategy,
        updatedAt: now,
      );
      _plan = await _planRepository.savePlan(draft);
      if (!mounted) return;
      await context.read<OnboardingCubit>().goToStep(
        OnboardingStep.extraAmount,
      );
      if (!mounted) return;
      context.go(AppRoutes.extraAmount);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu chiến lược. Vui lòng thử lại.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Plan _createDraftPlan(DateTime now) {
    return Plan(
      id: const Uuid().v4(),
      strategy: Strategy.snowball,
      extraMonthlyAmount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _StrategyCard extends StatelessWidget {
  const _StrategyCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : _cardKey = key;

  final String title;
  final String subtitle;
  final String detail;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Key? _cardKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _cardKey,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppDimensions.animNormal),
          decoration: BoxDecoration(
            color: AppColors.mdSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isSelected
                  ? AppColors.mdPrimary
                  : AppColors.mdOutlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.mdPrimary.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.mdPrimaryContainer
                            : AppColors.mdSurfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: AppDimensions.iconMd,
                        color: isSelected
                            ? AppColors.mdOnPrimaryContainer
                            : AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.titleMedium),
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            subtitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            detail,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? LucideIcons.checkCircle2
                          : LucideIcons.circle,
                      color: isSelected
                          ? AppColors.mdPrimary
                          : AppColors.mdOutline,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimensions.radiusLg - 1),
                    bottomRight: Radius.circular(AppDimensions.radiusLg - 1),
                  ),
                ),
                child: Text(
                  badgeText,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
