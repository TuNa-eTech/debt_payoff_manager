import 'package:decimal/decimal.dart';

import '../../core/constants/financial_constants.dart';

/// Extensions on [Decimal] for financial operations.
///
/// Reference: financial-engine-spec.md §2 (Precision & Money Representation)
extension DecimalFinancialExtensions on Decimal {
  /// Round to money scale (2 decimal places) using banker's rounding.
  ///
  /// Per spec §2: "Banker's rounding (round-half-to-even) cho interest calc"
  Decimal roundMoney() => round(scale: FinancialConstants.moneyScale);

  /// Round to internal rate precision (10 decimal places).
  Decimal roundRate() => round(scale: FinancialConstants.rateScaleInternal);

  /// Round for display rate (4 decimal places).
  Decimal roundRateDisplay() => round(scale: FinancialConstants.rateScaleDisplay);

  /// Round percentage for display (1 decimal place).
  Decimal roundPercentDisplay() =>
      round(scale: FinancialConstants.percentScaleDisplay);

  /// Convert from cents (integer) to dollar amount.
  ///
  /// Per spec §2: "$12.34 → lưu 1234 (cents)"
  static Decimal fromCents(int cents) =>
      (Decimal.fromInt(cents) / Decimal.fromInt(100)).toDecimal();

  /// Convert dollar amount to cents (integer).
  int toCents() => (this * Decimal.fromInt(100)).round().toDouble().toInt();

  /// Check if this Decimal is negative.
  bool get isNegative => this < Decimal.zero;

  /// Check if this Decimal is positive.
  bool get isPositive => this > Decimal.zero;

  /// Check if this Decimal is zero.
  bool get isZero => this == Decimal.zero;
}
