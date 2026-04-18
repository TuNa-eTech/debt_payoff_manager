/// App spacing, radius, and dimension constants.
///
/// Aligned with the Material Design 3 × Notion design system.
class AppDimensions {
  AppDimensions._();

  // ── Spacing scale ──
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ── Page layout ──
  static const double pagePaddingH = 16.0;
  static const double pagePaddingV = 12.0;
  static const double cardPadding = 16.0;
  static const double sectionGap = 24.0;

  // ── Border radius (MD3 shape scale) ──
  static const double radiusXs = 4.0;    // None / Extra Small
  static const double radiusSm = 8.0;    // Small — buttons, inputs
  static const double radiusMd = 12.0;   // Medium
  static const double radiusLg = 16.0;   // Large — cards
  static const double radiusXl = 28.0;   // Extra Large
  static const double radius2xl = 24.0;  // Hero cards (design system uses 24)
  static const double radiusFull = 999.0; // Full — pills, FABs, chips

  // ── Component heights ──
  static const double buttonHeightSm = 36.0;  // Chips
  static const double buttonHeight = 48.0;    // Standard buttons
  static const double buttonHeightLg = 56.0;  // Primary CTA / FAB
  static const double inputHeight = 56.0;     // Text fields
  static const double statusBarHeight = 44.0;
  static const double topAppBarHeight = 64.0;
  static const double navBarHeight = 80.0;

  // ── Icon sizes ──
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 40.0;

  // ── Elevation (MD3 tonal surfaces — shadows are minimal/Notion-style) ──
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0;
  static const double elevationMd = 2.0;
  static const double elevationLg = 4.0;

  // ── Animation durations (ms) ──
  static const int animFast = 150;
  static const int animNormal = 250;
  static const int animSlow = 400;

  // ── Bottom sheet ──
  static const double bottomSheetTopRadius = 24.0;
  static const double bottomSheetPaddingH = 24.0;
  static const double bottomSheetPaddingV = 16.0;
  static const double bottomSheetPaddingBottom = 40.0; // + safe area
}
