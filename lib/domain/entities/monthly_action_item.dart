import 'package:equatable/equatable.dart';

import 'debt.dart';

/// Represents a planned action (payment) for a debt in a specific month.
class MonthlyActionItem extends Equatable {
  const MonthlyActionItem({
    required this.debt,
    required this.plannedMinimum,
    required this.plannedExtra,
    required this.totalPaidThisMonth,
  });

  /// The debt associated with this action.
  final Debt debt;

  /// The planned minimum payment amount in cents.
  final int plannedMinimum;

  /// The planned extra payment amount in cents (allocated by strategy).
  final int plannedExtra;

  /// The total amount already paid towards this debt in the current month in cents.
  final int totalPaidThisMonth;

  /// The total planned payment for this month (minimum + extra).
  int get totalPlanned => plannedMinimum + plannedExtra;

  /// Returns true if the planned amount has been fully paid.
  bool get isPaid => totalPaidThisMonth >= totalPlanned;

  /// The remaining amount to pay this month to reach the planned target.
  int get remainingToPay {
    final remaining = totalPlanned - totalPaidThisMonth;
    return remaining > 0 ? remaining : 0;
  }

  MonthlyActionItem copyWith({
    Debt? debt,
    int? plannedMinimum,
    int? plannedExtra,
    int? totalPaidThisMonth,
  }) {
    return MonthlyActionItem(
      debt: debt ?? this.debt,
      plannedMinimum: plannedMinimum ?? this.plannedMinimum,
      plannedExtra: plannedExtra ?? this.plannedExtra,
      totalPaidThisMonth: totalPaidThisMonth ?? this.totalPaidThisMonth,
    );
  }

  @override
  List<Object?> get props => [
        debt,
        plannedMinimum,
        plannedExtra,
        totalPaidThisMonth,
      ];
}
