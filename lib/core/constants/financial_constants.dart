import 'package:decimal/decimal.dart';

/// Financial constants derived from financial-engine-spec.md.
///
/// Reference: §2 (Precision), §4 (Interest), §11 (Validation)
class FinancialConstants {
  FinancialConstants._();

  // ── Scale rules (spec §2) ──

  /// Money amounts: 2 decimal places.
  static const int moneyScale = 2;

  /// Interest rate internal precision: 10 decimal places.
  static const int rateScaleInternal = 10;

  /// Interest rate display precision: 4 decimal places.
  static const int rateScaleDisplay = 4;

  /// Percentage internal precision: 4 decimal places.
  static const int percentScaleInternal = 4;

  /// Percentage display precision: 1 decimal place.
  static const int percentScaleDisplay = 1;

  // ── Validation bounds (spec §11) ──

  /// Maximum allowed APR (100%).
  static final Decimal maxApr = Decimal.one;

  /// Minimum allowed APR (0%).
  static final Decimal minApr = Decimal.zero;

  /// APR threshold for usury warning (36%).
  static final Decimal usuryWarningThreshold = Decimal.parse('0.36');

  /// Balance growth cap: balance should not exceed 1.5x original principal
  /// (soft limit, excludes long forbearance).
  static final Decimal balanceGrowthCap = Decimal.parse('1.5');

  /// Total interest cap: total projected interest should not exceed 2x
  /// sum of original principals (soft warning).
  static const int totalInterestCapMultiplier = 2;

  /// Debt-free date warning threshold: 30 years.
  static const int debtFreeDateWarningYears = 30;

  // ── Day count conventions ──

  /// Default days in year (actual/365). Some issuers use 360.
  static const int defaultDaysInYear = 365;

  /// Bank method days in year.
  static const int bankMethodDaysInYear = 360;

  /// Months per year.
  static const int monthsPerYear = 12;

  /// Bi-weekly periods per year.
  static const int biweeklyPeriodsPerYear = 26;
}
