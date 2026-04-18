import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DebtInfoRow extends StatelessWidget {
  const DebtInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.mdOnSurfaceVariant),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant)),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: valueColor ?? AppColors.mdOnSurface,
              fontFamily: 'Roboto Mono',
            ),
          ),
        ],
      ),
    );
  }
}
