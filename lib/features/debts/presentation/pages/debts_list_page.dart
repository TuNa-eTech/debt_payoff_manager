import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../cubit/debts_cubit.dart';
import '../../cubit/debts_state.dart';
import '../debt_ui_utils.dart';
import '../widgets/debt_card.dart';

class DebtsListPage extends StatelessWidget {
  const DebtsListPage({super.key, this.referenceDate});

  final DateTime? referenceDate;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DebtsCubit, DebtsState>(
      listenWhen: (previous, current) =>
          previous.lastActionFeedback != current.lastActionFeedback,
      listener: (context, state) {
        final feedback = state.lastActionFeedback;
        if (feedback == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(feedback.message)));
        context.read<DebtsCubit>().clearActionFeedback();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.debtsListTitle)),
        body: BlocBuilder<DebtsCubit, DebtsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
                vertical: AppDimensions.pagePaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryCard(state: state),
                  const SizedBox(height: AppDimensions.sectionGap),
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: [
                      _FilterChip(
                        label: context.l10n.debtsListFilterAll,
                        count: state.debts.length,
                        selected: state.filter == DebtsFilter.all,
                        onTap: () => context.read<DebtsCubit>().setFilter(
                          DebtsFilter.all,
                        ),
                      ),
                      _FilterChip(
                        label: context.l10n.debtsListFilterActive,
                        count: state.activeCount,
                        selected: state.filter == DebtsFilter.active,
                        onTap: () => context.read<DebtsCubit>().setFilter(
                          DebtsFilter.active,
                        ),
                      ),
                      _FilterChip(
                        chipKey: AppTestKeys.debtsFilterPaidOff,
                        label: context.l10n.debtsListFilterPaid,
                        count: state.paidOffCount,
                        selected: state.filter == DebtsFilter.paidOff,
                        onTap: () => context.read<DebtsCubit>().setFilter(
                          DebtsFilter.paidOff,
                        ),
                      ),
                      _FilterChip(
                        chipKey: AppTestKeys.debtsFilterArchived,
                        label: context.l10n.debtsListFilterArchived,
                        count: state.archivedCount,
                        selected: state.filter == DebtsFilter.archived,
                        onTap: () => context.read<DebtsCubit>().setFilter(
                          DebtsFilter.archived,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sectionGap),
                  Text(
                    _sectionTitleForFilter(context, state.filter),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  if (state.visibleDebts.isEmpty)
                    _EmptyList(filter: state.filter)
                  else
                    ...state.visibleDebts.map((debt) {
                      final isPaidOff =
                          debt.status == DebtStatus.paidOff ||
                          debt.status == DebtStatus.archived;
                      final isOverdueDebt = isDebtOverdue(
                        debt,
                        now: referenceDate,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.md,
                        ),
                        child: SizedBox(
                          key: AppTestKeys.debtCard(debt.id),
                          child: DebtCard(
                            name: debt.name,
                            subtitle: debtSubtitle(debt, now: referenceDate),
                            balanceText: debtBalanceText(debt),
                            progress: debtProgress(debt),
                            icon: debtTypeIcon(debt.type),
                            iconColor: debtTypeColor(debt.type),
                            isOverdue: isOverdueDebt,
                            isPaidOff: isPaidOff,
                            onTap: () =>
                                context.push(AppRoutes.debtDetailPath(debt.id)),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: AppTestKeys.debtsAddFab,
          onPressed: () => context.push(AppRoutes.addDebt),
          backgroundColor: AppColors.mdPrimaryContainer,
          foregroundColor: AppColors.mdOnPrimaryContainer,
          elevation: 2,
          icon: const Icon(LucideIcons.plus),
          label: Text(
            context.l10n.commonAddDebt,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  String _sectionTitleForFilter(BuildContext context, DebtsFilter filter) {
    switch (filter) {
      case DebtsFilter.all:
        return context.l10n.debtsListSectionAll;
      case DebtsFilter.active:
        return context.l10n.debtsListSectionActive;
      case DebtsFilter.paidOff:
        return context.l10n.debtsListSectionPaidOff;
      case DebtsFilter.archived:
        return context.l10n.debtsListSectionArchived;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final DebtsState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCol(
              label: context.l10n.commonTotalDebt,
              value: AppFormatters.formatCents(state.totalBalanceCents),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.mdOutlineVariant),
          Expanded(
            child: _SummaryCol(
              label: context.l10n.debtsListFilterActive,
              value: '${state.activeCount}',
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.mdOutlineVariant),
          Expanded(
            child: _SummaryCol(
              label: context.l10n.debtsListFilterPaid,
              value: '${state.paidOffCount}',
              valueColor: AppColors.mdPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  const _SummaryCol({
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
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: valueColor ?? AppColors.mdOnSurface,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto Mono',
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.chipKey,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Key? chipKey;

  @override
  Widget build(BuildContext context) {
    return AppChip.filter(
      key: chipKey,
      label: '$label ($count)',
      selected: selected,
      onTap: onTap,
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.filter});

  final DebtsFilter filter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.mdOutlineVariant),
      ),
      child: Text(switch (filter) {
        DebtsFilter.all => context.l10n.debtsListEmptyAll,
        DebtsFilter.active => context.l10n.debtsListEmptyActive,
        DebtsFilter.paidOff => context.l10n.debtsListEmptyPaidOff,
        DebtsFilter.archived => context.l10n.debtsListEmptyArchived,
      }, style: AppTextStyles.bodyMedium),
    );
  }
}
