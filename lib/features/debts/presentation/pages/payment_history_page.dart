import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử thanh toán'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.slidersHorizontal),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: AppColors.mdSurfaceContainerLow,
              child: Row(
                children: [
                  Expanded(
                    child: _buildStat('Tổng đã trả', '\$4,200', AppColors.mdOnSurface),
                  ),
                  Container(width: 1, height: 36, color: AppColors.mdOutlineVariant),
                  Expanded(
                    child: _buildStat('Năm nay', '\$1,500', AppColors.mdPrimary),
                  ),
                  Container(width: 1, height: 36, color: AppColors.mdOutlineVariant),
                  Expanded(
                    child: _buildStat('Lần cuối', '15/4', AppColors.mdOnSurface),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('Chase Sapphire', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Tất cả loại', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Năm 2026', false),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMonthSection('Tháng 4/2026', [
                  _buildPaymentItem('Thanh toán minimum', '15 thg 4', '-\$125', 'Minimum', LucideIcons.check, AppColors.mdPrimary, AppColors.mdPrimaryContainer),
                  _buildPaymentItem('Trả thêm — Tax refund', '2 thg 4', '-\$500', 'Lump-sum', LucideIcons.zap, AppColors.mdTertiary, AppColors.mdTertiaryContainer),
                ]),
                const SizedBox(height: 24),
                _buildMonthSection('Tháng 3/2026', [
                  _buildPaymentItem('Thanh toán minimum', '15 thg 3', '-\$125', 'Minimum', LucideIcons.check, AppColors.mdPrimary, AppColors.mdPrimaryContainer),
                  _buildPaymentItem('Extra payment', '10 thg 3', '-\$50', 'Extra', LucideIcons.trendingDown, AppColors.mdSecondary, AppColors.mdSecondaryContainer),
                ]),
                
                const SizedBox(height: 32),
                
                // Load more button
                Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.mdSurface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.mdOutlineVariant),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.chevronDown, size: 16, color: AppColors.mdOnSurfaceVariant),
                      SizedBox(width: 8),
                      Text('Xem thêm · 3 tháng trước', style: TextStyle(color: AppColors.mdOnSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mdOnSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor, fontFamily: 'Roboto Mono')),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.mdSecondaryContainer : AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
        border: isSelected ? null : Border.all(color: AppColors.mdOutlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.mdOnSecondaryContainer : AppColors.mdOnSurfaceVariant,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.mdSurfaceContainerLow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Text(month, style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.mdSurface,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border.all(color: AppColors.mdSurfaceContainerLow, width: 2),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Container(height: 1, color: AppColors.mdOutlineVariant, margin: const EdgeInsets.symmetric(horizontal: 16)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(
    String title,
    String date,
    String amount,
    String type,
    IconData icon,
    Color iconColor,
    Color iconBgColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: AppColors.mdOnSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTextStyles.titleMedium.copyWith(color: iconColor, fontWeight: FontWeight.w600, fontFamily: 'Roboto Mono')),
              const SizedBox(height: 2),
              Text(type, style: const TextStyle(color: AppColors.mdOnSurfaceVariant, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
