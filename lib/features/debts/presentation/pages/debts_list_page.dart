import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_debt_card.dart';

class DebtsListPage extends StatelessWidget {
  const DebtsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Các khoản nợ'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryCol(label: 'Tổng nợ', value: '\$24,700'),
                  Container(width: 1, height: 40, color: AppColors.mdOutlineVariant),
                  _SummaryCol(label: 'Số khoản nợ', value: '4 khoản'),
                  Container(width: 1, height: 40, color: AppColors.mdOutlineVariant),
                  _SummaryCol(label: 'Hết nợ', value: 'T8/2028', valueColor: AppColors.mdPrimary),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Filter Chips (Using SingleChildScrollView for horizontal scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _FilterChip(label: 'Tất cả', isSelected: true, icon: LucideIcons.check),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Đang nợ', isSelected: false),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Đã trả', isSelected: false),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section 1: Active
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đang hoạt động', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant, letterSpacing: 0.5)),
                Text('3 khoản', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant, fontWeight: FontWeight.normal)),
              ],
            ),
            const SizedBox(height: 16),
            
            AppDebtCard(
              name: 'Chase Sapphire',
              subtitle: 'Đến hạn 15/4  ·  APR 19.99%',
              amount: '\$285',
              progress: 0.35,
              icon: LucideIcons.creditCard,
              status: DebtStatus.normal,
              onTap: () => context.go(AppRoutes.debtDetail.replaceAll(':id', '1')),
            ),
            const SizedBox(height: 16),
            
            AppDebtCard(
              name: 'Toyota Car Loan',
              subtitle: 'Đến hạn 20/4  ·  APR 4.5%',
              amount: '\$320',
              progress: 0.46,
              icon: LucideIcons.car,
              status: DebtStatus.normal,
              onTap: () => context.go(AppRoutes.debtDetail.replaceAll(':id', '2')),
            ),
            const SizedBox(height: 16),
            
            AppDebtCard(
              name: 'Student Loan',
              subtitle: '⚠ Quá hạn 3 ngày · APR 5.5%',
              amount: '\$80',
              progress: 0.06,
              icon: LucideIcons.graduationCap,
              status: DebtStatus.overdue,
              onTap: () => context.go(AppRoutes.debtDetail.replaceAll(':id', '3')),
            ),
            
            const SizedBox(height: 32),
            
            // Section 2: Paid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đã trả xong', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant, letterSpacing: 0.5)),
                Text('1 khoản', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant, fontWeight: FontWeight.normal)),
              ],
            ),
            const SizedBox(height: 16),
            
            AppDebtCard(
              name: 'Medical Debt',
              subtitle: 'Đã trả xong · Tháng 2/2026',
              amount: '\$2,000',
              progress: 1.0,
              icon: LucideIcons.heartPulse,
              status: DebtStatus.paid,
              onTap: () => context.go(AppRoutes.debtDetail.replaceAll(':id', '4')),
            ),
            
            const SizedBox(height: 80), // Fab space
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go(AppRoutes.addDebt);
        },
        backgroundColor: AppColors.mdPrimaryContainer,
        foregroundColor: AppColors.mdOnPrimaryContainer,
        elevation: 2,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Thêm nợ', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  const _SummaryCol({required this.label, required this.value, this.valueColor});
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
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdOnSurfaceVariant, letterSpacing: 0.4),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: valueColor ?? AppColors.mdOnSurface,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto Mono',
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, this.icon});
  final String label;
  final bool isSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.mdSecondaryContainer : AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? null : Border.all(color: AppColors.mdOutlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? AppColors.mdOnSecondaryContainer : AppColors.mdOnSurfaceVariant),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.mdOnSecondaryContainer : AppColors.mdOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
