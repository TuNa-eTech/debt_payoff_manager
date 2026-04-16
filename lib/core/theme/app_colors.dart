import 'package:flutter/material.dart';

/// App color palette.
///
/// Uses a curated dark theme with teal accent — trust-evoking,
/// finance-appropriate palette.
class AppColors {
  AppColors._();

  // ── Primary palette ──
  static const Color primary = Color(0xFF00BFA6);       // Teal accent
  static const Color primaryLight = Color(0xFF5DF2D6);
  static const Color primaryDark = Color(0xFF008E76);

  // ── Secondary palette ──
  static const Color secondary = Color(0xFF7C4DFF);      // Purple accent
  static const Color secondaryLight = Color(0xFFB47CFF);
  static const Color secondaryDark = Color(0xFF3F1DCB);

  // ── Surface / Background (Dark mode) ──
  static const Color background = Color(0xFF0F1419);
  static const Color surface = Color(0xFF1A1F25);
  static const Color surfaceVariant = Color(0xFF242B33);
  static const Color surfaceElevated = Color(0xFF2A323C);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // ── Semantic ──
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Financial specific ──
  static const Color debtRed = Color(0xFFFF6B6B);
  static const Color paidOffGreen = Color(0xFF4ADE80);
  static const Color interestAmber = Color(0xFFFCD34D);
  static const Color principalTeal = Color(0xFF2DD4BF);

  // ── Borders & Dividers ──
  static const Color border = Color(0xFF334155);
  static const Color divider = Color(0xFF1E293B);
}
