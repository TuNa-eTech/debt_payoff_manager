import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum DebtStatus { normal, paid, overdue }

class AppDebtCard extends StatelessWidget {
  const AppDebtCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.progress,
    required this.icon,
    required this.status,
    this.onTap,
  });

  final String name;
  final String subtitle;
  final String amount;
  final double progress;
  final IconData icon;
  final DebtStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color containerColor;
    Color leadBgColor;
    Color leadIconColor;
    Color fabColor;
    Color textColor = AppColors.mdOnSurface;
    Color subTextColor = AppColors.mdOnSurfaceVariant;
    Color trackColor;

    switch (status) {
      case DebtStatus.normal:
        containerColor = AppColors.mdSurfaceContainerLow;
        leadBgColor = AppColors.mdPrimaryContainer;
        leadIconColor = AppColors.mdOnPrimaryContainer;
        fabColor = AppColors.mdSurfaceContainerHighest;
        trackColor = AppColors.mdSurfaceContainerHighest;
        break;
      case DebtStatus.paid:
        containerColor = AppColors.mdSurfaceContainerLow;
        leadBgColor = const Color(0xFFC8F5DC);
        leadIconColor = const Color(0xFF1A6B3A);
        fabColor = const Color(0xFF1A6B3A);
        subTextColor = const Color(0xFF1A6B3A);
        trackColor = AppColors.mdSurfaceContainerHighest;
        break;
      case DebtStatus.overdue:
        containerColor = AppColors.mdErrorContainer;
        leadBgColor = const Color(0xFFFFBAB4);
        leadIconColor = AppColors.mdError;
        fabColor = AppColors.mdError;
        textColor = AppColors.mdOnErrorContainer;
        subTextColor = AppColors.mdOnErrorContainer;
        trackColor = const Color(0xFFFFBAB4);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lead Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: leadBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: leadIconColor, size: 20),
            ),
            const SizedBox(width: 16),
            
            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.titleSmall.copyWith(color: textColor)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: subTextColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: trackColor,
                    color: status == DebtStatus.paid ? leadIconColor : (status == DebtStatus.overdue ? AppColors.mdOnErrorContainer : AppColors.mdPrimary),
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Trail
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: status == DebtStatus.overdue ? textColor : AppColors.mdOnSurface,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto Mono',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: fabColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status == DebtStatus.paid ? LucideIcons.check : (status == DebtStatus.normal ? LucideIcons.plus : LucideIcons.alertCircle),
                    size: 16,
                    color: status == DebtStatus.normal ? AppColors.mdOnSurface : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
