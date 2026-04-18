import 'dart:math';

import 'package:decimal/decimal.dart';

import '../core/extensions/decimal_extensions.dart';

/// Standard amortization calculations.
///
/// Reference: financial-engine-spec.md §5.1
///
/// Used for: mortgage, student loan, personal loan (fixed payment).
abstract final class Amortization {
  /// Calculate fixed monthly payment (PMT) for standard amortization.
  ///
  /// Per §5.1:
  /// ```
  ///       P × r × (1 + r)^n
  /// PMT = ─────────────────
  ///         (1 + r)^n - 1
  /// ```
  ///
  /// Returns payment in cents.
  static int computeFixedPayment({
    required int principalCents,
    required Decimal apr,
    required int termMonths,
  }) {
    if (apr == Decimal.zero) {
      // Zero interest — simple division
      final payment =
          (Decimal.fromInt(principalCents) / Decimal.fromInt(termMonths))
              .toDecimal(scaleOnInfinitePrecision: 10);
      return payment.ceil().toDouble().toInt();
    }

    final p = DecimalFinancialExtensions.fromCents(principalCents);
    final r = apr.toDouble() / 12;
    final n = termMonths;

    final compoundFactor = pow(1 + r, n);
    final pmt = p.toDouble() * r * compoundFactor / (compoundFactor - 1);

    return (Decimal.parse(pmt.toStringAsFixed(2))).toCents();
  }

  /// Calculate remaining months to payoff given current balance and payment.
  ///
  /// Per §5.1: n = -log(1 - P × r / PMT) / log(1 + r)
  ///
  /// Returns null if payment <= monthly interest (infinite payoff).
  static int? computeRemainingMonths({
    required int balanceCents,
    required Decimal apr,
    required int paymentCents,
  }) {
    if (balanceCents <= 0) return 0;
    if (apr == Decimal.zero) {
      return (balanceCents / paymentCents).ceil();
    }

    final p = balanceCents / 100;
    final r = apr.toDouble() / 12;
    final pmt = paymentCents / 100;

    final ratio = p * r / pmt;
    if (ratio >= 1) return null; // Payment doesn't cover interest

    final n = -log(1 - ratio) / log(1 + r);
    return n.ceil();
  }

  /// Compute principal/interest split for a specific month.
  ///
  /// Per §5.1:
  /// ```
  /// Interest_k  = Balance_{k-1} × r
  /// Principal_k = PMT - Interest_k
  /// ```
  ///
  /// Returns (principalCents, interestCents).
  static ({int principal, int interest}) computePaymentSplit({
    required int balanceCents,
    required Decimal apr,
    required int paymentCents,
  }) {
    if (apr == Decimal.zero) {
      return (principal: paymentCents, interest: 0);
    }

    final balance = DecimalFinancialExtensions.fromCents(balanceCents);
    final r = (apr / Decimal.fromInt(12)).toDecimal(
      scaleOnInfinitePrecision: 10,
    );
    final interestDecimal = (balance * r).roundMoney();
    final interestCents = interestDecimal.toCents();

    // Ensure principal doesn't exceed remaining balance
    final principalCents = min(paymentCents - interestCents, balanceCents);

    return (principal: principalCents, interest: interestCents);
  }
}
