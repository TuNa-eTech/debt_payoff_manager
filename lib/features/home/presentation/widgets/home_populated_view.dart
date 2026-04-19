import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/debt_card.dart' as design_system;
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../debts/presentation/debt_ui_utils.dart';

class HomePopulatedView extends StatelessWidget {
  const HomePopulatedView({super.key, required this.debts, required this.plan});

  final List<Debt> debts;
  final Plan? plan;

  @override
  Widget build(BuildContext context) {
    final trackedDebts =
        debts.where((debt) => debt.status != DebtStatus.archived).toList()
          ..sort((a, b) => b.currentBalance.compareTo(a.currentBalance));
    final totalOriginal = trackedDebts.fold<int>(
      0,
      (sum, debt) => sum + debt.originalPrincipal,
    );
    final totalBalance = trackedDebts.fold<int>(
      0,
      (sum, debt) => sum + debt.currentBalance,
    );
    final totalPaid = (totalOriginal - totalBalance).clamp(0, totalOriginal);
    final progress = totalOriginal == 0 ? 0.0 : totalPaid / totalOriginal;
    final paidOffCount = trackedDebts
        .where((debt) => debt.status == DebtStatus.paidOff)
        .length;
    final pausedCount = trackedDebts
        .where((debt) => debt.status == DebtStatus.paused)
        .length;
    final focusDebts = trackedDebts.take(3).toList();

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
                  'Tổng dư nợ hiện tại',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.mdPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  AppFormatters.formatCents(totalBalance),
                  style: AppTextStyles.moneyLarge.copyWith(
                    color: AppColors.mdOnPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: _HeroStat(
                        label: 'Chiến lược',
                        value: plan?.strategy.label ?? 'Snowball',
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: _HeroStat(
                        label: 'Extra / tháng',
                        value: AppFormatters.formatCents(
                          plan?.extraMonthlyAmount ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã trả ${AppFormatters.formatCents(totalPaid)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnPrimary.withValues(alpha: 0.82),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.mdPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  color: AppColors.mdPrimaryContainer,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          AppCard(
            color: AppColors.mdSurfaceContainerLow,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: 'Đang theo dõi',
                    value:
                        '${trackedDebts.where((debt) => debt.currentBalance > 0).length}',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _SummaryStat(
                    label: 'Đã trả xong',
                    value: '$paidOffCount',
                    valueColor: AppColors.mdPrimary,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _SummaryStat(label: 'Tạm dừng', value: '$pausedCount'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          SectionHeader(
            title: 'Khoản nợ cần theo dõi',
            subtitle: 'Danh sách này lấy trực tiếp từ dữ liệu bạn đã lưu.',
            trailingLabel: 'Xem tất cả',
            onTrailingTap: () => context.go(AppRoutes.debts),
          ),
          const SizedBox(height: AppDimensions.md),
          ...focusDebts.map(
            (debt) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: design_system.DebtCard(
                name: debt.name,
                balance: AppFormatters.formatCents(debt.currentBalance),
                apr: AppFormatters.formatApr(double.parse(debt.apr.toString())),
                minPayment: AppFormatters.formatCents(debt.minimumPayment),
                dueDate: debt.status == DebtStatus.paused
                    ? 'Tạm dừng'
                    : 'Ngày ${debt.dueDayOfMonth}',
                state: debt.status == DebtStatus.paidOff
                    ? design_system.DebtCardState.paid
                    : design_system.DebtCardState.normal,
                debtTypeIcon: debtTypeIcon(debt.type),
                onTap: () => context.push(AppRoutes.debtDetailPath(debt.id)),
              ),
            ),
          ),
          if (focusDebts.isEmpty)
            AppCard(
              color: AppColors.mdSurfaceContainerLow,
              child: Text(
                'Hiện chưa có khoản nợ nào cần theo dõi.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          const SizedBox(height: AppDimensions.sectionGap),
          AppCard(
            color: AppColors.mdSurfaceContainerLow,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  size: AppDimensions.iconMd,
                  color: AppColors.mdPrimary,
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timeline chi tiết đang được kết nối',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        'Bạn đã có đủ dữ liệu nền để vào tab Kế hoạch và xem cấu hình hiện tại. Ngày hết nợ và dự phóng chi tiết sẽ xuất hiện khi phần mô phỏng kế hoạch được bật.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mdOnSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      AppButton.tonal(
                        label: 'Mở tab Kế hoạch',
                        icon: LucideIcons.arrowRight,
                        onPressed: () => context.go(AppRoutes.plan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
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

class _VerticalDivider extends StatelessWidget {
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
