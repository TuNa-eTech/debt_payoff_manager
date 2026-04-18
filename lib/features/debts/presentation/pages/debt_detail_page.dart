import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/debt_detail_hero_card.dart';
import '../widgets/debt_info_row.dart';
import '../widgets/debt_options_sheet.dart';
import '../widgets/debt_payment_item.dart';

class DebtDetailPage extends StatelessWidget {
  const DebtDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết khoản nợ'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.moreVertical),
            onPressed: () {
              DebtOptionsSheet.show(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Card
            const DebtDetailHeroCard(),
            
            const SizedBox(height: 24),
            
            // Key Info Section
            Container(
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text('Thông tin thanh toán', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Container(height: 1, color: AppColors.mdOutlineVariant),
                  const DebtInfoRow(icon: LucideIcons.calendarClock, label: 'Thanh toán tối thiểu', value: '\$125 / tháng'),
                  Container(height: 1, color: AppColors.mdOutlineVariant),
                  const DebtInfoRow(icon: LucideIcons.calendarDays, label: 'Ngày thanh toán', value: 'Ngày 15 hàng tháng'),
                  Container(height: 1, color: AppColors.mdOutlineVariant),
                  const DebtInfoRow(icon: LucideIcons.target, label: 'Kế hoạch trả (Snowball)', value: '\$160 / tháng', valueColor: AppColors.mdPrimary),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Recent Payments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lịch sử gần đây', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant, letterSpacing: 0.5)),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.mdPrimary,
                  ),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            const DebtPaymentItem(
              icon: LucideIcons.check,
              iconColor: AppColors.mdOnPrimaryContainer,
              iconBgColor: AppColors.mdPrimaryContainer,
              title: 'Thanh toán minimum',
              date: '15 tháng 4, 2026',
              amount: '-\$125',
              amountColor: AppColors.mdOnSurface,
              type: 'Minimum',
            ),
            const SizedBox(height: 12),
            const DebtPaymentItem(
              icon: LucideIcons.zap,
              iconColor: AppColors.mdTertiary,
              iconBgColor: AppColors.mdTertiaryContainer,
              title: 'Trả thêm — Tax refund',
              date: '2 tháng 4, 2026',
              amount: '-\$500',
              amountColor: AppColors.mdTertiary,
              type: 'Lump-sum',
            ),
            
            const SizedBox(height: 100), // FAB space
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FloatingActionButton.extended(
            onPressed: () {},
            elevation: 0,
            backgroundColor: AppColors.mdPrimary,
            foregroundColor: AppColors.mdOnPrimary,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Thêm thanh toán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

