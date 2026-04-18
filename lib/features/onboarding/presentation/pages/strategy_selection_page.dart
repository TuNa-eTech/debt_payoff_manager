import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class StrategySelectionPage extends StatefulWidget {
  const StrategySelectionPage({super.key});

  @override
  State<StrategySelectionPage> createState() => _StrategySelectionPageState();
}

class _StrategySelectionPageState extends State<StrategySelectionPage> {
  // 'snowball' or 'avalanche'
  String _selectedStrategy = 'snowball';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chọn chiến lược'),
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
                              'Bước 3/3',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.mdOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 1.0,
                          backgroundColor: AppColors.mdSurfaceContainerHighest,
                          color: AppColors.mdPrimary,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Chọn cách bạn muốn trả nợ.\nSố liệu tính từ dữ liệu thật của bạn.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    
                    // Snowball Card
                    _StrategyCard(
                      title: 'Snowball (Khuyên dùng)',
                      subtitle: 'Trả nợ nhỏ trước để có động lực.',
                      monthToPayOff: 'Thg 12 2026',
                      totalInterest: '\$1,240',
                      badgeText: 'Bạn trả xong sớm nhất!',
                      badgeColor: AppColors.mdPrimaryContainer,
                      badgeTextColor: AppColors.mdOnPrimaryContainer,
                      isSelected: _selectedStrategy == 'snowball',
                      onTap: () => setState(() => _selectedStrategy = 'snowball'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Avalanche Card
                    _StrategyCard(
                      title: 'Avalanche',
                      subtitle: 'Trả nợ ưu tiên lãi cao để tiết kiệm lãi.',
                      monthToPayOff: 'Thg 2 2027',
                      totalInterest: '\$980',
                      badgeText: 'Tiết kiệm được \$260 tiền lãi',
                      badgeColor: AppColors.mdSecondaryContainer,
                      badgeTextColor: AppColors.mdOnSecondaryContainer,
                      isSelected: _selectedStrategy == 'avalanche',
                      onTap: () => setState(() => _selectedStrategy = 'avalanche'),
                    ),
                    
                    const SizedBox(height: 24),
                    Text(
                      'Bạn có thể đổi chiến lược bất kỳ lúc nào sau khi setup.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant),
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
              child: AppButton.filledLg(
                label: _selectedStrategy == 'snowball'
                    ? 'Dùng Snowball — Tiếp tục'
                    : 'Dùng Avalanche — Tiếp tục',
                icon: null,
                trailingIcon: LucideIcons.arrowRight,
                fullWidth: true,
                onPressed: () {
                  context.go(AppRoutes.extraAmount);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrategyCard extends StatelessWidget {
  const _StrategyCard({
    required this.title,
    required this.subtitle,
    required this.monthToPayOff,
    required this.totalInterest,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String monthToPayOff;
  final String totalInterest;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.mdSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.mdPrimary : AppColors.mdOutlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                    color: isSelected ? AppColors.mdPrimary : AppColors.mdOutline,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.mdOutlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sạch nợ vào tháng',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(monthToPayOff, style: AppTextStyles.titleMedium),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tổng lãi',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(totalInterest, style: AppTextStyles.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: badgeColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(LucideIcons.sparkles, size: 16, color: badgeTextColor),
                  const SizedBox(width: 8),
                  Text(
                    badgeText,
                    style: AppTextStyles.labelMedium.copyWith(color: badgeTextColor),
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
