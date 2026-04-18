import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Filter / Assist / Status chip following the MD3 × Notion design.
///
/// - [AppChip.filter] — Toggleable selection chip (e.g., debt type filters)
/// - [AppChip.assist]  — Action chip (e.g., quick amount presets)
/// - [AppChip.status]  — Read-only informational chip
class AppChip extends StatelessWidget {
  const AppChip._internal({
    super.key,
    required this.label,
    required this.chipVariant,
    this.selected = false,
    this.onTap,
    this.icon,
    this.selectedIcon,
  });

  /// Toggleable filter chip — shown in lists and form selectors.
  const factory AppChip.filter({
    Key? key,
    required String label,
    required bool selected,
    required VoidCallback? onTap,
    IconData? icon,
  }) = _FilterChip;

  /// Action assist chip — tappable, never selected state.
  const factory AppChip.assist({
    Key? key,
    required String label,
    required VoidCallback? onTap,
    IconData? icon,
  }) = _AssistChip;

  /// Read-only informational chip.
  const factory AppChip.status({
    Key? key,
    required String label,
    Color? backgroundColor,
    Color? foregroundColor,
    IconData? icon,
  }) = _StatusChip;

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? selectedIcon;
  // ignore: library_private_types_in_public_api
  final _ChipVariant chipVariant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _colors();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppDimensions.animFast),
        height: AppDimensions.buttonHeightSm,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showIcon)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  selected && selectedIcon != null ? selectedIcon : icon,
                  size: AppDimensions.iconXs,
                  color: fg,
                ),
              ),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }

  bool get _showIcon {
    if (chipVariant == _ChipVariant.filter && selected && selectedIcon != null) return true;
    return icon != null;
  }

  (Color bg, Color fg, Color border) _colors() {
    switch (chipVariant) {
      case _ChipVariant.filter:
        if (selected) {
          return (
            AppColors.mdPrimary,
            AppColors.mdOnPrimary,
            AppColors.mdPrimary,
          );
        }
        return (
          Colors.transparent,
          AppColors.mdOnSurface,
          AppColors.mdOutline,
        );
      case _ChipVariant.assist:
        return (
          AppColors.mdSurfaceContainerLow,
          AppColors.mdOnSurface,
          AppColors.mdOutlineVariant,
        );
      case _ChipVariant.status:
        return (
          AppColors.mdSurfaceContainerLow,
          AppColors.mdOnSurfaceVariant,
          AppColors.mdOutlineVariant,
        );
    }
  }
}

enum _ChipVariant { filter, assist, status }

class _FilterChip extends AppChip {
  const _FilterChip({
    super.key,
    required super.label,
    required super.selected,
    required super.onTap,
    super.icon,
  }) : super._internal(
          chipVariant: _ChipVariant.filter,
          selectedIcon: null,
        );
}

class _AssistChip extends AppChip {
  const _AssistChip({
    super.key,
    required super.label,
    required super.onTap,
    super.icon,
  }) : super._internal(
          chipVariant: _ChipVariant.assist,
          selected: false,
          selectedIcon: null,
        );
}

class _StatusChip extends AppChip {
  const _StatusChip({
    super.key,
    required super.label,
    Color? backgroundColor,
    Color? foregroundColor,
    super.icon,
  }) : super._internal(
          chipVariant: _ChipVariant.status,
          selected: false,
          onTap: null,
          selectedIcon: null,
        );
}
