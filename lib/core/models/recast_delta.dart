import 'package:equatable/equatable.dart';

/// Delta between the previous persisted payoff summary and the latest recast.
class RecastDelta extends Equatable {
  const RecastDelta({
    required this.previousDebtFreeDate,
    required this.newDebtFreeDate,
    required this.previousTotalInterestProjected,
    required this.newTotalInterestProjected,
    required this.previousTotalInterestSaved,
    required this.newTotalInterestSaved,
  });

  final DateTime? previousDebtFreeDate;
  final DateTime? newDebtFreeDate;
  final int? previousTotalInterestProjected;
  final int? newTotalInterestProjected;
  final int? previousTotalInterestSaved;
  final int? newTotalInterestSaved;

  bool get isFirstRun => previousDebtFreeDate == null;

  bool get hasDebtFreeDateChange =>
      previousDebtFreeDate != null &&
      newDebtFreeDate != null &&
      _monthKey(previousDebtFreeDate!) != _monthKey(newDebtFreeDate!);

  bool get hasProjectedInterestChange =>
      previousTotalInterestProjected != null &&
      newTotalInterestProjected != null &&
      previousTotalInterestProjected != newTotalInterestProjected;

  bool get hasSavedInterestChange =>
      previousTotalInterestSaved != null &&
      newTotalInterestSaved != null &&
      previousTotalInterestSaved != newTotalInterestSaved;

  bool get hasMeaningfulChange =>
      !isFirstRun &&
      (hasDebtFreeDateChange ||
          hasProjectedInterestChange ||
          hasSavedInterestChange);

  int get debtFreeMonthDelta {
    if (previousDebtFreeDate == null || newDebtFreeDate == null) {
      return 0;
    }

    return ((newDebtFreeDate!.year - previousDebtFreeDate!.year) * 12) +
        (newDebtFreeDate!.month - previousDebtFreeDate!.month);
  }

  int? get projectedInterestDelta {
    if (previousTotalInterestProjected == null ||
        newTotalInterestProjected == null) {
      return null;
    }
    return newTotalInterestProjected! - previousTotalInterestProjected!;
  }

  int? get savedInterestDelta {
    if (previousTotalInterestSaved == null || newTotalInterestSaved == null) {
      return null;
    }
    return newTotalInterestSaved! - previousTotalInterestSaved!;
  }

  static int _monthKey(DateTime value) => (value.year * 12) + value.month;

  @override
  List<Object?> get props => [
    previousDebtFreeDate,
    newDebtFreeDate,
    previousTotalInterestProjected,
    newTotalInterestProjected,
    previousTotalInterestSaved,
    newTotalInterestSaved,
  ];
}
