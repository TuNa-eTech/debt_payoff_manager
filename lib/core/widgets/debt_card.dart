import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'status_badge.dart';

/// Debt state indicator used to style the card.
enum DebtCardState { normal, overdue, paid }

/// Reusable debt card matching the design system prototype.
///
/// Example:
/// ```dart
/// DebtCard(
///   name: 'Chase Sapphire',
///   balance: '$4,800',
///   apr: '18%',
///   minPayment: '$120/tháng',
///   state: DebtCardState.normal,
///   onTap: () => context.push('/debt/chase'),
/// )
/// ```
class DebtCard extends StatelessWidget {
  const DebtCard({
    super.key,
    required this.name,
    required this.balance,
    this.apr,
    this.minPayment,
    this.dueDate,
    this.state = DebtCardState.normal,
    this.onTap,
    this.onMoreTap,
    this.debtTypeIcon = LucideIcons.creditCard,
  });

  final String name;
  final String balance;
  final String? apr;
  final String? minPayment;
  final String? dueDate;
  final DebtCardState state;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final IconData debtTypeIcon;

  @override
  Widget build(BuildContext context) {
    final (bgColor, borderColor, textColor) = _stateColors();

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        splashColor: AppColors.mdPrimary.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header row ──
              Row(
                children: [
                  Icon(debtTypeIcon, size: AppDimensions.iconMd, color: textColor),
                  const Spacer(),
                  if (apr != null)
                    _AprBadge(label: apr!, state: state),
                  if (onMoreTap != null) ...[
                    const SizedBox(width: 4),
                    _MoreButton(onTap: onMoreTap!),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.sm),

              // ── Debt name ──
              Text(
                name,
                style: AppTextStyles.titleMedium.copyWith(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDimensions.xs),

              // ── Balance + status badge ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      balance,
                      style: AppTextStyles.moneyXSmall.copyWith(color: textColor),
                    ),
                  ),
                  _StateBadge(state: state),
                ],
              ),

              // ── Optional details row ──
              if (minPayment != null || dueDate != null) ...[
                const SizedBox(height: AppDimensions.sm),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    if (minPayment != null)
                      Expanded(
                        child: _DetailItem(
                          icon: LucideIcons.arrowDownCircle,
                          label: 'Tối thiểu',
                          value: minPayment!,
                          color: AppColors.mdOnSurfaceVariant,
                        ),
                      ),
                    if (dueDate != null)
                      Expanded(
                        child: _DetailItem(
                          icon: LucideIcons.calendar,
                          label: 'Đến hạn',
                          value: dueDate!,
                          color: state == DebtCardState.overdue
                              ? AppColors.debtRed
                              : AppColors.mdOnSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (Color bg, Color border, Color text) _stateColors() {
    switch (state) {
      case DebtCardState.overdue:
        return (
          AppColors.mdErrorContainer,
          AppColors.mdError.withValues(alpha: 0.5),
          AppColors.debtRed,
        );
      case DebtCardState.paid:
        return (
          AppColors.mdSurfaceContainerLow,
          AppColors.mdOutlineVariant,
          AppColors.mdOnSurfaceVariant,
        );
      case DebtCardState.normal:
        return (
          AppColors.mdSurface,
          AppColors.mdOutlineVariant,
          AppColors.mdOnSurface,
        );
    }
  }
}

class _AprBadge extends StatelessWidget {
  const _AprBadge({required this.label, required this.state});
  final String label;
  final DebtCardState state;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = state == DebtCardState.overdue
        ? (AppColors.mdError.withValues(alpha: 0.15), AppColors.debtRed)
        : (AppColors.mdPrimaryContainer, AppColors.mdPrimary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: fg),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});
  final DebtCardState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      DebtCardState.overdue => StatusBadge.overdue(),
      DebtCardState.paid => StatusBadge.paid(),
      DebtCardState.normal => const SizedBox.shrink(),
    };
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: const Icon(
          LucideIcons.moreHorizontal,
          size: AppDimensions.iconMd,
          color: AppColors.mdOnSurfaceVariant,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconXs, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            Text(value,
                style: AppTextStyles.labelMedium.copyWith(color: color)),
          ],
        ),
      ],
    );
  }
}
