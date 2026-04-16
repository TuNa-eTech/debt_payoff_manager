import 'package:decimal/decimal.dart';

import '../core/constants/financial_constants.dart';

/// Validation and sanity checks for financial calculations.
///
/// Reference: financial-engine-spec.md §11
///
/// "Mỗi phép tính phải pass sanity check trước khi hiển thị."
class FinancialValidators {
  FinancialValidators._();

  /// Check if balance exceeds growth cap (1.5x original).
  ///
  /// Per §11.1: balance <= originalPrincipal × 1.5
  static bool isBalanceOverGrown({
    required int currentBalanceCents,
    required int originalPrincipalCents,
  }) {
    final cap = (Decimal.fromInt(originalPrincipalCents) *
            FinancialConstants.balanceGrowthCap)
        .toBigInt()
        .toInt();
    return currentBalanceCents > cap;
  }

  /// Check if APR triggers usury warning.
  ///
  /// Per §11.2: APR > 36% → warning
  static bool isUsuryWarning(Decimal apr) {
    return apr > FinancialConstants.usuryWarningThreshold;
  }

  /// Check if minimum payment covers monthly interest.
  ///
  /// Per §11.2: "Minimum payment không đủ bù lãi — nợ sẽ tăng"
  static bool isNegativeAmortization({
    required int minimumPaymentCents,
    required int monthlyInterestCents,
  }) {
    return minimumPaymentCents < monthlyInterestCents;
  }

  /// Check if projected payoff exceeds 30 years.
  ///
  /// Per §11.2: "Debt-free date > 30 năm → warning"
  static bool isPayoffTooLong(int projectedMonths) {
    return projectedMonths >
        FinancialConstants.debtFreeDateWarningYears * 12;
  }

  /// Verify payment split invariant.
  ///
  /// Per §3.2 invariant: amount == principalPortion + interestPortion + feePortion
  static bool isPaymentSplitValid({
    required int amount,
    required int principalPortion,
    required int interestPortion,
    required int feePortion,
  }) {
    return amount == principalPortion + interestPortion + feePortion;
  }

  /// Generate sanity warnings for a debt.
  ///
  /// Returns list of warning messages per §11.2.
  static List<String> generateWarnings({
    required int currentBalanceCents,
    required int originalPrincipalCents,
    required Decimal apr,
    required int minimumPaymentCents,
    required int monthlyInterestCents,
    int? projectedMonths,
  }) {
    final warnings = <String>[];

    if (isBalanceOverGrown(
      currentBalanceCents: currentBalanceCents,
      originalPrincipalCents: originalPrincipalCents,
    )) {
      warnings.add(
        'Balance exceeds original principal — '
        'you may not be covering monthly interest.',
      );
    }

    if (isUsuryWarning(apr)) {
      warnings.add('Unusually high interest rate. Please verify your APR.');
    }

    if (isNegativeAmortization(
      minimumPaymentCents: minimumPaymentCents,
      monthlyInterestCents: monthlyInterestCents,
    )) {
      warnings.add(
        'Minimum payment doesn\'t cover interest — '
        'your balance will grow each month.',
      );
    }

    if (projectedMonths != null && isPayoffTooLong(projectedMonths)) {
      warnings.add(
        'At the current rate, payoff will take over 30 years. '
        'Consider increasing your extra payment.',
      );
    }

    return warnings;
  }
}
