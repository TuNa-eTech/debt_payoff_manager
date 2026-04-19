import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planRepository = getIt.get<PlanRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tiến độ')),
      body: StreamBuilder<Plan?>(
        stream: planRepository.watchCurrentPlan(),
        builder: (context, planSnapshot) {
          return BlocBuilder<DebtsCubit, DebtsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final debts = state.debts
                  .where((debt) => debt.status != DebtStatus.archived)
                  .toList(growable: false);

              if (debts.isEmpty) {
                return const EmptyState(
                  title: 'Chưa có tiến độ để hiển thị',
                  subtitle:
                      'Thêm khoản nợ đầu tiên để app bắt đầu theo dõi mức độ hoàn thành của bạn.',
                  icon: LucideIcons.barChart2,
                );
              }

              final totalOriginal = debts.fold<int>(
                0,
                (sum, debt) => sum + debt.originalPrincipal,
              );
              final totalRemaining = debts.fold<int>(
                0,
                (sum, debt) => sum + debt.currentBalance,
              );
              final totalPaid = (totalOriginal - totalRemaining).clamp(
                0,
                totalOriginal,
              );
              final overallProgress = totalOriginal == 0
                  ? 0.0
                  : totalPaid / totalOriginal;
              final paidOffCount = debts
                  .where((debt) => debt.status == DebtStatus.paidOff)
                  .length;
              final pausedCount = debts
                  .where((debt) => debt.status == DebtStatus.paused)
                  .length;
              final activeCount = debts
                  .where((debt) => debt.status == DebtStatus.active)
                  .length;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH,
                  vertical: AppDimensions.pagePaddingV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppHeroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đã trả được',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.mdPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            AppFormatters.formatCents(totalPaid),
                            style: AppTextStyles.moneyLarge.copyWith(
                              color: AppColors.mdOnPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            'Còn lại ${AppFormatters.formatCents(totalRemaining)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  AppColors.mdOnPrimary.withValues(alpha: 0.82),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tiến độ tổng thể',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.mdOnPrimary.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                              ),
                              Text(
                                '${(overallProgress * 100).round()}%',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.mdPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          LinearProgressIndicator(
                            value: overallProgress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(alpha: 0.18),
                            color: AppColors.mdPrimaryContainer,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (planSnapshot.data != null) ...[
                      const SizedBox(height: AppDimensions.sectionGap),
                      _PlanSummaryCard(plan: planSnapshot.data!),
                    ],
                    const SizedBox(height: AppDimensions.sectionGap),
                    AppCard(
                      color: AppColors.mdSurfaceContainerLow,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProgressStat(
                              label: 'Đang theo dõi',
                              value: '$activeCount',
                            ),
                          ),
                          const _ProgressDivider(),
                          Expanded(
                            child: _ProgressStat(
                              label: 'Đã trả xong',
                              value: '$paidOffCount',
                              valueColor: AppColors.mdPrimary,
                            ),
                          ),
                          const _ProgressDivider(),
                          Expanded(
                            child: _ProgressStat(
                              label: 'Tạm dừng',
                              value: '$pausedCount',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionGap),
                    AppCard(
                      color: AppColors.mdSurfaceContainerLow,
                      child: Text(
                        'Tiến độ ở đây kết hợp cả số dư thực tế và plan summary đã recast. Phần overview trước đây ở Home đã được chuyển về tab này.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.mdOnSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionGap),
                    const SectionHeader(
                      title: 'Tiến độ theo khoản',
                      subtitle:
                          'Dựa trên số dư hiện tại so với gốc ban đầu của từng khoản.',
                    ),
                    const SizedBox(height: AppDimensions.md),
                    ...debts.map(
                      (debt) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.md),
                        child: _DebtProgressCard(debt: debt),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.mdSurfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Plan summary', style: AppTextStyles.titleSmall),
              const Spacer(),
              AppChip.status(label: plan.strategy.label, icon: LucideIcons.map),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _ProgressStat(
                  label: 'Debt-free date',
                  value: plan.projectedDebtFreeDate == null
                      ? 'Đang recast'
                      : AppFormatters.formatShortMonthYear(
                          plan.projectedDebtFreeDate!,
                        ),
                  valueColor: AppColors.mdPrimary,
                ),
              ),
              Expanded(
                child: _ProgressStat(
                  label: 'Extra / tháng',
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
                  label: 'Projected interest',
                  value: AppFormatters.formatCents(
                    plan.totalInterestProjected ?? 0,
                  ),
                ),
              ),
              Expanded(
                child: _ProgressStat(
                  label: 'Saved vs minimum',
                  value: AppFormatters.formatCents(plan.totalInterestSaved ?? 0),
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
    final paidAmount =
        (debt.originalPrincipal - debt.currentBalance).clamp(0, debt.originalPrincipal);
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
              Expanded(child: Text(debt.name, style: AppTextStyles.titleMedium)),
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
                ? 'Khoản nợ này đã được đánh dấu trả xong.'
                : isPaused
                    ? 'Khoản nợ này đang tạm dừng.'
                    : 'Còn lại ${AppFormatters.formatCents(debt.currentBalance)} trên gốc ${AppFormatters.formatCents(debt.originalPrincipal)}',
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
