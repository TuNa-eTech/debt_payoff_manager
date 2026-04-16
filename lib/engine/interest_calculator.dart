import 'dart:math';

import 'package:decimal/decimal.dart';

import '../core/constants/financial_constants.dart';
import '../core/extensions/decimal_extensions.dart';
import '../domain/enums/interest_method.dart';

/// Interest calculation engine.
///
/// Reference: financial-engine-spec.md §4, §5.1-5.4
///
/// **Pure Dart — no Flutter imports. All methods are static and deterministic.**
class InterestCalculator {
  InterestCalculator._();

  /// Compute monthly periodic rate from APR.
  ///
  /// Per §4.2: Monthly periodic rate = APR / 12
  static Decimal monthlyRate(Decimal apr) {
    return (apr / Decimal.fromInt(FinancialConstants.monthsPerYear)).toDecimal(scaleOnInfinitePrecision: 10).roundRate();
  }

  /// Compute daily periodic rate from APR.
  ///
  /// Per §4.2: Daily periodic rate = APR / 365
  static Decimal dailyRate(Decimal apr, {int daysInYear = 365}) {
    return (apr / Decimal.fromInt(daysInYear)).toDecimal(scaleOnInfinitePrecision: 10).roundRate();
  }

  /// Compute interest for a month based on the debt's interest method.
  ///
  /// Per §5.1-5.3: method determines calculation approach.
  /// Returns interest in cents.
  static int computeMonthlyInterest({
    required int balanceCents,
    required Decimal apr,
    required InterestMethod method,
    int daysInMonth = 30,
    int daysInYear = 365,
  }) {
    if (balanceCents <= 0 || apr == Decimal.zero) return 0;

    final balance = DecimalFinancialExtensions.fromCents(balanceCents);

    switch (method) {
      case InterestMethod.simpleMonthly:
        // §5.2: Interest = Balance × (APR / 12)
        final rate = monthlyRate(apr);
        final interest = (balance * rate).roundMoney();
        return interest.toCents();

      case InterestMethod.compoundDaily:
        // §5.3: Effective monthly from daily compound
        // effective_monthly_rate = (1 + APR/365)^days - 1
        final dailyRateDouble = apr.toDouble() / daysInYear;
        final effectiveMonthly = pow(1 + dailyRateDouble, daysInMonth) - 1;
        final interest =
            (balance * Decimal.parse(effectiveMonthly.toStringAsFixed(10)))
                .roundMoney();
        return interest.toCents();

      case InterestMethod.compoundMonthly:
        // Same as simpleMonthly for per-month calculation.
        // Compound effect is in the amortization schedule.
        final rate = monthlyRate(apr);
        final interest = (balance * rate).roundMoney();
        return interest.toCents();
    }
  }

  /// Compute APY from APR.
  ///
  /// Per §4.1: APY = (1 + APR/n)^n - 1
  static Decimal computeApy(Decimal apr, {int compoundingPeriods = 12}) {
    final ratePerPeriod = apr.toDouble() / compoundingPeriods;
    final apy = pow(1 + ratePerPeriod, compoundingPeriods) - 1;
    return Decimal.parse(apy.toStringAsFixed(FinancialConstants.rateScaleInternal));
  }
}
