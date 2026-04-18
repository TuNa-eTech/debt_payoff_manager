import 'package:flutter/material.dart';

/// App color palette.
///
/// Material Design 3 × Notion aesthetic.
/// Seed: Forest Green #1B6B4A — trust-evoking, calm, finance-appropriate.
class AppColors {
  AppColors._();

  // ── MD3 Primary (Forest Green) ──
  static const Color mdPrimary = Color(0xFF1B6B4A);
  static const Color mdOnPrimary = Color(0xFFFFFFFF);
  static const Color mdPrimaryContainer = Color(0xFFA8F0CC);
  static const Color mdOnPrimaryContainer = Color(0xFF002114);
  static const Color mdInversePrimary = Color(0xFF8DD4B1);

  // ── MD3 Secondary ──
  static const Color mdSecondary = Color(0xFF4D6357);
  static const Color mdOnSecondary = Color(0xFFFFFFFF);
  static const Color mdSecondaryContainer = Color(0xFFCFE9D8);
  static const Color mdOnSecondaryContainer = Color(0xFF0A1F15);

  // ── MD3 Tertiary ──
  static const Color mdTertiary = Color(0xFF3A6373);
  static const Color mdOnTertiary = Color(0xFFFFFFFF);
  static const Color mdTertiaryContainer = Color(0xFFBDE9FB);
  static const Color mdOnTertiaryContainer = Color(0xFF001F29);

  // ── MD3 Surface Scale (Notion Warm Whites) ──
  static const Color mdSurface = Color(0xFFFFFFFF);
  static const Color mdOnSurface = Color(0xFF1A1A1A); // Notion Black
  static const Color mdOnSurfaceVariant = Color(0xFF404943);
  static const Color mdSurfaceVariant = Color(0xFFDCE5DC);
  static const Color mdSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color mdSurfaceContainerLow = Color(0xFFF6F5F4); // Warm White
  static const Color mdSurfaceContainer = Color(0xFFEFEBE8);
  static const Color mdSurfaceContainerHigh = Color(0xFFE3E9E4);
  static const Color mdSurfaceContainerHighest = Color(0xFFE5E1DD);
  static const Color mdInverseSurface = Color(0xFF2C322D);
  static const Color mdInverseOnSurface = Color(0xFFECF2ED);

  // ── MD3 Error ──
  static const Color mdError = Color(0xFFBA1A1A);
  static const Color mdOnError = Color(0xFFFFFFFF);
  static const Color mdErrorContainer = Color(0xFFFFD9D9);
  static const Color mdOnErrorContainer = Color(0xFF410002);

  // ── MD3 Outline ──
  static const Color mdOutline = Color(0xFF707973);
  static const Color mdOutlineVariant = Color(0xFFEAEAE8); // Whisper border

  // ── Semantic colors ──
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFEFF6FF);

  // ── Financial-specific ──
  static const Color debtRed = Color(0xFFDD0000);
  static const Color debtRedContainer = Color(0xFFFFD9D9);
  static const Color paidGreen = Color(0xFF1B6B4A);
  static const Color paidGreenContainer = Color(0xFFA8F0CC);
  static const Color interestAmber = Color(0xFFD97706);
  static const Color principalGreen = Color(0xFF16A34A);

  // ── Legacy aliases (for backward-compat during migration) ──
  static const Color primary = mdPrimary;
  static const Color onPrimary = mdOnPrimary;
  static const Color surface = mdSurface;
  static const Color background = mdSurfaceContainerLow;
  static const Color surfaceVariant = mdSurfaceContainer;
  static const Color surfaceElevated = mdSurfaceContainerHigh;
  static const Color textPrimary = mdOnSurface;
  static const Color textSecondary = mdOnSurfaceVariant;
  static const Color textTertiary = mdOutline;
  static const Color error = mdError;
  static const Color border = mdOutlineVariant;
  static const Color divider = mdOutlineVariant;
  static const Color secondary = mdSecondary;

  // ── Helper: Notion whisper border ──
  static const Color whisperBorder = Color(0x1A000000); // rgba(0,0,0,0.10)
}
