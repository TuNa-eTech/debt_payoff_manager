import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_debt_card.dart';

class HomePopulatedView extends StatelessWidget {
  const HomePopulatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.mdPrimary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THÁNG 4 · 2026',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.66),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '🎯 Ngày hết nợ dự kiến',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdPrimaryContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tháng 8, 2028',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.mdOnPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Strategy Badge Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chiến lược Snowball',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdOnPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Hero Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tổng nợ dư', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdPrimaryContainer)),
                            const SizedBox(height: 4),
                            Text('\$14,200', style: AppTextStyles.titleMedium.copyWith(color: AppColors.mdOnPrimary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lãi tiết kiệm', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdPrimaryContainer)),
                            const SizedBox(height: 4),
                            Text('\$1,240', style: AppTextStyles.titleMedium.copyWith(color: AppColors.mdOnPrimary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tiến độ tổng thể', style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withOpacity(0.66))),
                    Text('38%', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdPrimaryContainer, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.38,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: AppColors.mdPrimaryContainer,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📅  Cần trả tháng này',
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mdSecondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$685',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSecondaryContainer, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Debt Cards
          const AppDebtCard(
            name: 'Chase Sapphire',
            subtitle: 'Đến hạn 15/4  ·  APR 19.99%',
            amount: '\$285',
            progress: 0.2,
            icon: LucideIcons.creditCard,
            status: DebtStatus.normal,
          ),
          const SizedBox(height: 16),
          
          const AppDebtCard(
            name: 'Toyota Car Loan',
            subtitle: 'Đã thanh toán · 20/4',
            amount: '\$320',
            progress: 1.0,
            icon: LucideIcons.car,
            status: DebtStatus.paid,
          ),
          const SizedBox(height: 16),
          
          const AppDebtCard(
            name: 'Student Loan',
            subtitle: '⚠ Quá hạn 3 ngày · APR 5.5%',
            amount: '\$80',
            progress: 0.05,
            icon: LucideIcons.graduationCap,
            status: DebtStatus.overdue,
          ),
          
          const SizedBox(height: 24),
          
          // Summary Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.mdSurfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.mdPrimary),
                    const SizedBox(width: 8),
                    Text(
                      '1 / 3 khoản đã trả tháng này',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                    ),
                  ],
                ),
                Text(
                  '33%',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
