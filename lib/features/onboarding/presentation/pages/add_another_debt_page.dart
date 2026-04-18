import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class AddAnotherDebtPage extends StatelessWidget {
  const AddAnotherDebtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Danh sách nợ (2)'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bước 2/3',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.mdOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.66,
                          backgroundColor: AppColors.mdSurfaceContainerHighest,
                          color: AppColors.mdPrimary,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Added Debts mock list
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thẻ tín dụng Chase', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            '\$2,450.00',
                            style: AppTextStyles.moneyLarge.copyWith(color: AppColors.debtRed),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lãi suất: 22.4% • Trả tối thiểu: \$75.00',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vay sinh viên', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            '\$14,200.00',
                            style: AppTextStyles.moneyLarge.copyWith(color: AppColors.debtRed),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lãi suất: 6.8% • Trả tối thiểu: \$210.00',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.mdSurface,
                border: Border(
                  top: BorderSide(color: AppColors.mdOutlineVariant, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.filledLg(
                    label: 'Xem kế hoạch của tôi',
                    icon: null,
                    trailingIcon: LucideIcons.arrowRight,
                    fullWidth: true,
                    onPressed: () {
                      context.go(AppRoutes.strategySelection);
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton.outlined(
                    label: 'Thêm khoản nợ khác',
                    fullWidth: true,
                    onPressed: () {
                      context.go(AppRoutes.debtEntry); // In real app, push or clear state
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

