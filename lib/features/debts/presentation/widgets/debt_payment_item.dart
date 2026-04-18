import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DebtPaymentItem extends StatelessWidget {
  const DebtPaymentItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.date,
    required this.amount,
    required this.amountColor,
    required this.type,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String date;
  final String amount;
  final Color amountColor;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mdSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
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
                Text(date, style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTextStyles.titleMedium.copyWith(color: amountColor, fontWeight: FontWeight.w600, fontFamily: 'Roboto Mono')),
              const SizedBox(height: 2),
              Text(type, style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
