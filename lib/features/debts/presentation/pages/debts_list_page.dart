import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  const DebtsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DebtsCubit, DebtsState>(
      listenWhen: (previous, current) =>
          previous.lastActionFeedback != current.lastActionFeedback,
      listener: (context, state) {
        final feedback = state.lastActionFeedback;
        if (feedback == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(feedback.message)),
        );
        context.read<DebtsCubit>().clearActionFeedback();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Các khoản nợ'),
        ),
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
                        label: 'Tất cả',
                        count: state.debts.length,
                        selected: state.filter == DebtsFilter.all,
                        onTap: () =>
                            context.read<DebtsCubit>().setFilter(DebtsFilter.all),
                      ),
                      _FilterChip(
                        label: 'Đang nợ',
                        count: state.activeCount,
                        selected: state.filter == DebtsFilter.active,
                        onTap: () => context
                            .read<DebtsCubit>()
                            .setFilter(DebtsFilter.active),
                      ),
                      _FilterChip(
                        label: 'Đã trả',
                        count: state.paidOffCount,
                        selected: state.filter == DebtsFilter.paidOff,
                        onTap: () => context
                            .read<DebtsCubit>()
                            .setFilter(DebtsFilter.paidOff),
                      ),
                      _FilterChip(
                        label: 'Đã lưu trữ',
                        count: state.archivedCount,
                        selected: state.filter == DebtsFilter.archived,
                        onTap: () => context
                            .read<DebtsCubit>()
                            .setFilter(DebtsFilter.archived),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sectionGap),
                  Text(
                    _sectionTitleForFilter(state.filter),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  if (state.visibleDebts.isEmpty)
                    _EmptyList(filter: state.filter)
                  else
                    ...state.visibleDebts.map(
                      (debt) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.md),
                        child: DebtCard(
                          name: debt.name,
                          subtitle: debtSubtitle(debt),
                          balanceText: debtBalanceText(debt),
                          progress: debtProgress(debt),
                          icon: debtTypeIcon(debt.type),
                          iconColor: debtTypeColor(debt.type),
                          isPaidOff: debt.status == DebtStatus.paidOff ||
                              debt.status == DebtStatus.archived,
                          onTap: () =>
                              context.go(AppRoutes.debtDetailPath(debt.id)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go(AppRoutes.addDebt),
          backgroundColor: AppColors.mdPrimaryContainer,
          foregroundColor: AppColors.mdOnPrimaryContainer,
          elevation: 2,
          icon: const Icon(LucideIcons.plus),
          label: const Text(
            'Thêm nợ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  String _sectionTitleForFilter(DebtsFilter filter) {
    switch (filter) {
      case DebtsFilter.all:
        return 'Tất cả khoản nợ';
      case DebtsFilter.active:
        return 'Khoản nợ đang theo dõi';
      case DebtsFilter.paidOff:
        return 'Khoản nợ đã trả xong';
      case DebtsFilter.archived:
        return 'Khoản nợ đã lưu trữ';
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
              label: 'Tổng dư nợ',
              value: AppFormatters.formatCents(state.totalBalanceCents),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.mdOutlineVariant),
          Expanded(
            child: _SummaryCol(
              label: 'Đang nợ',
              value: '${state.activeCount}',
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.mdOutlineVariant),
          Expanded(
            child: _SummaryCol(
              label: 'Đã trả',
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
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppChip.filter(
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
      child: Text(
        switch (filter) {
          DebtsFilter.all => 'Bạn chưa có khoản nợ nào. Hãy thêm khoản đầu tiên.',
          DebtsFilter.active => 'Hiện không có khoản nợ nào đang theo dõi.',
          DebtsFilter.paidOff => 'Chưa có khoản nợ nào được đánh dấu đã trả xong.',
          DebtsFilter.archived => 'Chưa có khoản nợ nào được lưu trữ.',
        },
        style: AppTextStyles.bodyMedium,
      ),
    );
  }
}
