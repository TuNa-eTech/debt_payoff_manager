import 'package:equatable/equatable.dart';

import '../../domain/enums/debt_type.dart';
import '../../domain/enums/payment_type.dart';

enum MonthlyActionKind { minimum, extra }

class MonthlyActionItem extends Equatable {
  const MonthlyActionItem({
    required this.id,
    required this.debtId,
    required this.debtName,
    required this.debtType,
    required this.kind,
    required this.paymentType,
    required this.amountCents,
    required this.dueDate,
    required this.subtitle,
    this.priorityRank,
    this.isCompleted = false,
    this.isOverdue = false,
    this.isUpcoming = false,
  });

  final String id;
  final String debtId;
  final String debtName;
  final DebtType debtType;
  final MonthlyActionKind kind;
  final PaymentType paymentType;
  final int amountCents;
  final DateTime dueDate;
  final String subtitle;
  final int? priorityRank;
  final bool isCompleted;
  final bool isOverdue;
  final bool isUpcoming;

  MonthlyActionItem copyWith({
    bool? isCompleted,
    bool? isOverdue,
    bool? isUpcoming,
  }) {
    return MonthlyActionItem(
      id: id,
      debtId: debtId,
      debtName: debtName,
      debtType: debtType,
      kind: kind,
      paymentType: paymentType,
      amountCents: amountCents,
      dueDate: dueDate,
      subtitle: subtitle,
      priorityRank: priorityRank,
      isCompleted: isCompleted ?? this.isCompleted,
      isOverdue: isOverdue ?? this.isOverdue,
      isUpcoming: isUpcoming ?? this.isUpcoming,
    );
  }

  @override
  List<Object?> get props => [
        id,
        debtId,
        debtName,
        debtType,
        kind,
        paymentType,
        amountCents,
        dueDate,
        subtitle,
        priorityRank,
        isCompleted,
        isOverdue,
        isUpcoming,
      ];
}

class MonthlyActionSection extends Equatable {
  const MonthlyActionSection({
    required this.debtId,
    required this.debtName,
    required this.debtType,
    required this.totalDueCents,
    required this.items,
  });

  final String debtId;
  final String debtName;
  final DebtType debtType;
  final int totalDueCents;
  final List<MonthlyActionItem> items;

  bool get isCompleted => items.isNotEmpty && items.every((item) => item.isCompleted);

  @override
  List<Object?> get props => [debtId, debtName, debtType, totalDueCents, items];
}

class MonthlyActionSummary extends Equatable {
  const MonthlyActionSummary({
    required this.totalMinimumCents,
    required this.totalExtraCents,
    required this.totalDueCents,
    required this.completedCount,
    required this.totalCount,
    required this.overdueCount,
  });

  final int totalMinimumCents;
  final int totalExtraCents;
  final int totalDueCents;
  final int completedCount;
  final int totalCount;
  final int overdueCount;

  bool get allCompleted => totalCount > 0 && completedCount == totalCount;

  @override
  List<Object?> get props => [
        totalMinimumCents,
        totalExtraCents,
        totalDueCents,
        completedCount,
        totalCount,
        overdueCount,
      ];
}
