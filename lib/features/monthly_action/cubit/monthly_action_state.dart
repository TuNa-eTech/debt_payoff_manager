import 'package:equatable/equatable.dart';

/// Data for a single payment action item in the monthly view.
class MonthlyPaymentItem extends Equatable {
  const MonthlyPaymentItem({
    required this.debtId,
    required this.debtName,
    required this.amountCents,
    required this.dueDate,
    this.isCompleted = false,
    this.isOverdue = false,
  });

  final String debtId;
  final String debtName;
  final int amountCents;
  final DateTime dueDate;
  final bool isCompleted;
  final bool isOverdue;

  @override
  List<Object?> get props => [
        debtId, debtName, amountCents, dueDate, isCompleted, isOverdue,
      ];
}

/// State for monthly action feature.
sealed class MonthlyActionState extends Equatable {
  const MonthlyActionState();

  @override
  List<Object?> get props => [];
}

class MonthlyActionInitial extends MonthlyActionState {
  const MonthlyActionInitial();
}

class MonthlyActionLoading extends MonthlyActionState {
  const MonthlyActionLoading();
}

class MonthlyActionLoaded extends MonthlyActionState {
  const MonthlyActionLoaded({
    required this.items,
    required this.totalDueCents,
    required this.completedCount,
  });

  final List<MonthlyPaymentItem> items;
  final int totalDueCents;
  final int completedCount;

  int get totalCount => items.length;
  int get overdueCount => items.where((i) => i.isOverdue).length;

  @override
  List<Object?> get props => [items, totalDueCents, completedCount];
}
