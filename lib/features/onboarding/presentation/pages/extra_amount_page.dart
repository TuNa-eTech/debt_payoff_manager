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
  final PlanRecastService _planRecastService = getIt.get<PlanRecastService>();

  Plan? _plan;
  double _extraAmount = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPreviewLoading = false;
  StrategyPreview? _preview;
  Timer? _previewDebounce;
  String? _previewFingerprint;
  int _previewRequestId = 0;

  @override
  void dispose() {
    _previewDebounce?.cancel();
    super.dispose();
  }

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

              final trackedDebts = debtsState.debts
                  .where((debt) => debt.currentBalance > 0)
                  .toList(growable: false);
              _maybeSchedulePreview(trackedDebts);
              final trackedCount = trackedDebts.length;
              final strategyLabel =
                  _plan?.strategy.label ?? Strategy.snowball.label;
              final amountCents = _extraAmount.round() * 100;

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
                            'Mặc định là \$0. Preview sẽ recast live sau 300ms để cho bạn thấy debt-free date và lãi tiết kiệm thật.',
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
                                  AppFormatters.formatCents(amountCents),
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
                                _setExtraAmount(
                                  value,
                                  trackedDebts: trackedDebts,
                                );
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
                                onTap: () => _bumpExtra(
                                  50,
                                  trackedDebts: trackedDebts,
                                ),
                              ),
                              _AmountChip(
                                key: AppTestKeys.onboardingExtraPreset100,
                                label: '+\$100',
                                onTap: () => _bumpExtra(
                                  100,
                                  trackedDebts: trackedDebts,
                                ),
                              ),
                              _AmountChip(
                                label: '+\$200',
                                onTap: () => _bumpExtra(
                                  200,
                                  trackedDebts: trackedDebts,
                                ),
                              ),
                              _AmountChip(
                                label: 'Max',
                                onTap: () => _setExtraAmount(
                                  1000,
                                  trackedDebts: trackedDebts,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          _ExtraPreviewCard(
                            preview: _preview,
                            strategyLabel: strategyLabel,
                            extraMonthlyAmount: amountCents,
                            isLoading: _isPreviewLoading,
                            hasTrackedDebts: trackedDebts.isNotEmpty,
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
                                  'Khoản extra này sẽ được dùng làm ngân sách trả thêm mỗi tháng. Khi bạn bấm lưu, plan summary và timeline cache sẽ recast ngay.',
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

  void _bumpExtra(int amountDollars, {required List<Debt> trackedDebts}) {
    _setExtraAmount(
      (_extraAmount + amountDollars).clamp(0, 1000).toDouble(),
      trackedDebts: trackedDebts,
    );
  }

  void _setExtraAmount(double value, {required List<Debt> trackedDebts}) {
    setState(() => _extraAmount = value);
    _schedulePreview(trackedDebts);
  }

  void _maybeSchedulePreview(List<Debt> trackedDebts) {
    if (_isLoading || trackedDebts.isEmpty) return;

    final fingerprint = _previewStateFingerprint(trackedDebts);
    if (fingerprint == _previewFingerprint) return;
    _previewFingerprint = fingerprint;
    _schedulePreview(trackedDebts);
  }

  void _schedulePreview(List<Debt> trackedDebts) {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(_refreshPreview(trackedDebts)),
    );
  }

  Future<void> _refreshPreview(List<Debt> trackedDebts) async {
    final requestId = ++_previewRequestId;
    setState(() => _isPreviewLoading = true);

    try {
      final now = DateTime.now().toUtc();
      final draft = (_plan ?? _createDraftPlan(now)).copyWith(
        extraMonthlyAmount: _extraAmount.round() * 100,
        updatedAt: now,
      );
      final preview = await _planRecastService.previewPlan(
        plan: draft,
        debts: trackedDebts,
      );

      if (!mounted || requestId != _previewRequestId) return;
      setState(() {
        _preview = preview;
        _isPreviewLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _previewRequestId) return;
      setState(() => _isPreviewLoading = false);
    }
  }

  String _previewStateFingerprint(List<Debt> debts) {
    final buffer = StringBuffer()
      ..write(_plan?.strategy.name ?? 'none')
      ..write('|')
      ..write(_extraAmount.round() * 100);
    for (final debt in debts) {
      buffer
        ..write('|')
        ..write(debt.id)
        ..write(':')
        ..write(debt.currentBalance)
        ..write(':')
        ..write(debt.apr)
        ..write(':')
        ..write(debt.status.name);
    }
    return buffer.toString();
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

class _ExtraPreviewCard extends StatelessWidget {
  const _ExtraPreviewCard({
    required this.preview,
    required this.strategyLabel,
    required this.extraMonthlyAmount,
    required this.isLoading,
    required this.hasTrackedDebts,
  });

  final StrategyPreview? preview;
  final String strategyLabel;
  final int extraMonthlyAmount;
  final bool isLoading;
  final bool hasTrackedDebts;

  @override
  Widget build(BuildContext context) {
    if (!hasTrackedDebts) {
      return AppCard(
        color: AppColors.mdSurfaceContainerLow,
        child: Text(
          'Thêm ít nhất một khoản nợ để xem preview payoff thật.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

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
              Text('Live preview', style: AppTextStyles.titleSmall),
              const SizedBox(width: AppDimensions.sm),
              AppChip.status(label: strategyLabel, icon: LucideIcons.zap),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            preview?.projectedDebtFreeDate == null
                ? 'Đang recast...'
                : AppFormatters.formatMonthYear(preview!.projectedDebtFreeDate!),
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.mdPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Debt-free date với extra ${AppFormatters.formatCents(extraMonthlyAmount)} / tháng',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
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
                  label: 'Saved vs minimum',
                  value: preview == null
                      ? '--'
                      : AppFormatters.formatCents(preview!.totalInterestSaved),
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
