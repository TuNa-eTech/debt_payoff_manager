import 'package:equatable/equatable.dart';

/// Timeline projection — cached simulation result.
///
/// Reference: financial-engine-spec.md §3.5
///
/// This is a **cache, not source of truth**. Regenerated on any input change.
class TimelineProjection extends Equatable {
  const TimelineProjection({
    required this.planId,
    required this.generatedAt,
    required this.months,
  });

  final String planId;
  final DateTime generatedAt;
  final List<MonthProjection> months;

  @override
  List<Object?> get props => [planId, generatedAt, months];
}

/// Projection data for a single month across all debts.
class MonthProjection extends Equatable {
  const MonthProjection({
    required this.monthIndex,
    required this.yearMonth,
    required this.entries,
    required this.totalPaymentThisMonth,
    required this.totalInterestThisMonth,
    required this.totalBalanceEndOfMonth,
  });

  /// 0 = current month.
  final int monthIndex;

  /// "YYYY-MM" format.
  final String yearMonth;

  final List<DebtMonthEntry> entries;

  /// Total payment across all debts this month (cents).
  final int totalPaymentThisMonth;

  /// Total interest across all debts this month (cents).
  final int totalInterestThisMonth;

  /// Sum of all ending balances (cents).
  final int totalBalanceEndOfMonth;

  @override
  List<Object?> get props => [
        monthIndex, yearMonth, entries,
        totalPaymentThisMonth, totalInterestThisMonth, totalBalanceEndOfMonth,
      ];
}

/// Per-debt data within a month projection.
class DebtMonthEntry extends Equatable {
  const DebtMonthEntry({
    required this.debtId,
    required this.startingBalance,
    required this.interestAccrued,
    required this.paymentApplied,
    required this.principalPortion,
    required this.interestPortion,
    required this.endingBalance,
    this.isPaidOffThisMonth = false,
  });

  final String debtId;

  /// All amounts in cents.
  final int startingBalance;
  final int interestAccrued;
  final int paymentApplied;
  final int principalPortion;
  final int interestPortion;
  final int endingBalance;
  final bool isPaidOffThisMonth;

  @override
  List<Object?> get props => [
        debtId, startingBalance, interestAccrued, paymentApplied,
        principalPortion, interestPortion, endingBalance, isPaidOffThisMonth,
      ];
}
