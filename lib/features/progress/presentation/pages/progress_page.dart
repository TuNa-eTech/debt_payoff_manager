import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/i18n/strategy_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/milestone.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/enums/milestone_type.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../cubit/progress_cubit.dart';
import '../../cubit/progress_state.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgressCubit>(
      create: (_) => getIt<ProgressCubit>()..start(),
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, progressState) {
        return BlocBuilder<DebtsCubit, DebtsState>(
          builder: (context, debtsState) {
            if (progressState.isLoading || debtsState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final debts = debtsState.debts
                .where((debt) => debt.status != DebtStatus.archived)
                .toList(growable: false);

            if (debts.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: Text(context.l10n.progressTitle)),
                body: EmptyState(
                  title: context.l10n.progressNoProgress,
                  subtitle: context.l10n.progressEmptySubtitle,
                  icon: LucideIcons.barChart2,
                ),
              );
            }

            final paidOffCount = debts
                .where((d) => d.status == DebtStatus.paidOff)
                .length;
            final pausedCount = debts
                .where((d) => d.status == DebtStatus.paused)
                .length;
            final activeCount = debts
                .where((d) => d.status == DebtStatus.active)
                .length;

            return Scaffold(
              appBar: AppBar(title: Text(context.l10n.progressTitle)),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH,
                  vertical: AppDimensions.pagePaddingV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero: paid so far + overall %
                    AppHeroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.progressPaidSoFar,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.mdPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            AppFormatters.formatCents(
                              progressState.totalPaidCents,
                            ),
                            style: AppTextStyles.moneyLarge.copyWith(
                              color: AppColors.mdOnPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            context.l10n.progressRemainingAmount(
                              AppFormatters.formatCents(
                                progressState.totalRemainingCents,
                              ),
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.mdOnPrimary.withValues(
                                alpha: 0.82,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.progressOverall,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.mdOnPrimary.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                              ),
                              Text(
                                '${(progressState.overallProgress * 100).round()}%',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.mdPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          LinearProgressIndicator(
                            value: progressState.overallProgress,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.18,
                            ),
                            color: AppColors.mdPrimaryContainer,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Streak + interest saved stats
                    const SizedBox(height: AppDimensions.sectionGap),
                    AppCard(
                      color: AppColors.mdSurfaceContainerLow,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProgressStat(
                              label: context.l10n.progressInterestSaved,
                              value: AppFormatters.formatCents(
                                progressState.interestSavedCents,
                              ),
                              valueColor: AppColors.mdPrimary,
                            ),
                          ),
                          const _ProgressDivider(),
                          Expanded(
                            child: _ProgressStat(
                              label: '🔥',
                              value: context.l10n.progressStreakMonths(
                                progressState.streak,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Plan summary (debt-free date, extra, projected interest)
                    const SizedBox(height: AppDimensions.sectionGap),
                    _PlanSummaryCard(planRepository: getIt<PlanRepository>()),

                    // Status counts
                    const SizedBox(height: AppDimensions.sectionGap),
                    AppCard(
                      color: AppColors.mdSurfaceContainerLow,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProgressStat(
                              label: context.l10n.homeTrackedLabel,
                              value: '$activeCount',
                            ),
                          ),
                          const _ProgressDivider(),
                          Expanded(
                            child: _ProgressStat(
                              label: context.l10n.homePaidOffLabel,
                              value: '$paidOffCount',
                              valueColor: AppColors.mdPrimary,
                            ),
                          ),
                          const _ProgressDivider(),
                          Expanded(
                            child: _ProgressStat(
                              label: context.l10n.homePausedLabel,
                              value: '$pausedCount',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Achievements (earned milestones)
                    if (progressState.unseenMilestones.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.sectionGap),
                      SectionHeader(title: context.l10n.progressAchievements),
                      const SizedBox(height: AppDimensions.md),
                      _MilestoneBadgesRow(
                        milestones: progressState.unseenMilestones,
                      ),
                    ],

                    const SizedBox(height: AppDimensions.sectionGap),
                    AppCard(
                      color: AppColors.mdSurfaceContainerLow,
                      child: Text(
                        context.l10n.progressTabHelper,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.mdOnSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionGap),
                    _MonthlySummaryEntryCard(),
                    const SizedBox(height: AppDimensions.sectionGap),
                    SectionHeader(
                      title: context.l10n.progressByDebt,
                      subtitle: context.l10n.progressByDebtHelper,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    ...debts.map(
                      (debt) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.md,
                        ),
                        child: _DebtProgressCard(debt: debt),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.planRepository});

  final PlanRepository planRepository;

  @override
  Widget build(BuildContext context) {
    final scenarioId = context.userSettings?.activeScenarioId ?? 'main';
    return StreamBuilder(
      stream: planRepository.watchCurrentPlan(scenarioId: scenarioId),
      builder: (context, snapshot) {
        final plan = snapshot.data;
        if (plan == null) return const SizedBox.shrink();
        return AppCard(
          color: AppColors.mdSurfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.progressPlanSummary,
                    style: AppTextStyles.titleSmall,
                  ),
                  const Spacer(),
                  AppChip.status(
                    label: plan.strategy.localizedLabel(context.l10n),
                    icon: LucideIcons.map,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: _ProgressStat(
                      label: context.l10n.progressDebtFreeDate,
                      value: plan.projectedDebtFreeDate == null
                          ? context.l10n.monthlyActionRecasting
                          : AppFormatters.formatShortMonthYear(
                              plan.projectedDebtFreeDate!,
                            ),
                      valueColor: AppColors.mdPrimary,
                    ),
                  ),
                  Expanded(
                    child: _ProgressStat(
                      label: context.l10n.homeExtraMonthlyLabel,
                      value: AppFormatters.formatCents(plan.extraMonthlyAmount),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: _ProgressStat(
                      label: context.l10n.progressProjectedInterest,
                      value: AppFormatters.formatCents(
                        plan.totalInterestProjected ?? 0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _ProgressStat(
                      label: context.l10n.progressSavedVsMinimum,
                      value: AppFormatters.formatCents(
                        plan.totalInterestSaved ?? 0,
                      ),
                      valueColor: AppColors.mdPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MilestoneBadgesRow extends StatelessWidget {
  const _MilestoneBadgesRow({required this.milestones});

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: milestones
          .map((m) => _MilestoneBadge(type: m.type))
          .toList(growable: false),
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({required this.type});

  final MilestoneType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.mdPrimaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        type.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.mdOnPrimaryContainer,
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
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

class _ProgressDivider extends StatelessWidget {
  const _ProgressDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      color: AppColors.mdOutlineVariant,
    );
  }
}

class _DebtProgressCard extends StatelessWidget {
  const _DebtProgressCard({required this.debt});

  final Debt debt;

  @override
  Widget build(BuildContext context) {
    final paidAmount = (debt.originalPrincipal - debt.currentBalance).clamp(
      0,
      debt.originalPrincipal,
    );
    final progress = debt.originalPrincipal == 0
        ? 0.0
        : paidAmount / debt.originalPrincipal;
    final isPaidOff = debt.status == DebtStatus.paidOff;
    final isPaused = debt.status == DebtStatus.paused;

    return AppCard(
      color: isPaidOff
          ? AppColors.successContainer
          : isPaused
          ? AppColors.mdSurfaceContainerLow
          : AppColors.mdSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(debt.name, style: AppTextStyles.titleMedium),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isPaidOff ? AppColors.success : AppColors.mdPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            isPaidOff
                ? context.l10n.progressDebtPaidOffStatus
                : isPaused
                ? context.l10n.progressDebtPausedStatus
                : context.l10n.progressDebtRemainingVsOriginal(
                    AppFormatters.formatCents(debt.currentBalance),
                    AppFormatters.formatCents(debt.originalPrincipal),
                  ),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.mdSurfaceContainerHighest,
            color: isPaidOff ? AppColors.success : AppColors.mdPrimary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
        ],
      ),
    );
  }
}

class _MonthlySummaryEntryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.monthlySummary),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mdPrimaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              LucideIcons.calendarDays,
              size: 22,
              color: AppColors.mdOnPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.monthlySummaryTitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AppFormatters.formatMonthYear(DateTime.now()),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: AppColors.mdOutline,
          ),
        ],
      ),
    );
  }
}
