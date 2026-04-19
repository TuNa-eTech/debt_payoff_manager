import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/models/recast_delta.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/entities/timeline_projection.dart';
import '../../cubit/plan_timeline_cubit.dart';
import '../../cubit/plan_timeline_state.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlanTimelineCubit>()..start(),
      child: const _TimelineView(),
    );
  }
}

class _TimelineView extends StatefulWidget {
  const _TimelineView();

  @override
  State<_TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<_TimelineView> {
  final Set<int> _expandedMonths = <int>{0};

  void _toggleMonth(int monthIndex) {
    setState(() {
      if (!_expandedMonths.add(monthIndex)) {
        _expandedMonths.remove(monthIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanTimelineCubit, PlanTimelineState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kế hoạch')),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(PlanTimelineState state) {
    if (state.isLoading && !state.hasTrackedDebts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasTrackedDebts) {
      return const EmptyState(
        title: 'Chưa có kế hoạch để hiển thị',
        subtitle:
            'Thêm ít nhất một khoản nợ để app recast timeline, debt-free date, và projected interest của bạn.',
        icon: LucideIcons.map,
      );
    }

    if (state.allTrackedDebtsPaidOff) {
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
            const AppCard(
              color: AppColors.mdSurfaceContainerLow,
              child: EmptyState(
                title: 'Tất cả khoản nợ đã được trả xong',
                subtitle:
                    'Timeline tháng không còn khoản đang hoạt động. App vẫn giữ plan summary cuối cùng để bạn đối chiếu.',
                icon: LucideIcons.partyPopper,
              ),
            ),
          ],
        ),
      );
    }

    if (state.projection == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<PlanTimelineCubit>().load(),
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
              child: _DeltaBanner(state: state),
            ),
          const SizedBox(height: AppDimensions.sectionGap),
          _InterestComparisonCard(state: state),
          const SizedBox(height: AppDimensions.sectionGap),
          const SectionHeader(
            title: 'Timeline theo tháng',
            subtitle:
                'List-first view với payment breakdown, ending balance, và milestone payoff theo projection mới nhất.',
          ),
          const SizedBox(height: AppDimensions.md),
          ...state.projection!.months.map(
            (month) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: _MonthCard(
                month: month,
                debtNameById: {
                  for (final debt in state.debts) debt.id: debt.name,
                },
                isExpanded: _expandedMonths.contains(month.monthIndex),
                onToggle: () => _toggleMonth(month.monthIndex),
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

  final PlanTimelineState state;

  @override
  Widget build(BuildContext context) {
    final plan = state.plan;
    final projection = state.projection;
    final payoffDate = plan?.projectedDebtFreeDate;
    final projectedInterest = plan?.totalInterestProjected ?? 0;
    final savedInterest = plan?.totalInterestSaved ?? 0;

    return AppHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debt-free date',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mdPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            payoffDate == null
                ? 'Đang recast...'
                : AppFormatters.formatMonthYear(payoffDate),
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.mdOnPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Projected interest',
                  value: AppFormatters.formatCents(projectedInterest),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _HeroStat(
                  label: 'Saved vs minimum',
                  value: AppFormatters.formatCents(savedInterest),
                ),
              ),
            ],
          ),
          if (plan != null) ...[
            const SizedBox(height: AppDimensions.md),
            Text(
              '${plan.strategy.label} · Extra ${AppFormatters.formatCents(plan.extraMonthlyAmount)} / tháng · ${projection?.months.length ?? 0} tháng projected',
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

class _DeltaBanner extends StatelessWidget {
  const _DeltaBanner({required this.state});

  final PlanTimelineState state;

  @override
  Widget build(BuildContext context) {
    final delta = state.delta!;
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
                : LucideIcons.info,
            color: isPositive
                ? AppColors.mdPrimary
                : isNegative
                ? AppColors.debtRed
                : AppColors.mdOnSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              _message(delta),
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

  String _message(RecastDelta delta) {
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

    return 'Plan vừa được recast từ dữ liệu mới nhất.';
  }
}

class _InterestComparisonCard extends StatelessWidget {
  const _InterestComparisonCard({required this.state});

  final PlanTimelineState state;

  @override
  Widget build(BuildContext context) {
    final projectedInterest = state.plan?.totalInterestProjected ?? 0;
    final savedInterest = state.plan?.totalInterestSaved ?? 0;
    final minimumOnlyInterest = projectedInterest + savedInterest;

    return AppCard(
      color: AppColors.mdSurfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Projected vs minimum-only', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.md),
          _ComparisonRow(
            label: 'Kế hoạch hiện tại',
            value: AppFormatters.formatCents(projectedInterest),
            valueColor: AppColors.mdPrimary,
          ),
          const SizedBox(height: AppDimensions.sm),
          _ComparisonRow(
            label: 'Minimum-only baseline',
            value: AppFormatters.formatCents(minimumOnlyInterest),
          ),
          const SizedBox(height: AppDimensions.sm),
          _ComparisonRow(
            label: 'Tiết kiệm được',
            value: AppFormatters.formatCents(savedInterest),
            valueColor: AppColors.mdPrimary,
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: valueColor ?? AppColors.mdOnSurface,
          ),
        ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.debtNameById,
    required this.isExpanded,
    required this.onToggle,
  });

  final MonthProjection month;
  final Map<String, String> debtNameById;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final monthDate = DateTime.parse('${month.yearMonth}-01');

    return AppCard(
      key: AppTestKeys.timelineMonthCard(month.monthIndex),
      color: AppColors.mdSurface,
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.formatMonthYear(monthDate),
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      'Payment ${AppFormatters.formatCents(month.totalPaymentThisMonth)} · Interest ${AppFormatters.formatCents(month.totalInterestThisMonth)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                color: AppColors.mdOnSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Ending balance',
                  value: AppFormatters.formatCents(
                    month.totalBalanceEndOfMonth,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _MiniStat(
                  label: 'Debts paid off',
                  value:
                      '${month.entries.where((entry) => entry.isPaidOffThisMonth).length}',
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: AppDimensions.md),
            ...month.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.mdSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              debtNameById[entry.debtId] ?? entry.debtId,
                              style: AppTextStyles.titleSmall,
                            ),
                          ),
                          if (entry.isPaidOffThisMonth)
                            AppChip.status(
                              label: 'Paid off',
                              icon: LucideIcons.partyPopper,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      _ComparisonRow(
                        label: 'Starting balance',
                        value: AppFormatters.formatCents(entry.startingBalance),
                      ),
                      _ComparisonRow(
                        label: 'Interest accrued',
                        value: AppFormatters.formatCents(entry.interestAccrued),
                      ),
                      _ComparisonRow(
                        label: 'Payment applied',
                        value: AppFormatters.formatCents(entry.paymentApplied),
                      ),
                      _ComparisonRow(
                        label: 'Ending balance',
                        value: AppFormatters.formatCents(entry.endingBalance),
                        valueColor: entry.endingBalance == 0
                            ? AppColors.mdPrimary
                            : AppColors.mdOnSurface,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(value, style: AppTextStyles.titleSmall),
        ],
      ),
    );
  }
}
