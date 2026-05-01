import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
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
enum _StatusBadgeKind { overdue, paid, active, upcoming, custom }

class StatusBadge extends StatelessWidget {
  const StatusBadge._({
    super.key,
    required _StatusBadgeKind kind,
    this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  }) : _kind = kind;

  factory StatusBadge.overdue({Key? key, String? label}) => StatusBadge._(
    key: key,
    kind: _StatusBadgeKind.overdue,
    label: label,
    backgroundColor: AppColors.mdErrorContainer,
    foregroundColor: AppColors.debtRed,
  );

  factory StatusBadge.paid({Key? key, String? label}) => StatusBadge._(
    key: key,
    kind: _StatusBadgeKind.paid,
    label: label,
    backgroundColor: AppColors.mdPrimaryContainer,
    foregroundColor: AppColors.mdPrimary,
  );

  factory StatusBadge.active({Key? key, String? label}) => StatusBadge._(
    key: key,
    kind: _StatusBadgeKind.active,
    label: label,
    backgroundColor: AppColors.mdSurfaceContainerHigh,
    foregroundColor: AppColors.mdOnSurfaceVariant,
  );

  factory StatusBadge.upcoming({Key? key, String? label}) => StatusBadge._(
    key: key,
    kind: _StatusBadgeKind.upcoming,
    label: label,
    backgroundColor: AppColors.warningContainer,
    foregroundColor: AppColors.warning,
  );

  factory StatusBadge.custom({
    Key? key,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) => StatusBadge._(
    key: key,
    kind: _StatusBadgeKind.custom,
    label: label,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
  );

  final _StatusBadgeKind _kind;
  final String? label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel =
        label ??
        switch (_kind) {
          _StatusBadgeKind.overdue => context.l10n.statusBadgeOverdue,
          _StatusBadgeKind.paid => context.l10n.statusBadgePaid,
          _StatusBadgeKind.active => context.l10n.statusBadgeActive,
          _StatusBadgeKind.upcoming => context.l10n.statusBadgeUpcoming,
          _StatusBadgeKind.custom => '',
        };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        effectiveLabel,
        style: AppTextStyles.badge.copyWith(color: foregroundColor),
      ),
    );
  }
}
