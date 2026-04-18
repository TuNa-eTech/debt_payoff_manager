import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Generic card container with whisper border and optional tap handling.
///
/// Use this as the base for all card-like surfaces in the app.
/// For debt-specific cards, prefer [DebtCard].
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.elevation = 0,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double? borderRadius;
  final double elevation;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDimensions.radiusLg;
    final effectiveBorderColor = borderColor ?? AppColors.whisperBorder;
    final effectiveColor = color ?? AppColors.mdSurface;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: effectiveBorderColor, width: borderWidth),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: Offset(0, elevation * 2),
                  blurRadius: elevation * 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            splashColor: AppColors.mdPrimary.withValues(alpha: 0.05),
            highlightColor: AppColors.mdPrimary.withValues(alpha: 0.03),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Hero card variant — Forest Green fill, for summary/AHA moment cards.
class AppHeroCard extends StatelessWidget {
  const AppHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.lg),
    this.borderRadius = AppDimensions.radius2xl,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mdPrimary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Section label row: title + optional "See all" / trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.titleSmall),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall,
                ),
            ],
          ),
        ),
        if (trailingLabel != null && onTrailingTap != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: AppDimensions.xs,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              trailingLabel!,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.mdPrimary,
              ),
            ),
          ),
      ],
    );
  }
}
