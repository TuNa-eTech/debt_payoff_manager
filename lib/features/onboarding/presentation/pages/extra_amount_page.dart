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
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/enums/strategy.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import '../../cubit/onboarding_state.dart';
import '../onboarding_navigation.dart';

class ExtraAmountPage extends StatefulWidget {
  const ExtraAmountPage({super.key});

  @override
  State<ExtraAmountPage> createState() => _ExtraAmountPageState();
}

class _ExtraAmountPageState extends State<ExtraAmountPage> {
  final PlanRepository _planRepository = getIt.get<PlanRepository>();

  Plan? _plan;
  double _extraAmount = 0;
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
      _extraAmount = (plan?.extraMonthlyAmount ?? 0) / 100;
      _isLoading = false;
    });
  }

  Future<void> _handleBack() async {
    await navigateToOnboardingStep(
      context,
      step: OnboardingStep.selectStrategy,
      route: AppRoutes.strategySelection,
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
            key: AppTestKeys.onboardingExtraBack,
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: _handleBack,
          ),
          title: const Text('Ngân sách thêm'),
        ),
        body: SafeArea(
          child: BlocBuilder<DebtsCubit, DebtsState>(
            builder: (context, debtsState) {
              if (_isLoading || debtsState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final trackedCount = debtsState.debts
                  .where((debt) => debt.currentBalance > 0)
                  .length;
              final strategyLabel =
                  _plan?.strategy.label ?? Strategy.snowball.label;

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
                            'Bước 4/4',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.mdPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          LinearProgressIndicator(
                            value: 1,
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
                            'Ngoài khoản tối thiểu, bạn muốn để thêm bao nhiêu mỗi tháng?',
                            style: AppTextStyles.headlineSmall,
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            'Mặc định là \$0. App sẽ lưu cấu hình này vào kế hoạch chính của bạn ngay bây giờ.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.lg,
                              vertical: AppDimensions.xl,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mdPrimaryContainer,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLg,
                              ),
                              border: Border.all(color: AppColors.mdPrimary),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Extra payment mỗi tháng',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.mdOnPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.sm),
                                Text(
                                  AppFormatters.formatCents(
                                    _extraAmount.round() * 100,
                                  ),
                                  style: AppTextStyles.displayMedium.copyWith(
                                    color: AppColors.mdOnPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.sm),
                                Text(
                                  '$strategyLabel · $trackedCount khoản đang theo dõi',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.mdOnPrimaryContainer
                                        .withValues(alpha: 0.82),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.lg),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.mdPrimary,
                              inactiveTrackColor:
                                  AppColors.mdSurfaceContainerHighest,
                              thumbColor: AppColors.mdPrimary,
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _extraAmount.clamp(0, 1000),
                              min: 0,
                              max: 1000,
                              divisions: 20,
                              onChanged: (value) {
                                setState(() => _extraAmount = value);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.sm,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$0',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.mdOnSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '\$1000',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.mdOnSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.lg),
                          Wrap(
                            spacing: AppDimensions.sm,
                            runSpacing: AppDimensions.sm,
                            children: [
                              _AmountChip(
                                label: '+\$50',
                                onTap: () => _bumpExtra(50),
                              ),
                              _AmountChip(
                                key: AppTestKeys.onboardingExtraPreset100,
                                label: '+\$100',
                                onTap: () => _bumpExtra(100),
                              ),
                              _AmountChip(
                                label: '+\$200',
                                onTap: () => _bumpExtra(200),
                              ),
                              _AmountChip(
                                label: 'Max',
                                onTap: () =>
                                    setState(() => _extraAmount = 1000),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          AppCard(
                            color: AppColors.mdSurfaceContainerLow,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.info,
                                      color: AppColors.mdPrimary,
                                      size: AppDimensions.iconMd,
                                    ),
                                    const SizedBox(width: AppDimensions.sm),
                                    Text(
                                      'Điều gì xảy ra tiếp theo?',
                                      style: AppTextStyles.titleSmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.sm),
                                Text(
                                  'Khoản extra này sẽ được dùng làm ngân sách trả thêm mỗi tháng. Khi phần mô phỏng kế hoạch được bật, app sẽ hiển thị timeline và ngày hết nợ từ cấu hình bạn đang lưu.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.mdOnSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          key: AppTestKeys.onboardingExtraContinue,
                          child: AppButton.filledLg(
                            label: 'Lưu và xem tóm tắt',
                            trailingIcon: LucideIcons.arrowRight,
                            fullWidth: true,
                            loading: _isSaving,
                            onPressed: () => _saveAndContinue(
                              amountCents: _extraAmount.round() * 100,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        AppButton.text(
                          label: 'Dùng \$0 lúc này',
                          onPressed: _isSaving
                              ? null
                              : () => _saveAndContinue(amountCents: 0),
                        ),
                      ],
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

  void _bumpExtra(int amountDollars) {
    setState(() {
      _extraAmount = (_extraAmount + amountDollars).clamp(0, 1000).toDouble();
    });
  }

  Future<void> _saveAndContinue({required int amountCents}) async {
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now().toUtc();
      final draft = (_plan ?? _createDraftPlan(now)).copyWith(
        extraMonthlyAmount: amountCents,
        updatedAt: now,
      );
      _plan = await _planRepository.savePlan(draft);
      if (!mounted) return;
      context.go(AppRoutes.ahaMoment);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu ngân sách thêm. Vui lòng thử lại.'),
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

class _AmountChip extends StatelessWidget {
  const _AmountChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppChip.assist(label: label, onTap: onTap);
  }
}
