import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Status badge pill for debt items.
///
/// Usage:
/// ```dart
/// StatusBadge.overdue()
/// StatusBadge.paid()
/// StatusBadge.active(label: '18% APR')
/// StatusBadge.upcoming()
/// ```
class StatusBadge extends StatelessWidget {
  const StatusBadge._({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  factory StatusBadge.overdue({Key? key}) => StatusBadge._(
        key: key,
        label: 'QUÁ HẠN',
        backgroundColor: AppColors.mdErrorContainer,
        foregroundColor: AppColors.debtRed,
      );

  factory StatusBadge.paid({Key? key}) => StatusBadge._(
        key: key,
        label: 'ĐÃ TRẢ',
        backgroundColor: AppColors.mdPrimaryContainer,
        foregroundColor: AppColors.mdPrimary,
      );

  factory StatusBadge.active({Key? key, String? label}) => StatusBadge._(
        key: key,
        label: label ?? 'ĐANG TRẢ',
        backgroundColor: AppColors.mdSurfaceContainerHigh,
        foregroundColor: AppColors.mdOnSurfaceVariant,
      );

  factory StatusBadge.upcoming({Key? key}) => StatusBadge._(
        key: key,
        label: 'SẮP ĐẾN HẠN',
        backgroundColor: AppColors.warningContainer,
        foregroundColor: AppColors.warning,
      );

  factory StatusBadge.custom({
    Key? key,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) =>
      StatusBadge._(
        key: key,
        label: label,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      );

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: foregroundColor),
      ),
    );
  }
}
