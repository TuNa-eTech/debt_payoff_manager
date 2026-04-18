import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/enums/strategy.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import '../../../debts/presentation/debt_ui_utils.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final planRepository = getIt.get<PlanRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch'),
      ),
      body: StreamBuilder<Plan?>(
        stream: planRepository.watchCurrentPlan(),
        builder: (context, planSnapshot) {
          return BlocBuilder<DebtsCubit, DebtsState>(
            builder: (context, debtsState) {
              if (debtsState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final debts = debtsState.debts
                  .where(
                    (debt) =>
                        debt.status != DebtStatus.archived &&
                        debt.currentBalance > 0,
                  )
                  .toList();

              if (debts.isEmpty) {
                return const EmptyState(
                  title: 'Chưa có kế hoạch để hiển thị',
                  subtitle:
                      'Thêm ít nhất một khoản nợ để app lưu cấu hình chiến lược và dựng thứ tự ưu tiên.',
                  icon: LucideIcons.map,
                );
              }

              final plan = planSnapshot.data;
              final orderedDebts = _sortDebtsForPlan(
                debts: debts,
                plan: plan,
              );
              final totalBalance = debts.fold<int>(
                0,
                (sum, debt) => sum + debt.currentBalance,
              );
              final pausedCount = debts
                  .where((debt) => debt.status == DebtStatus.paused)
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
                            'Chiến lược hiện tại',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.mdPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            plan?.strategy.label ?? Strategy.snowball.label,
                            style: AppTextStyles.displaySmall.copyWith(
                              color: AppColors.mdOnPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Row(
                            children: [
                              Expanded(
                                child: _PlanStat(
                                  label: 'Tổng dư nợ',
                                  value: AppFormatters.formatCents(
                                    totalBalance,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.md),
                              Expanded(
                                child: _PlanStat(
                                  label: 'Extra / tháng',
                                  value: AppFormatters.formatCents(
                                    plan?.extraMonthlyAmount ?? 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionGap),
                    AppCard(
                      color: AppColors.mdSurfaceContainerLow,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.info,
                            size: AppDimensions.iconMd,
                            color: AppColors.mdPrimary,
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: Text(
                              'Tab này hiện hiển thị cấu hình kế hoạch và thứ tự ưu tiên thật từ dữ liệu của bạn. Timeline theo tháng, debt-free date và phân rã principal/lãi sẽ xuất hiện khi phần mô phỏng được bật.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.mdOnSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pausedCount > 0) ...[
                      const SizedBox(height: AppDimensions.md),
                      AppCard(
                        color: AppColors.mdSurface,
                        child: Text(
                          '$pausedCount khoản đang ở trạng thái tạm dừng sẽ vẫn nằm trong kế hoạch nhưng không nhận extra payment trong thời gian pause.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mdOnSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.sectionGap),
                    SectionHeader(
                      title: 'Thứ tự ưu tiên hiện tại',
                      subtitle:
                          'Danh sách này phản ánh đúng strategy đang lưu, chưa phải projection theo thời gian.',
                    ),
                    const SizedBox(height: AppDimensions.md),
                    ...orderedDebts.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.md),
                        child: _PriorityCard(
                          rank: entry.key + 1,
                          debt: entry.value,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Debt> _sortDebtsForPlan({
    required List<Debt> debts,
    required Plan? plan,
  }) {
    final sorted = List<Debt>.from(debts);
    final strategy = plan?.strategy ?? Strategy.snowball;

    switch (strategy) {
      case Strategy.snowball:
        sorted.sort((a, b) {
          final balanceCompare = a.currentBalance.compareTo(b.currentBalance);
          if (balanceCompare != 0) return balanceCompare;
          return b.apr.compareTo(a.apr);
        });
      case Strategy.avalanche:
        sorted.sort((a, b) {
          final aprCompare = b.apr.compareTo(a.apr);
          if (aprCompare != 0) return aprCompare;
          return a.currentBalance.compareTo(b.currentBalance);
        });
      case Strategy.custom:
        final order = plan?.customOrder ?? const <String>[];
        final positions = {
          for (var index = 0; index < order.length; index++) order[index]: index,
        };
        sorted.sort((a, b) {
          final aIndex = positions[a.id] ?? 1 << 20;
          final bIndex = positions[b.id] ?? 1 << 20;
          if (aIndex != bIndex) return aIndex.compareTo(bIndex);
          return a.currentBalance.compareTo(b.currentBalance);
        });
    }

    return sorted;
  }
}

class _PlanStat extends StatelessWidget {
  const _PlanStat({
    required this.label,
    required this.value,
  });

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

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
    required this.rank,
    required this.debt,
  });

  final int rank;
  final Debt debt;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.mdSurface,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mdPrimaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mdOnPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.name,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  debtSubtitle(debt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Text(
            AppFormatters.formatCents(debt.currentBalance),
            style: AppTextStyles.moneyXSmall,
          ),
        ],
      ),
    );
  }
}
