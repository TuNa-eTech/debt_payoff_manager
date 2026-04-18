import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến độ'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Progress Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.mdPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tổng nợ đã trả', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                          const SizedBox(height: 4),
                          const Text('\$4,200', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, fontFamily: 'Geist', letterSpacing: -0.5)),
                        ],
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('28%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Roboto Mono')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.28,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.mdPrimaryContainer,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Còn lại: \$10,800', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                      Text('Mục tiêu: Tháng 8, 2028', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildStatItem('Tháng này', '+\$425', true)),
                  Container(width: 1, height: 36, color: AppColors.mdOutlineVariant),
                  Expanded(child: _buildStatItem('Lãi đã tiết kiệm', '\$120', false)),
                  Container(width: 1, height: 36, color: AppColors.mdOutlineVariant),
                  Expanded(child: _buildStatItem('Streak', '4 tháng', false)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Milestones
            Text('Cột mốc tiếp theo', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mdTertiaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.target, color: AppColors.mdTertiary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đạt 30% tổng nợ', style: AppTextStyles.titleSmall.copyWith(color: AppColors.mdOnTertiaryContainer)),
                        const SizedBox(height: 4),
                        Text('Chỉ còn \$300 nữa để đạt được mốc này!', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnTertiaryContainer.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Per-Debt Progress
            Text('Tiến độ theo khoản', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            _buildDebtProgressItem('Chase Sapphire', 0.85, '\$5,200', AppColors.mdPrimary, AppColors.mdPrimaryContainer, false),
            const SizedBox(height: 8),
            _buildDebtProgressItem('Car Loan', 0.15, '\$6,500', AppColors.mdTertiary, AppColors.mdTertiaryContainer, false),
            const SizedBox(height: 8),
            _buildDebtProgressItem('Student Loan', 0.05, '\$4,800', AppColors.mdError, AppColors.mdErrorContainer, true),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isHighlight) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mdOnSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isHighlight ? AppColors.mdPrimary : AppColors.mdOnSurface, fontFamily: 'Roboto Mono')),
      ],
    );
  }

  Widget _buildDebtProgressItem(String title, double progress, String totalStr, Color color, Color bgColor, bool isWarning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isWarning ? AppColors.mdErrorContainer.withOpacity(0.3) : AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.labelMedium),
              Text('${(progress * 100).toInt()}%', style: AppTextStyles.labelMedium.copyWith(color: color, fontFamily: 'Roboto Mono')),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isWarning ? AppColors.mdErrorContainer : AppColors.mdSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
