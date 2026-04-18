import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// App text field with floating label, following the MD3 × Notion design.
///
/// Supports:
/// - Floating label pattern
/// - Prefix / suffix icon
/// - Helper text and error text
/// - Read-only mode
/// - Currency input mode (right-aligned, numeric keyboard)
///
/// Example:
/// ```dart
/// AppTextField(
///   label: 'Tên khoản nợ',
///   controller: _nameController,
///   required: true,
///   prefixIcon: LucideIcons.creditCard,
/// )
/// AppTextField.currency(
///   label: 'Số dư còn lại',
///   controller: _balanceController,
/// )
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.required = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.obscureText = false,
  }) : _isCurrency = false,
       _isPercentage = false;

  const AppTextField._numeric({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.required = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    bool isCurrency = false,
  })  : _isCurrency = isCurrency,
        _isPercentage = !isCurrency,
        hint = null,
        textInputAction = TextInputAction.done,
        maxLines = 1,
        textAlign = TextAlign.end,
        onSuffixTap = null,
        keyboardType = null,
        inputFormatters = null,
        obscureText = false;

  /// Currency variant — right-aligned, numeric keyboard, dollar prefix.
  factory AppTextField.currency({
    Key? key,
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? helperText,
    String? errorText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool required = false,
    bool readOnly = false,
    bool enabled = true,
    bool autofocus = false,
  }) =>
      AppTextField._numeric(
        key: key,
        label: label,
        controller: controller,
        focusNode: focusNode,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: null,
        suffixIcon: null,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        required: required,
        readOnly: readOnly,
        enabled: enabled,
        autofocus: autofocus,
        isCurrency: true,
      );

  /// Percentage variant — right-aligned, numeric keyboard, percent suffix.
  factory AppTextField.percentage({
    Key? key,
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? helperText,
    String? errorText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool required = false,
    bool readOnly = false,
    bool enabled = true,
    bool autofocus = false,
  }) =>
      AppTextField._numeric(
        key: key,
        label: label,
        controller: controller,
        focusNode: focusNode,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: null,
        suffixIcon: null,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        required: required,
        readOnly: readOnly,
        enabled: enabled,
        autofocus: autofocus,
        isCurrency: false,
      );

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool required;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final TextAlign textAlign;
  final bool autofocus;
  final bool obscureText;
  final bool _isCurrency;
  final bool _isPercentage;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = required ? '$label *' : label;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      textAlign: textAlign,
      keyboardType: (_isCurrency || _isPercentage)
          ? const TextInputType.numberWithOptions(decimal: true)
          : keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      obscureText: obscureText,
      inputFormatters: (_isCurrency || _isPercentage)
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
          : inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.mdOnSurface,
        textBaseline: TextBaseline.alphabetic,
      ),
      decoration: InputDecoration(
        labelText: effectiveLabel,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: _isCurrency ? null : _buildPrefixIcon(),
        prefixIconConstraints: prefixIcon != null
            ? const BoxConstraints(minWidth: 44, minHeight: 44)
            : null,
        prefix: _isCurrency
            ? const Text(
                '\$  ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mdOnSurfaceVariant,
                ),
              )
            : null,
        suffixIcon: _isPercentage ? null : _buildSuffixIcon(),
        suffix: _isPercentage
            ? const Text(
                '  %',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mdOnSurfaceVariant,
                ),
              )
            : null,
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    if (prefixIcon == null) return null;
    return Icon(prefixIcon, size: AppDimensions.iconMd, color: AppColors.mdOnSurfaceVariant);
  }

  Widget? _buildSuffixIcon() {
    if (suffixIcon == null) return null;
    if (onSuffixTap != null) {
      return GestureDetector(
        onTap: onSuffixTap,
        child: Icon(suffixIcon, size: AppDimensions.iconMd, color: AppColors.mdOnSurfaceVariant),
      );
    }
    return Icon(suffixIcon, size: AppDimensions.iconMd, color: AppColors.mdOnSurfaceVariant);
  }
}
