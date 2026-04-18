import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Reusable empty state widget matching the MD3 × Notion design system.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = LucideIcons.inbox,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconXl,
                color: AppColors.mdOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            Text(
              title,
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.sm),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.xl),
              AppButton.filled(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
              ),
            ],

            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: AppDimensions.sm),
              AppButton.text(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
