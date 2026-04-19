import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/models/strategy_preview.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/plan_recast_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/enums/strategy.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../../engine/strategy_sorter.dart';
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
  final PlanRecastService _planRecastService = getIt.get<PlanRecastService>();

  Plan? _plan;
  Strategy _selectedStrategy = Strategy.snowball;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPreviewLoading = false;
  Map<Strategy, StrategyPreview> _previews = const {};
  String? _previewFingerprint;
  int _previewRequestId = 0;

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
              _maybeRefreshPreviews(trackedDebts);

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
                                : 'App đang so projection thật của Snowball và Avalanche từ dữ liệu khoản nợ hiện tại của bạn.',
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
                              subtitle: _topPriorityText(
                                strategy: Strategy.snowball,
                                debts: trackedDebts,
                              ),
                              detail: _previewDetail(
                                _previews[Strategy.snowball],
                              ),
                              badgeText: _previewBadgeText(
                                _previews[Strategy.snowball],
                                fallback: 'Ưu tiên khoản có số dư nhỏ nhất.',
                              ),
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
                              subtitle: _topPriorityText(
                                strategy: Strategy.avalanche,
                                debts: trackedDebts,
                              ),
                              detail: _previewDetail(
                                _previews[Strategy.avalanche],
                              ),
                              badgeText: _previewBadgeText(
                                _previews[Strategy.avalanche],
                                fallback: 'Ưu tiên APR cao nhất để giảm lãi.',
                              ),
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
                            _SelectedStrategyPreviewCard(
                              strategy: _selectedStrategy,
                              preview: _previews[_selectedStrategy],
                              extraMonthlyAmount:
                                  _plan?.extraMonthlyAmount ?? 0,
                              isLoading: _isPreviewLoading,
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
                                      'Bạn có thể đổi chiến lược bất kỳ lúc nào sau onboarding. Mỗi lần đổi, plan summary và timeline cache sẽ recast lại.',
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

  void _maybeRefreshPreviews(List<Debt> trackedDebts) {
    if (_isLoading || trackedDebts.isEmpty) return;

    final fingerprint = _previewStateFingerprint(trackedDebts);
    if (fingerprint == _previewFingerprint) return;
    _previewFingerprint = fingerprint;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_refreshPreviews(trackedDebts));
    });
  }

  Future<void> _refreshPreviews(List<Debt> trackedDebts) async {
    final requestId = ++_previewRequestId;
    setState(() => _isPreviewLoading = true);

    try {
      final now = DateTime.now().toUtc();
      final draft = (_plan ?? _createDraftPlan(now)).copyWith(updatedAt: now);
      final previews = await Future.wait([
        _planRecastService.previewPlan(
          plan: draft.copyWith(strategy: Strategy.snowball),
          debts: trackedDebts,
        ),
        _planRecastService.previewPlan(
          plan: draft.copyWith(strategy: Strategy.avalanche),
          debts: trackedDebts,
        ),
      ]);

      if (!mounted || requestId != _previewRequestId) return;
      setState(() {
        _previews = {
          Strategy.snowball: previews[0],
          Strategy.avalanche: previews[1],
        };
        _isPreviewLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _previewRequestId) return;
      setState(() => _isPreviewLoading = false);
    }
  }

  String _previewStateFingerprint(List<Debt> debts) {
    final buffer = StringBuffer()
      ..write(_plan?.extraMonthlyAmount ?? 0)
      ..write('|')
      ..write(_plan?.strategy.name ?? 'none');
    for (final debt in debts) {
      buffer
        ..write('|')
        ..write(debt.id)
        ..write(':')
        ..write(debt.currentBalance)
        ..write(':')
        ..write(debt.apr)
        ..write(':')
        ..write(debt.status.name)
        ..write(':')
        ..write(debt.excludeFromStrategy);
    }
    return buffer.toString();
  }

  String _topPriorityText({
    required Strategy strategy,
    required List<Debt> debts,
  }) {
    final candidates = debts
        .where((debt) => !debt.excludeFromStrategy)
        .toList(growable: false);
    if (candidates.isEmpty) {
      return 'Mọi khoản đang được exclude khỏi strategy.';
    }

    final ordered = StrategySorter.sort(candidates, strategy);
    return 'Bắt đầu với ${ordered.first.name}';
  }

  String _previewDetail(StrategyPreview? preview) {
    if (preview == null) {
      return 'Đang tính payoff date và projected interest từ dữ liệu hiện tại...';
    }

    final payoffDate = preview.projectedDebtFreeDate == null
        ? 'Đang recast'
        : AppFormatters.formatMonthYear(preview.projectedDebtFreeDate!);
    return 'Debt-free $payoffDate · ${AppFormatters.formatMonthsDuration(preview.projectedMonths)} · lãi ${AppFormatters.formatCents(preview.totalInterestProjected)}';
  }

  String _previewBadgeText(StrategyPreview? preview, {required String fallback}) {
    if (preview == null) return fallback;
    return 'Tiết kiệm ${AppFormatters.formatCents(preview.totalInterestSaved)} vs minimum-only';
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

class _SelectedStrategyPreviewCard extends StatelessWidget {
  const _SelectedStrategyPreviewCard({
    required this.strategy,
    required this.preview,
    required this.extraMonthlyAmount,
    required this.isLoading,
  });

  final Strategy strategy;
  final StrategyPreview? preview;
  final int extraMonthlyAmount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && preview == null) {
      return const AppCard(
        color: AppColors.mdSurfaceContainerLow,
        child: SizedBox(
          height: 128,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AppCard(
      color: AppColors.mdSurfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Preview hiện tại', style: AppTextStyles.titleSmall),
              const Spacer(),
              AppChip.status(label: strategy.label, icon: LucideIcons.sparkles),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _PreviewStat(
                  label: 'Debt-free date',
                  value: preview?.projectedDebtFreeDate == null
                      ? 'Đang recast'
                      : AppFormatters.formatShortMonthYear(
                          preview!.projectedDebtFreeDate!,
                        ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _PreviewStat(
                  label: 'Projected length',
                  value: preview == null
                      ? '--'
                      : AppFormatters.formatMonthsDuration(
                          preview!.projectedMonths,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _PreviewStat(
                  label: 'Projected interest',
                  value: preview == null
                      ? '--'
                      : AppFormatters.formatCents(
                          preview!.totalInterestProjected,
                        ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _PreviewStat(
                  label: 'Extra / tháng',
                  value: AppFormatters.formatCents(extraMonthlyAmount),
                  valueColor: AppColors.mdPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

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
          style: AppTextStyles.titleMedium.copyWith(
            color: valueColor ?? AppColors.mdOnSurface,
          ),
        ),
      ],
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
