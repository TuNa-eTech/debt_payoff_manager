import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Versatile button widget following the MD3 × Notion design system.
///
/// Variants:
/// - [AppButton.filled]    — Primary CTA (Forest Green pill, 48px)
/// - [AppButton.filledLg]  — Large CTA (56px, full-width CTAs on forms)
/// - [AppButton.tonal]     — Secondary action (primary container tint)
/// - [AppButton.outlined]  — Ghost / tertiary (outline border)
/// - [AppButton.text]      — Inline text action
/// - [AppButton.error]     — Destructive action (error container)
///
/// All variants support [loading], [icon], [trailingIcon], [disabled].
class AppButton extends StatelessWidget {
  const AppButton._internal({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    required this.variant,
    this.height = AppDimensions.buttonHeight,
  });

  /// Primary filled CTA — Forest Green, pill shape.
  const factory AppButton.filled({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool loading,
    bool fullWidth,
  }) = _FilledButton;

  /// Large filled CTA (56px) — for bottom-of-screen primary actions.
  const factory AppButton.filledLg({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool loading,
    bool fullWidth,
  }) = _FilledLgButton;

  /// Tonal button — primaryContainer background, for secondary actions.
  const factory AppButton.tonal({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading,
    bool fullWidth,
  }) = _TonalButton;

  /// Outlined button — ghost style for tertiary actions.
  const factory AppButton.outlined({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading,
    bool fullWidth,
  }) = _OutlinedButton;

  /// Text button — minimal ink, for inline actions.
  const factory AppButton.text({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) = _TextButton;

  /// Error/destructive button — errorContainer fill.
  const factory AppButton.error({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading,
    bool fullWidth,
  }) = _ErrorButton;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;
  // ignore: library_private_types_in_public_api
  final _ButtonVariant variant;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final effectiveCallback = loading ? null : onPressed;

    switch (variant) {
      case _ButtonVariant.filled:
        return FilledButton(
          onPressed: effectiveCallback,
          style: _filledStyle(),
          child: _buildContent(AppColors.mdOnPrimary),
        );
      case _ButtonVariant.tonal:
        return FilledButton.tonal(
          onPressed: effectiveCallback,
          style: _tonalStyle(),
          child: _buildContent(AppColors.mdOnPrimaryContainer),
        );
      case _ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: effectiveCallback,
          child: _buildContent(AppColors.mdOnSurface),
        );
      case _ButtonVariant.text:
        return TextButton(
          onPressed: effectiveCallback,
          child: _buildContent(AppColors.mdPrimary),
        );
      case _ButtonVariant.error:
        return FilledButton(
          onPressed: effectiveCallback,
          style: _errorStyle(),
          child: _buildContent(AppColors.debtRed),
        );
    }
  }

  Widget _buildContent(Color contentColor) {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: contentColor,
        ),
      );
    }
    final children = <Widget>[
      if (icon != null) ...[
        Icon(icon, size: AppDimensions.iconMd, color: contentColor),
        const SizedBox(width: 8),
      ],
      Text(label, style: AppTextStyles.labelLarge.copyWith(color: contentColor)),
      if (trailingIcon != null) ...[
        const SizedBox(width: 8),
        Icon(trailingIcon, size: AppDimensions.iconMd, color: contentColor),
      ],
    ];
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  ButtonStyle _filledStyle() => FilledButton.styleFrom(
        backgroundColor: AppColors.mdPrimary,
        foregroundColor: AppColors.mdOnPrimary,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      );

  ButtonStyle _tonalStyle() => FilledButton.styleFrom(
        backgroundColor: AppColors.mdPrimaryContainer,
        foregroundColor: AppColors.mdOnPrimaryContainer,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      );

  ButtonStyle _errorStyle() => FilledButton.styleFrom(
        backgroundColor: AppColors.mdErrorContainer,
        foregroundColor: AppColors.debtRed,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      );
}

enum _ButtonVariant { filled, tonal, outlined, text, error }

// ── Concrete factory subclasses ──
class _FilledButton extends AppButton {
  const _FilledButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.trailingIcon,
    super.loading = false,
    super.fullWidth = false,
  }) : super._internal(
          variant: _ButtonVariant.filled,
          height: AppDimensions.buttonHeight,
        );
}

class _FilledLgButton extends AppButton {
  const _FilledLgButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.trailingIcon,
    super.loading = false,
    super.fullWidth = false,
  }) : super._internal(
          variant: _ButtonVariant.filled,
          height: AppDimensions.buttonHeightLg,
        );
}

class _TonalButton extends AppButton {
  const _TonalButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.loading = false,
    super.fullWidth = false,
  }) : super._internal(
          variant: _ButtonVariant.tonal,
          height: AppDimensions.buttonHeight,
        );
}

class _OutlinedButton extends AppButton {
  const _OutlinedButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.loading = false,
    super.fullWidth = false,
  }) : super._internal(
          variant: _ButtonVariant.outlined,
          height: AppDimensions.buttonHeight,
        );
}

class _TextButton extends AppButton {
  const _TextButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
  }) : super._internal(
          variant: _ButtonVariant.text,
          height: 36,
        );
}

class _ErrorButton extends AppButton {
  const _ErrorButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.loading = false,
    super.fullWidth = false,
  }) : super._internal(
          variant: _ButtonVariant.error,
          height: AppDimensions.buttonHeight,
        );
}
