import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/models/monthly_action_models.dart';
import '../../../../core/models/recast_delta.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/enums/debt_status.dart';
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
          backgroundColor: AppColors.mdSurfaceContainerLow,
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
      return KeyedSubtree(
        key: AppTestKeys.monthlyActionEmptyAddDebt,
        child: EmptyState(
          title: context.l10n.monthlyActionEmptyTitle,
          subtitle: context.l10n.monthlyActionEmptySubtitle,
          icon: LucideIcons.walletCards,
          actionLabel: context.l10n.commonAddDebt,
          onAction: () => context.push(AppRoutes.addDebt),
        ),
      );
    }

    final nextAction = _selectNextAction(state);
    final allDone =
        state.summary != null &&
        state.summary!.allCompleted &&
        state.hasActionItems;

    if (!state.hasActionItems) {
      return RefreshIndicator(
        onRefresh: () =>
            context.read<MonthlyActionCubit>().loadMonthlyActions(),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          children: [
            _CompletionCard(
              state: state,
              onViewPlan: () => context.go(AppRoutes.plan),
            ),
            if (state.summary?.hasSingleTrackedDebt ?? false) ...[
              const SizedBox(height: AppDimensions.md),
              _SingleDebtSnapshotCard(
                summary: state.summary!,
                onViewProgress: () => context.go(AppRoutes.progress),
                onAddDebt: () => context.push(AppRoutes.addDebt),
              ),
            ],
            const SizedBox(height: AppDimensions.md),
            if (state.delta?.hasMeaningfulChange ?? false)
              _RecastBanner(delta: state.delta!),
            const SizedBox(height: 80),
          ],
        ),
      );
    }

    if (allDone) {
      return RefreshIndicator(
        onRefresh: () =>
            context.read<MonthlyActionCubit>().loadMonthlyActions(),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          children: [
            _DoneProofDashboard(
              state: state,
              onViewPlan: () => context.go(AppRoutes.plan),
              onViewHistory: () {
                final debtId = _historyDebtId(state);
                if (debtId == null) return;
                final route = state.summary!.trackedDebtCount == 1
                    ? AppRoutes.paymentHistoryPath(debtId)
                    : AppRoutes.debtDetailPath(debtId);
                context.push(route);
              },
              onLogAnother: () {
                final debtId = _logDebtId(state);
                if (debtId != null) {
                  context.push(AppRoutes.logPaymentPath(debtId));
                }
              },
            ),
            if (state.delta?.hasMeaningfulChange ?? false) ...[
              const SizedBox(height: AppDimensions.sm),
              _RecastBanner(delta: state.delta!),
            ],
            const SizedBox(height: AppDimensions.md),
            _SummaryStrip(summary: state.summary),
            if (state.summary?.hasSingleTrackedDebt ?? false) ...[
              const SizedBox(height: AppDimensions.md),
              _SingleDebtSnapshotCard(
                summary: state.summary!,
                onViewProgress: () => context.go(AppRoutes.progress),
                onAddDebt: () => context.push(AppRoutes.addDebt),
              ),
            ],
            const SizedBox(height: AppDimensions.md),
            _CompletedChecklistSection(
              sections: state.sections,
              submittingIds: state.submittingIds,
              onCheckOff: (item) => _showCheckOffSheet(context, item),
            ),
            const SizedBox(height: 80),
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
          _NextActionCard(
            item: nextAction,
            summary: state.summary,
            onCheckOff: nextAction == null
                ? null
                : () => _showCheckOffSheet(context, nextAction),
            onViewPlan: () => context.go(AppRoutes.plan),
          ),
          if (state.delta?.hasMeaningfulChange ?? false) ...[
            const SizedBox(height: AppDimensions.sm),
            _RecastBanner(delta: state.delta!),
          ],
          const SizedBox(height: AppDimensions.md),
          _SummaryStrip(summary: state.summary),
          const SizedBox(height: AppDimensions.md),
          SectionHeader(
            title: context.l10n.monthlyActionNeedToPay,
            subtitle: context.l10n.monthlyActionChecklistHelper,
          ),
          const SizedBox(height: AppDimensions.sm),
          ...state.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: _MonthlyActionSectionCard(
                section: section,
                submittingIds: state.submittingIds,
                onCheckOff: (item) => _showCheckOffSheet(context, item),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  MonthlyActionItem? _selectNextAction(MonthlyActionState state) {
    final items = state.sections
        .expand((section) => section.items)
        .where((item) => !item.isCompleted)
        .toList(growable: false);
    if (items.isEmpty) return null;

    MonthlyActionItem? firstWhere(bool Function(MonthlyActionItem) test) {
      for (final item in items) {
        if (test(item)) return item;
      }
      return null;
    }

    return firstWhere(
          (item) => item.kind == MonthlyActionKind.minimum && item.isOverdue,
        ) ??
        firstWhere(
          (item) => item.kind == MonthlyActionKind.minimum && item.isUpcoming,
        ) ??
        firstWhere((item) => item.kind == MonthlyActionKind.minimum) ??
        firstWhere((item) => item.kind == MonthlyActionKind.extra) ??
        items.first;
  }

  String? _historyDebtId(MonthlyActionState state) {
    if (state.summary?.trackedDebtCount == 1) {
      return state.summary?.singleDebtId;
    }
    return _latestProofItem(state.sections)?.debtId;
  }

  String? _logDebtId(MonthlyActionState state) {
    return _latestProofItem(state.sections)?.debtId ??
        state.summary?.singleDebtId;
  }

  Future<void> _showCheckOffSheet(
    BuildContext context,
    MonthlyActionItem item,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        var isSubmitting = false;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> confirm() async {
              setSheetState(() => isSubmitting = true);
              final success = await context
                  .read<MonthlyActionCubit>()
                  .checkOffPayment(item);
              if (!sheetContext.mounted) return;
              Navigator.of(sheetContext).pop();

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.monthlyActionSnackbarSaved(item.debtName),
                    ),
                  ),
                );
              }
            }

            void logCustomPayment() {
              Navigator.of(sheetContext).pop();
              context.push(AppRoutes.logPaymentPath(item.debtId));
            }

            return SafeArea(
              top: false,
              child: Padding(
                key: AppTestKeys.monthlyActionConfirmSheet,
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pagePaddingH,
                  0,
                  AppDimensions.pagePaddingH,
                  AppDimensions.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.monthlyActionConfirmTitle,
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      context.l10n.monthlyActionConfirmSubtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _ConfirmInfoRow(
                      label: context.l10n.monthlyActionInfoDebt,
                      value: item.debtName,
                    ),
                    _ConfirmInfoRow(
                      label: context.l10n.monthlyActionInfoType,
                      value: _actionTitle(context, item),
                    ),
                    _ConfirmInfoRow(
                      label: context.l10n.monthlyActionInfoAmount,
                      value: AppFormatters.formatCents(item.amountCents),
                    ),
                    _ConfirmInfoRow(
                      label: context.l10n.monthlyActionInfoDate,
                      value: AppFormatters.formatDate(
                        context
                                .read<MonthlyActionCubit>()
                                .state
                                .referenceDate ??
                            item.dueDate,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    SizedBox(
                      key: AppTestKeys.monthlyActionConfirmPrimary,
                      child: AppButton.filled(
                        label: context.l10n.monthlyActionConfirmPrimary,
                        icon: LucideIcons.check,
                        loading: isSubmitting,
                        fullWidth: true,
                        onPressed: isSubmitting ? null : confirm,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    SizedBox(
                      key: AppTestKeys.monthlyActionConfirmCustom,
                      child: AppButton.outlined(
                        label: context.l10n.monthlyActionLogDifferent,
                        icon: LucideIcons.pencil,
                        fullWidth: true,
                        onPressed: isSubmitting ? null : logCustomPayment,
                      ),
                    ),
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

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({
    required this.item,
    required this.summary,
    required this.onCheckOff,
    required this.onViewPlan,
  });

  final MonthlyActionItem? item;
  final MonthlyActionSummary? summary;
  final VoidCallback? onCheckOff;
  final VoidCallback onViewPlan;

  @override
  Widget build(BuildContext context) {
    final nextItem = item;
    if (nextItem == null) {
      return _CompletionCard(summary: summary, onViewPlan: onViewPlan);
    }

    final chipLabel = _statusChipLabel(context, nextItem);
    final isUrgent = nextItem.isOverdue;

    return AppCard(
      key: AppTestKeys.monthlyActionNextAction,
      color: AppColors.mdSurface,
      borderColor: isUrgent
          ? AppColors.debtRed.withValues(alpha: 0.28)
          : AppColors.whisperBorder,
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.mdErrorContainer
                      : AppColors.mdPrimaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(
                  isUrgent
                      ? LucideIcons.alertCircle
                      : LucideIcons.calendarCheck,
                  size: AppDimensions.iconMd,
                  color: isUrgent ? AppColors.debtRed : AppColors.mdPrimary,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.monthlyActionNextPay,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(nextItem.debtName, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      _actionSubtitle(context, nextItem),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCents(nextItem.amountCents),
                    style: AppTextStyles.moneyXSmall.copyWith(
                      color: isUrgent
                          ? AppColors.debtRed
                          : AppColors.mdOnSurface,
                    ),
                  ),
                  if (chipLabel != null) ...[
                    const SizedBox(height: AppDimensions.xs),
                    AppChip.status(label: chipLabel),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  _dueText(context, nextItem),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(
                key: AppTestKeys.monthlyActionNextCheckOff(nextItem.id),
                child: AppButton.filled(
                  label: context.l10n.monthlyActionCheckOff,
                  icon: LucideIcons.check,
                  onPressed: onCheckOff,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoneProofDashboard extends StatelessWidget {
  const _DoneProofDashboard({
    required this.state,
    required this.onViewPlan,
    required this.onViewHistory,
    required this.onLogAnother,
  });

  final MonthlyActionState state;
  final VoidCallback onViewPlan;
  final VoidCallback onViewHistory;
  final VoidCallback onLogAnother;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary!;
    final latestProof = _latestProofItem(state.sections)?.completionProof;
    final latestLabel = latestProof == null
        ? context.l10n.monthlyActionNoLoggedDate
        : AppFormatters.formatDate(latestProof.date);
    final canLogAnother =
        _latestProofItem(state.sections) != null ||
        summary.singleDebtId != null;

    return AppCard(
      key: AppTestKeys.monthlyActionDoneDashboard,
      color: AppColors.mdSurface,
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.mdPrimaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(
                  LucideIcons.checkCircle2,
                  size: AppDimensions.iconMd,
                  color: AppColors.mdPrimary,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.monthlyActionDoneProofTitle,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      _doneProofSubtitle(context, summary),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: context.l10n.monthlyActionStatLogged,
                  value: AppFormatters.formatCents(summary.loggedTotalCents),
                  valueColor: AppColors.mdPrimary,
                ),
              ),
              const _Divider(),
              Expanded(
                child: _SummaryStat(
                  label: context.l10n.monthlyActionStatRemaining,
                  value: AppFormatters.formatCents(
                    summary.remainingBalanceCents,
                  ),
                ),
              ),
              const _Divider(),
              Expanded(
                child: _SummaryStat(
                  label: context.l10n.monthlyActionStatLatestLogged,
                  value: latestLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              _IconButtonWithLabel(
                label: context.l10n.monthlyActionViewHistory,
                icon: LucideIcons.history,
                onPressed: onViewHistory,
              ),
              if (canLogAnother) ...[
                const SizedBox(width: AppDimensions.sm),
                _IconButtonWithLabel(
                  label: context.l10n.monthlyActionLogAnother,
                  icon: LucideIcons.plus,
                  onPressed: onLogAnother,
                ),
              ],
              const SizedBox(width: AppDimensions.sm),
              _IconButtonWithLabel(
                label: context.l10n.monthlyActionNextActionPrimary,
                icon: LucideIcons.map,
                onPressed: onViewPlan,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _doneProofSubtitle(
    BuildContext context,
    MonthlyActionSummary summary,
  ) {
    final debtName = summary.singleDebtName;
    if (summary.hasSingleTrackedDebt && debtName != null) {
      if (summary.singleTrackedDebtPaidOff) {
        return context.l10n.monthlyActionDoneProofSinglePaidOff(debtName);
      }
      return context.l10n.monthlyActionDoneProofSingleRemaining(
        debtName,
        AppFormatters.formatCents(summary.remainingBalanceCents),
      );
    }

    return context.l10n.monthlyActionDoneProofSubtitle(
      AppFormatters.formatCents(summary.loggedTotalCents),
    );
  }
}

class _SingleDebtSnapshotCard extends StatelessWidget {
  const _SingleDebtSnapshotCard({
    required this.summary,
    required this.onViewProgress,
    required this.onAddDebt,
  });

  final MonthlyActionSummary summary;
  final VoidCallback onViewProgress;
  final VoidCallback onAddDebt;

  @override
  Widget build(BuildContext context) {
    final isPaidOff = summary.singleTrackedDebtPaidOff;

    return AppCard(
      key: AppTestKeys.monthlyActionSingleDebtCard,
      color: AppColors.mdSurface,
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPaidOff
                ? context.l10n.monthlyActionSingleDebtPaidOffTitle
                : context.l10n.monthlyActionSingleDebtTitle,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppDimensions.sm),
          _SingleDebtInfoRow(
            label: context.l10n.monthlyActionSingleDebtRemainingLabel,
            value: AppFormatters.formatCents(summary.remainingBalanceCents),
          ),
          if (summary.singleDebtDueDate != null)
            _SingleDebtInfoRow(
              label: context.l10n.monthlyActionSingleDebtDueDateLabel,
              value: AppFormatters.formatDate(summary.singleDebtDueDate!),
            ),
          if (summary.singleDebtStatus != null)
            _SingleDebtInfoRow(
              label: context.l10n.monthlyActionSingleDebtStatusLabel,
              value: _debtStatusLabel(context, summary.singleDebtStatus!),
            ),
          if (isPaidOff) ...[
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: [
                AppButton.tonal(
                  label: context.l10n.monthlyActionViewProgress,
                  icon: LucideIcons.trendingDown,
                  onPressed: onViewProgress,
                ),
                AppButton.outlined(
                  label: context.l10n.monthlyActionAddAnotherDebt,
                  icon: LucideIcons.plus,
                  onPressed: onAddDebt,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SingleDebtInfoRow extends StatelessWidget {
  const _SingleDebtInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({this.state, this.summary, this.onViewPlan});

  final MonthlyActionState? state;
  final MonthlyActionSummary? summary;
  final VoidCallback? onViewPlan;

  @override
  Widget build(BuildContext context) {
    final effectiveSummary = summary ?? state?.summary;

    return AppCard(
      color: AppColors.mdSurface,
      onTap: onViewPlan,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm + AppDimensions.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.mdPrimaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Icon(
              LucideIcons.checkCircle2,
              size: AppDimensions.iconSm,
              color: AppColors.mdPrimary,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.monthlyActionNextActionTitle,
                  style: AppTextStyles.bodyMedium,
                ),
                if (effectiveSummary != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.check,
                        size: 12,
                        color: AppColors.mdPrimary,
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Text(
                        context.l10n.monthlyActionCompletionChip(
                          effectiveSummary.completedCount,
                          effectiveSummary.totalCount,
                        ),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.mdPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onViewPlan != null) ...[
            const SizedBox(width: AppDimensions.xs),
            Icon(
              LucideIcons.chevronRight,
              size: AppDimensions.iconSm,
              color: AppColors.mdOnSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary});

  final MonthlyActionSummary? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const AppCard(
        color: AppColors.mdSurface,
        padding: EdgeInsets.all(AppDimensions.md),
        child: SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (summary!.allCompleted) {
      return AppCard(
        color: AppColors.mdSurface,
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            Expanded(
              child: _SummaryStat(
                label: context.l10n.monthlyActionStatLogged,
                value: AppFormatters.formatCents(summary!.loggedTotalCents),
                valueColor: AppColors.mdPrimary,
              ),
            ),
            const _Divider(),
            Expanded(
              child: _SummaryStat(
                label: context.l10n.monthlyActionCompleted,
                value: '${summary!.completedCount}/${summary!.totalCount}',
              ),
            ),
            const _Divider(),
            Expanded(
              child: _SummaryStat(
                label: context.l10n.monthlyActionStatRemaining,
                value: AppFormatters.formatCents(
                  summary!.remainingBalanceCents,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      color: AppColors.mdSurface,
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: context.l10n.monthlyActionTotalThisMonth,
              value: AppFormatters.formatCents(summary!.totalDueCents),
            ),
          ),
          const _Divider(),
          Expanded(
            child: _SummaryStat(
              label: context.l10n.monthlyActionCompleted,
              value: '${summary!.completedCount}/${summary!.totalCount}',
              valueColor: AppColors.mdPrimary,
            ),
          ),
          const _Divider(),
          Expanded(
            child: _SummaryStat(
              label: context.l10n.monthlyActionOverdueChip,
              value: '${summary!.overdueCount}',
              valueColor: summary!.overdueCount > 0 ? AppColors.debtRed : null,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
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
          : AppColors.mdSurface,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(AppDimensions.md),
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
              _message(context),
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

  String _message(BuildContext context) {
    final l10n = context.l10n;
    if (delta.hasDebtFreeDateChange &&
        delta.previousDebtFreeDate != null &&
        delta.newDebtFreeDate != null) {
      final monthDelta = delta.debtFreeMonthDelta;
      return l10n.monthlyActionRecastDebtFree(
        AppFormatters.formatMonthYear(delta.previousDebtFreeDate!),
        AppFormatters.formatMonthYear(delta.newDebtFreeDate!),
        monthDelta == 0
            ? ''
            : monthDelta < 0
            ? l10n.monthlyActionDeltaSooner(monthDelta.abs())
            : l10n.monthlyActionDeltaLater(monthDelta),
      );
    }

    if (delta.hasProjectedInterestChange &&
        delta.previousTotalInterestProjected != null &&
        delta.newTotalInterestProjected != null) {
      final projectedDelta = delta.projectedInterestDelta!;
      return l10n.monthlyActionRecastProjectedInterest(
        AppFormatters.formatCents(delta.previousTotalInterestProjected!),
        AppFormatters.formatCents(delta.newTotalInterestProjected!),
        projectedDelta == 0
            ? ''
            : projectedDelta < 0
            ? l10n.monthlyActionDeltaReduced(
                AppFormatters.formatCents(projectedDelta.abs()),
              )
            : l10n.monthlyActionDeltaIncreased(
                AppFormatters.formatCents(projectedDelta),
              ),
      );
    }

    if (delta.hasSavedInterestChange &&
        delta.previousTotalInterestSaved != null &&
        delta.newTotalInterestSaved != null) {
      final savedDelta = delta.savedInterestDelta!;
      return l10n.monthlyActionRecastSavedInterest(
        AppFormatters.formatCents(delta.previousTotalInterestSaved!),
        AppFormatters.formatCents(delta.newTotalInterestSaved!),
        savedDelta == 0
            ? ''
            : savedDelta > 0
            ? l10n.monthlyActionDeltaIncreased(
                AppFormatters.formatCents(savedDelta),
              )
            : l10n.monthlyActionDeltaReduced(
                AppFormatters.formatCents(savedDelta.abs()),
              ),
      );
    }

    return l10n.monthlyActionRecastNeutral;
  }
}

class _CompletedChecklistSection extends StatefulWidget {
  const _CompletedChecklistSection({
    required this.sections,
    required this.submittingIds,
    required this.onCheckOff,
  });

  final List<MonthlyActionSection> sections;
  final Set<String> submittingIds;
  final ValueChanged<MonthlyActionItem> onCheckOff;

  @override
  State<_CompletedChecklistSection> createState() =>
      _CompletedChecklistSectionState();
}

class _CompletedChecklistSectionState
    extends State<_CompletedChecklistSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.sections.fold<int>(
      0,
      (sum, section) => sum + section.items.length,
    );
    final completedCount = widget.sections.fold<int>(
      0,
      (sum, section) =>
          sum + section.items.where((item) => item.isCompleted).length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          key: AppTestKeys.monthlyActionCompletedChecklistToggle,
          color: AppColors.mdSurface,
          padding: const EdgeInsets.all(AppDimensions.md),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Icon(
                LucideIcons.listChecks,
                size: AppDimensions.iconMd,
                color: AppColors.mdPrimary,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  context.l10n.monthlyActionCompletedChecklistTitle(
                    completedCount,
                    totalCount,
                  ),
                  style: AppTextStyles.titleSmall,
                ),
              ),
              Icon(
                _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: AppDimensions.iconMd,
                color: AppColors.mdOnSurfaceVariant,
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppDimensions.sm),
          ...widget.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: _MonthlyActionSectionCard(
                section: section,
                submittingIds: widget.submittingIds,
                onCheckOff: widget.onCheckOff,
              ),
            ),
          ),
        ],
      ],
    );
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
      padding: const EdgeInsets.all(AppDimensions.md),
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
          const SizedBox(height: AppDimensions.sm),
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
    final chipLabel = _statusChipLabel(context, item);
    final proof = item.completionProof;

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
                Text(
                  _actionTitle(context, item),
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  _actionSubtitle(context, item),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  proof == null
                      ? _dueText(context, item)
                      : context.l10n.monthlyActionLoggedProof(
                          AppFormatters.formatCents(proof.amountCents),
                          AppFormatters.formatDate(proof.date),
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
              Tooltip(
                message: item.isCompleted
                    ? context.l10n.monthlyActionLogged
                    : context.l10n.monthlyActionCheckOff,
                child: SizedBox(
                  key: AppTestKeys.monthlyActionCheckOff(item.id),
                  child: InkWell(
                    onTap: item.isCompleted || isSubmitting ? null : onCheckOff,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.isCompleted
                            ? AppColors.mdPrimary
                            : AppColors.mdPrimaryContainer,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Icon(
                        item.isCompleted
                            ? LucideIcons.checkCircle2
                            : LucideIcons.check,
                        size: AppDimensions.iconMd,
                        color: item.isCompleted
                            ? AppColors.mdOnPrimary
                            : AppColors.mdPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmInfoRow extends StatelessWidget {
  const _ConfirmInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mdOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

MonthlyActionItem? _latestProofItem(List<MonthlyActionSection> sections) {
  MonthlyActionItem? latest;
  for (final item in sections.expand((section) => section.items)) {
    if (item.completionProof == null) continue;
    final currentProof = latest?.completionProof;
    if (currentProof == null ||
        item.completionProof!.date.isAfter(currentProof.date)) {
      latest = item;
    }
  }
  return latest;
}

String _debtStatusLabel(BuildContext context, DebtStatus status) {
  return switch (status) {
    DebtStatus.active => context.l10n.debtStatusActive,
    DebtStatus.paidOff => context.l10n.debtStatusPaidOff,
    DebtStatus.archived => context.l10n.debtStatusArchived,
    DebtStatus.paused => context.l10n.debtStatusPaused,
  };
}

String _actionTitle(BuildContext context, MonthlyActionItem item) {
  return item.kind == MonthlyActionKind.minimum
      ? context.l10n.paymentTypeMinimumLabel
      : context.l10n.paymentTypeExtraLabel;
}

String _actionSubtitle(BuildContext context, MonthlyActionItem item) {
  if (item.kind == MonthlyActionKind.minimum) {
    return context.l10n.monthlyActionMinimumSubtitle;
  }
  if (item.priorityRank != null) {
    return context.l10n.monthlyActionExtraPrioritySubtitle(item.priorityRank!);
  }
  return context.l10n.monthlyActionExtraSubtitle;
}

String _dueText(BuildContext context, MonthlyActionItem item) {
  return item.kind == MonthlyActionKind.minimum
      ? context.l10n.monthlyActionDueDate(
          AppFormatters.formatDate(item.dueDate),
        )
      : context.l10n.monthlyActionInMonth(
          AppFormatters.formatMonthYear(item.dueDate),
        );
}

String? _statusChipLabel(BuildContext context, MonthlyActionItem item) {
  if (item.isOverdue) return context.l10n.monthlyActionOverdueChip;
  if (item.isUpcoming) return context.l10n.monthlyActionUpcomingChip;
  if (item.kind == MonthlyActionKind.extra && item.priorityRank != null) {
    return context.l10n.monthlyActionPriorityChip(item.priorityRank!);
  }
  return null;
}

/// Compact icon button with tooltip label for space-efficient action rows.
class _IconButtonWithLabel extends StatelessWidget {
  const _IconButtonWithLabel({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.mdPrimaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppDimensions.iconSm,
                color: AppColors.mdPrimary,
              ),
              const SizedBox(width: AppDimensions.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.mdPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
