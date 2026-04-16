import 'dart:math';

import 'package:decimal/decimal.dart';

import '../core/extensions/decimal_extensions.dart';
import '../domain/enums/min_payment_type.dart';

/// Minimum payment calculator.
///
/// Reference: financial-engine-spec.md §6.1
///
/// Supports 3 methods per spec:
/// A. Fixed amount
/// B. Percent of balance
/// C. Interest + percent of principal
class MinPaymentCalculator {
  MinPaymentCalculator._();

  /// Compute minimum payment for a given month.
  ///
  /// Returns payment in cents.
  static int compute({
    required int balanceCents,
    required int interestCents,
    required MinPaymentType type,
    required int fixedAmountCents,
    Decimal? percent,
    int? floorCents,
  }) {
    if (balanceCents <= 0) return 0;

    int calculated;

    switch (type) {
      case MinPaymentType.fixed:
        // §6.1 A: min_payment = fixed_value
        calculated = fixedAmountCents;

      case MinPaymentType.percentOfBalance:
        // §6.1 B: min_payment = max(balance × percent, floor)
        assert(percent != null, 'percent required for percentOfBalance');
        final balance = DecimalFinancialExtensions.fromCents(balanceCents);
        final pctPayment = (balance * percent!).roundMoney().toCents();
        calculated = max(pctPayment, floorCents ?? 0);

      case MinPaymentType.interestPlusPercent:
        // §6.1 C: min_payment = max(interest + balance × percent, floor)
        assert(percent != null, 'percent required for interestPlusPercent');
        final balance = DecimalFinancialExtensions.fromCents(balanceCents);
        final principalPortion =
            (balance * percent!).roundMoney().toCents();
        final total = interestCents + principalPortion;
        calculated = max(total, floorCents ?? 0);
    }

    // Never exceed remaining balance + interest
    return min(calculated, balanceCents + interestCents);
  }
}
