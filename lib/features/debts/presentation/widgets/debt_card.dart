import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A compact card representing a single debt in the debts list.
///
/// Shows: name, icon, subtitle (due date + APR), balance amount,
/// progress bar, and a contextual trailing indicator.
///
/// Design follows the same pattern as [AppDebtCard] in core/widgets
/// but is feature-specific with more configuration options.
class DebtCard extends StatelessWidget {
  const DebtCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.balanceText,
    required this.progress,
    this.icon = LucideIcons.creditCard,
    this.iconColor,
    this.isOverdue = false,
    this.isPaidOff = false,
    this.onTap,
    this.onLongPress,
  });

  final String name;
  final String subtitle;
  final String balanceText;
  final double progress;
  final IconData icon;
  final Color? iconColor;
  final bool isOverdue;
  final bool isPaidOff;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    // Resolve colors based on state
    final Color containerColor;
    final Color leadBgColor;
    final Color leadIconColor;
    final Color progressColor;
    final Color progressTrackColor;
    final Color titleColor;
    final Color subtitleColor;
    final Color amountColor;

    if (isPaidOff) {
      containerColor = AppColors.mdSurfaceContainerLow;
      leadBgColor = const Color(0xFFC8F5DC);
      leadIconColor = const Color(0xFF1A6B3A);
      progressColor = AppColors.paidGreen;
      progressTrackColor = AppColors.mdSurfaceContainerHighest;
      titleColor = AppColors.mdOnSurface;
      subtitleColor = AppColors.paidGreen;
      amountColor = AppColors.paidGreen;
    } else if (isOverdue) {
      containerColor = AppColors.mdErrorContainer;
      leadBgColor = const Color(0xFFFFBAB4);
      leadIconColor = AppColors.mdError;
      progressColor = AppColors.mdOnErrorContainer;
      progressTrackColor = const Color(0xFFFFBAB4);
      titleColor = AppColors.mdOnErrorContainer;
      subtitleColor = AppColors.mdOnErrorContainer;
      amountColor = AppColors.mdOnErrorContainer;
    } else {
      containerColor = AppColors.mdSurfaceContainerLow;
      leadBgColor = (iconColor ?? AppColors.mdPrimary).withOpacity(0.12);
      leadIconColor = iconColor ?? AppColors.mdPrimary;
      progressColor = AppColors.mdPrimary;
      progressTrackColor = AppColors.mdSurfaceContainerHighest;
      titleColor = AppColors.mdOnSurface;
      subtitleColor = AppColors.mdOnSurfaceVariant;
      amountColor = AppColors.mdOnSurface;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Lead Icon ──
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: leadBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(this.icon, color: leadIconColor, size: 20),
            ),
            const SizedBox(width: 14),

            // ── Body ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.titleSmall.copyWith(color: titleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: subtitleColor, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: progressTrackColor,
                          color: progressColor,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: subtitleColor,
                          fontFamily: 'Roboto Mono',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // ── Trail: Amount + Action ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balanceText,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto Mono',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPaidOff
                        ? AppColors.paidGreen
                        : isOverdue
                            ? AppColors.mdError
                            : AppColors.mdSurfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPaidOff
                        ? LucideIcons.check
                        : isOverdue
                            ? LucideIcons.alertCircle
                            : LucideIcons.chevronRight,
                    size: 16,
                    color: (isPaidOff || isOverdue) ? Colors.white : AppColors.mdOnSurfaceVariant,
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
