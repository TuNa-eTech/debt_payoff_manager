import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lộ trình trả nợ'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.info),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Debt-Free Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                      Text('Ngày hết nợ dự kiến', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.snowflake, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Snowball', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Tháng 8, 2028', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700, fontFamily: 'Geist', letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(LucideIcons.trendingDown, size: 14, color: AppColors.mdPrimaryContainer),
                      const SizedBox(width: 6),
                      Text('Sớm hơn 3 tháng nhờ chiến lược Snowball', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdPrimaryContainer, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withOpacity(0.15), height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildBannerStat('Tổng lãi dự kiến', '\$4,200')),
                      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildBannerStat('Tiết kiệm được', '\$850', isHighlight: true)),
                      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildBannerStat('Trả thêm/tháng', '\$250')),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lộ trình theo tháng', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant, letterSpacing: 0.5)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mdSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.mdOutlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.list, size: 14, color: AppColors.mdOnSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Theo khoản', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Timeline Items
            _buildTimelineItem(
              monthName: 'T5/2026',
              items: [
                _buildTimelineListTile('Chase Sapphire', '\$125', LucideIcons.creditCard, AppColors.mdPrimary),
                _buildTimelineListTile('Student Loan', '\$80', LucideIcons.graduationCap, AppColors.mdSecondary),
                _buildTimelineListTile('Car Loan', '\$320', LucideIcons.car, AppColors.mdTertiary),
                _buildTimelineListTile('Trả thêm Snowball', '\$250', LucideIcons.snowflake, AppColors.mdPrimary, isAction: true),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildTimelineItem(
              monthName: 'T6/2026',
              items: [
                _buildTimelineListTile('Chase Sapphire', '\$125', LucideIcons.creditCard, AppColors.mdPrimary),
                _buildTimelineListTile('Student Loan', '\$80', LucideIcons.graduationCap, AppColors.mdSecondary),
                _buildTimelineListTile('Car Loan', '\$320', LucideIcons.car, AppColors.mdTertiary),
                _buildTimelineListTile('Trả thêm Snowball', '\$250', LucideIcons.snowflake, AppColors.mdPrimary, isAction: true),
              ],
            ),

            const SizedBox(height: 16),
            
            _buildTimelineMilestone(
              monthName: 'T8/2026',
              milestoneTitle: 'Dứt điểm Chase Sapphire!',
              milestoneSubtitle: 'Tiền trả thêm sẽ được cuộn qua khoản vay Student Loan',
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerStat(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: isHighlight ? AppColors.mdPrimaryContainer : Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Roboto Mono')),
      ],
    );
  }

  Widget _buildTimelineItem({required String monthName, required List<Widget> items}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline connector
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.mdPrimaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.mdPrimary, width: 3),
              ),
            ),
            Container(
              width: 2,
              height: 160,
              color: AppColors.mdOutlineVariant,
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(monthName, style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.mdSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mdOutlineVariant),
                ),
                child: Column(
                  children: items,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimelineMilestone({required String monthName, required String milestoneTitle, required String milestoneSubtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline connector
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.mdTertiaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.mdTertiary, width: 3),
              ),
            ),
            Container(
              width: 2,
              height: 80,
              color: AppColors.mdOutlineVariant,
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(monthName, style: AppTextStyles.titleSmall.copyWith(color: AppColors.mdTertiary)),
               const SizedBox(height: 12),
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: AppColors.mdTertiaryContainer,
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Row(
                   children: [
                     const Icon(LucideIcons.partyPopper, color: AppColors.mdTertiary, size: 24),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(milestoneTitle, style: AppTextStyles.titleSmall.copyWith(color: AppColors.mdOnTertiaryContainer)),
                           const SizedBox(height: 4),
                           Text(milestoneSubtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnTertiaryContainer.withOpacity(0.8))),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineListTile(String title, String amount, IconData icon, Color iconColor, {bool isAction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isAction ? iconColor.withOpacity(0.1) : AppColors.mdSurfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: isAction ? iconColor : AppColors.mdOnSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          Text(amount, style: AppTextStyles.titleMedium.copyWith(fontFamily: 'Roboto Mono', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
