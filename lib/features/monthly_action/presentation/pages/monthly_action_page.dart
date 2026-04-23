import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/models/monthly_action_models.dart';
import '../../../../core/models/recast_delta.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../debts/presentation/debt_ui_utils.dart';
import '../../cubit/monthly_action_cubit.dart';
import '../../cubit/monthly_action_state.dart';

/// Monthly action page — "Tháng này bạn cần trả".
class MonthlyActionPage extends StatelessWidget {
  const MonthlyActionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MonthlyActionCubit>()..start(),
      child: const _MonthlyActionView(),
    );
  }
}

class _MonthlyActionView extends StatelessWidget {
  const _MonthlyActionView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MonthlyActionCubit, MonthlyActionState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.monthlyActionThisMonth),
            actions: [
              if (state.referenceDate != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.md),
                  child: Center(
                    child: AppChip.status(
                      label: AppFormatters.formatShortMonthYear(
                        state.referenceDate!,
                      ),
                      icon: LucideIcons.calendarDays,
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MonthlyActionState state) {
    if (state.isLoading && !state.hasTrackedDebts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasTrackedDebts) {
      return EmptyState(
        title: context.l10n.monthlyActionEmptyTitle,
        subtitle: context.l10n.monthlyActionEmptySubtitle,
        icon: LucideIcons.walletCards,
      );
    }

    if (!state.hasActionItems) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PlanHero(state: state),
            const SizedBox(height: AppDimensions.sectionGap),
            AppCard(
              color: AppColors.mdSurfaceContainerLow,
              child: EmptyState(
                title: context.l10n.monthlyActionNoChecklist,
                subtitle: context.l10n.monthlyActionNoChecklistSubtitle,
                icon: LucideIcons.partyPopper,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MonthlyActionCubit>().loadMonthlyActions(),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingV,
        ),
        children: [
          _PlanHero(state: state),
          if (state.delta?.hasMeaningfulChange ?? false)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.md),
              child: _RecastBanner(delta: state.delta!),
            ),
          const SizedBox(height: AppDimensions.sectionGap),
          _SummaryCard(summary: state.summary),
          const SizedBox(height: AppDimensions.sectionGap),
          SectionHeader(
            title: context.l10n.monthlyActionNeedToPay,
            subtitle: context.l10n.monthlyActionChecklistHelper,
          ),
          const SizedBox(height: AppDimensions.md),
          ...state.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: _MonthlyActionSectionCard(
                section: section,
                submittingIds: state.submittingIds,
                onCheckOff: (item) =>
                    context.read<MonthlyActionCubit>().checkOffPayment(item),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PlanHero extends StatelessWidget {
  const _PlanHero({required this.state});

  final MonthlyActionState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final plan = state.plan;
    return AppHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.progressDebtFreeDate,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mdPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            plan?.projectedDebtFreeDate == null
                ? context.l10n.monthlyActionRecasting
                : AppFormatters.formatMonthYear(plan!.projectedDebtFreeDate!),
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.mdOnPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: context.l10n.monthlyActionTotalThisMonth,
                  value: summary == null
                      ? '--'
                      : AppFormatters.formatCents(summary.totalDueCents),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _HeroStat(
                  label: context.l10n.monthlyActionCompleted,
                  value: summary == null
                      ? '--'
                      : '${summary.completedCount}/${summary.totalCount}',
                ),
              ),
            ],
          ),
          if (plan != null) ...[
            const SizedBox(height: AppDimensions.md),
            Text(
              '${plan.strategy.label} · Extra ${AppFormatters.formatCents(plan.extraMonthlyAmount)} / ${context.l10n.commonMonth}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mdOnPrimary.withValues(alpha: 0.82),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mdPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.mdOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final MonthlyActionSummary? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const AppCard(
        color: AppColors.mdSurfaceContainerLow,
        child: SizedBox(
          height: 96,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AppCard(
      color: AppColors.mdSurfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: context.l10n.paymentTypeMinimumLabel,
              value: AppFormatters.formatCents(summary!.totalMinimumCents),
            ),
          ),
          const _Divider(),
          Expanded(
            child: _SummaryStat(
              label: context.l10n.paymentTypeExtraLabel,
              value: AppFormatters.formatCents(summary!.totalExtraCents),
              valueColor: AppColors.mdPrimary,
            ),
          ),
          const _Divider(),
          Expanded(
            child: _SummaryStat(
              label: context.l10n.monthlyActionOverdueChip,
              value: '${summary!.overdueCount}',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      color: AppColors.mdOutlineVariant,
    );
  }
}

class _RecastBanner extends StatelessWidget {
  const _RecastBanner({required this.delta});

  final RecastDelta delta;

  @override
  Widget build(BuildContext context) {
    final monthDelta = delta.debtFreeMonthDelta;
    final projectedDelta = delta.projectedInterestDelta;
    final savedDelta = delta.savedInterestDelta;
    final movedSooner = delta.hasDebtFreeDateChange && monthDelta < 0;
    final movedLater = delta.hasDebtFreeDateChange && monthDelta > 0;
    final improvedInterest =
        !delta.hasDebtFreeDateChange &&
        ((projectedDelta != null && projectedDelta < 0) ||
            (savedDelta != null && savedDelta > 0));
    final worsenedInterest =
        !delta.hasDebtFreeDateChange &&
        ((projectedDelta != null && projectedDelta > 0) ||
            (savedDelta != null && savedDelta < 0));
    final isPositive = movedSooner || improvedInterest;
    final isNegative = movedLater || worsenedInterest;

    return AppCard(
      color: isPositive
          ? AppColors.mdPrimaryContainer
          : isNegative
          ? AppColors.mdErrorContainer
          : AppColors.mdSurfaceContainerLow,
      borderColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPositive
                ? LucideIcons.trendingDown
                : isNegative
                ? LucideIcons.alertCircle
                : LucideIcons.sparkles,
            color: isPositive
                ? AppColors.mdPrimary
                : isNegative
                ? AppColors.debtRed
                : AppColors.mdOnSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              _message(),
              style: AppTextStyles.bodySmall.copyWith(
                color: isPositive
                    ? AppColors.mdOnPrimaryContainer
                    : isNegative
                    ? AppColors.debtRed
                    : AppColors.mdOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _message() {
    if (delta.hasDebtFreeDateChange &&
        delta.previousDebtFreeDate != null &&
        delta.newDebtFreeDate != null) {
      final monthDelta = delta.debtFreeMonthDelta;
      return 'Debt-free date: ${AppFormatters.formatMonthYear(delta.previousDebtFreeDate!)} → ${AppFormatters.formatMonthYear(delta.newDebtFreeDate!)}'
          '${monthDelta == 0
              ? ''
              : monthDelta < 0
              ? ' (sớm hơn ${monthDelta.abs()} tháng)'
              : ' (trễ hơn $monthDelta tháng)'}';
    }

    if (delta.hasProjectedInterestChange &&
        delta.previousTotalInterestProjected != null &&
        delta.newTotalInterestProjected != null) {
      final projectedDelta = delta.projectedInterestDelta!;
      return 'Projected interest: ${AppFormatters.formatCents(delta.previousTotalInterestProjected!)} → ${AppFormatters.formatCents(delta.newTotalInterestProjected!)}'
          '${projectedDelta == 0
              ? ''
              : projectedDelta < 0
              ? ' (giảm ${AppFormatters.formatCents(projectedDelta.abs())})'
              : ' (tăng ${AppFormatters.formatCents(projectedDelta)})'}';
    }

    if (delta.hasSavedInterestChange &&
        delta.previousTotalInterestSaved != null &&
        delta.newTotalInterestSaved != null) {
      final savedDelta = delta.savedInterestDelta!;
      return 'Saved vs minimum: ${AppFormatters.formatCents(delta.previousTotalInterestSaved!)} → ${AppFormatters.formatCents(delta.newTotalInterestSaved!)}'
          '${savedDelta == 0
              ? ''
              : savedDelta > 0
              ? ' (tăng ${AppFormatters.formatCents(savedDelta)})'
              : ' (giảm ${AppFormatters.formatCents(savedDelta.abs())})'}';
    }

    return 'Timeline vừa được recast từ dữ liệu mới nhất của bạn.';
  }
}

class _MonthlyActionSectionCard extends StatelessWidget {
  const _MonthlyActionSectionCard({
    required this.section,
    required this.submittingIds,
    required this.onCheckOff,
  });

  final MonthlyActionSection section;
  final Set<String> submittingIds;
  final ValueChanged<MonthlyActionItem> onCheckOff;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: AppTestKeys.monthlyActionSection(section.debtId),
      color: AppColors.mdSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                debtTypeIcon(section.debtType),
                color: AppColors.mdPrimary,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.debtName, style: AppTextStyles.titleMedium),
                    Text(
                      context.l10n.monthlyActionRequiredTotal(
                        AppFormatters.formatCents(section.totalDueCents),
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (section.isCompleted)
                AppChip.status(
                  label: context.l10n.monthlyActionDoneBadge,
                  icon: LucideIcons.check,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...section.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: _ActionRow(
                item: item,
                isSubmitting: submittingIds.contains(item.id),
                onCheckOff: () => onCheckOff(item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.item,
    required this.isSubmitting,
    required this.onCheckOff,
  });

  final MonthlyActionItem item;
  final bool isSubmitting;
  final VoidCallback onCheckOff;

  @override
  Widget build(BuildContext context) {
    final title = item.kind == MonthlyActionKind.minimum
        ? context.l10n.paymentTypeMinimumLabel
        : context.l10n.paymentTypeExtraLabel;
    final chipLabel = item.isOverdue
        ? context.l10n.monthlyActionOverdueChip
        : item.isUpcoming
        ? context.l10n.monthlyActionUpcomingChip
        : item.kind == MonthlyActionKind.extra && item.priorityRank != null
        ? context.l10n.monthlyActionPriorityChip(item.priorityRank!)
        : null;

    return Container(
      key: AppTestKeys.monthlyActionItem(item.id),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: item.isCompleted
            ? AppColors.mdPrimaryContainer.withValues(alpha: 0.35)
            : AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: item.isOverdue
              ? AppColors.debtRed.withValues(alpha: 0.2)
              : AppColors.whisperBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  item.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  item.kind == MonthlyActionKind.minimum
                      ? context.l10n.monthlyActionDueDate(
                          AppFormatters.formatDate(item.dueDate),
                        )
                      : context.l10n.monthlyActionInMonth(
                          AppFormatters.formatMonthYear(item.dueDate),
                        ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
                if (chipLabel != null) ...[
                  const SizedBox(height: AppDimensions.sm),
                  AppChip.status(label: chipLabel),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.formatCents(item.amountCents),
                style: AppTextStyles.titleMedium.copyWith(
                  color: item.isOverdue
                      ? AppColors.debtRed
                      : AppColors.mdOnSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              SizedBox(
                key: AppTestKeys.monthlyActionCheckOff(item.id),
                child: AppButton.tonal(
                  label: item.isCompleted
                      ? context.l10n.monthlyActionLogged
                      : context.l10n.monthlyActionCheckOff,
                  icon: item.isCompleted
                      ? LucideIcons.checkCircle2
                      : LucideIcons.check,
                  loading: isSubmitting,
                  onPressed: item.isCompleted || isSubmitting
                      ? null
                      : onCheckOff,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
