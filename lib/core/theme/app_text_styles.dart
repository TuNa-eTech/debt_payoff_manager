import 'package:flutter/material.dart';

import 'app_colors.dart';

/// App typography — MD3 type scale with Notion compression.
///
/// Font: Roboto bundled as a local app asset.
/// Philosophy: As headings scale up, letter-spacing compresses (Notion-style).
/// Line height tightens at large sizes, loosens at body sizes.
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Roboto';

  static TextStyle _roboto({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    List<FontFeature>? fontFeatures,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.mdOnSurface,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: fontFeatures,
    );
  }

  // ── Display — max size, billboard density ──
  static TextStyle get displayLarge => _roboto(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: AppColors.mdOnSurface,
    letterSpacing: -2.125,
    height: 1.0,
  );

  static TextStyle get displayMedium => _roboto(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    color: AppColors.mdOnSurface,
    letterSpacing: -1.5,
    height: 1.10,
  );

  static TextStyle get displaySmall => _roboto(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.mdOnSurface,
    letterSpacing: -0.75,
    height: 1.15,
  );

  // ── Headline ──
  static TextStyle get headlineLarge => _roboto(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.mdOnSurface,
    letterSpacing: -1.0,
    height: 1.20,
  );

  static TextStyle get headlineMedium => _roboto(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.mdOnSurface,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static TextStyle get headlineSmall => _roboto(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.mdOnSurface,
    letterSpacing: -0.25,
    height: 1.30,
  );

  // ── Title (screen headers, card titles) ──
  static TextStyle get titleLarge => _roboto(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.mdOnSurface,
    letterSpacing: -0.25,
    height: 1.27,
  );

  static TextStyle get titleMedium => _roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.mdOnSurface,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static TextStyle get titleSmall => _roboto(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.mdOnSurface,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ── Body ──
  static TextStyle get bodyLarge => _roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.mdOnSurface,
    letterSpacing: 0,
    height: 1.50,
  );

  static TextStyle get bodyMedium => _roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.mdOnSurfaceVariant,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get bodySmall => _roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mdOnSurfaceVariant,
    letterSpacing: 0,
    height: 1.33,
  );

  // ── Label ──
  static TextStyle get labelLarge => _roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.mdOnSurface,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => _roboto(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.mdOnSurfaceVariant,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => _roboto(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.mdOnSurfaceVariant,
    letterSpacing: 0.5,
    height: 1.27,
  );

  // ── Badge / Status pill ──
  static TextStyle get badge => _roboto(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );

  // ── Money display (tabular, compressed) ──
  static TextStyle get moneyLarge => _roboto(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.mdOnSurface,
    letterSpacing: -1.0,
    height: 1.0,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get moneyMedium => _roboto(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.mdOnSurface,
    letterSpacing: -0.5,
    height: 1.10,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get moneySmall => _roboto(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.mdOnSurface,
    letterSpacing: -0.25,
    height: 1.20,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get moneyXSmall => _roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.mdOnSurface,
    letterSpacing: 0,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ── Navigation label ──
  static TextStyle get navLabel => _roboto(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  // ── Text style builder (fluent override helper) ──
  /// Example: `AppTextStyles.bodyMedium.colored(AppColors.mdError)`
  static TextStyle Function({Color? color, FontWeight? weight, double? size})
  styleBuilder(TextStyle base) {
    return ({Color? color, FontWeight? weight, double? size}) =>
        base.copyWith(color: color, fontWeight: weight, fontSize: size);
  }
}

/// Extension for quick color overrides on TextStyle.
extension TextStyleX on TextStyle {
  TextStyle colored(Color color) => copyWith(color: color);
  TextStyle weighted(FontWeight weight) => copyWith(fontWeight: weight);
  TextStyle sized(double size) => copyWith(fontSize: size);
}
