import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

class DebtDetailHeroCard extends StatelessWidget {
  const DebtDetailHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.creditCard, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text('Chase Sapphire', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('Thẻ tín dụng', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Số dư hiện tại', style: TextStyle(color: Colors.white.withOpacity(0.66), fontSize: 12)),
          const Text('\$5,200', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700, fontFamily: 'Geist', letterSpacing: -1)),
          Text('Còn lại / Gốc ban đầu \$8,000', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 16),
          
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã trả \$2,800', style: TextStyle(color: Colors.white.withOpacity(0.66), fontSize: 12)),
              const Text('35%', style: TextStyle(color: AppColors.mdPrimaryContainer, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Roboto Mono')),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.35,
            backgroundColor: Colors.white.withOpacity(0.15),
            color: AppColors.mdPrimaryContainer,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lãi suất APR', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      SizedBox(height: 4),
                      Text('19.99%', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phí hàng tháng', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      SizedBox(height: 4),
                      Text('\$64.50', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
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
