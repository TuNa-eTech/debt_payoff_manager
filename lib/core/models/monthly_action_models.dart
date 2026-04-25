import 'package:equatable/equatable.dart';

import '../../domain/enums/debt_status.dart';
import '../../domain/enums/debt_type.dart';
import '../../domain/enums/payment_type.dart';

enum MonthlyActionKind { minimum, extra }

class MonthlyActionCompletionProof extends Equatable {
  const MonthlyActionCompletionProof({
    required this.paymentId,
    required this.amountCents,
    required this.date,
    required this.appliedBalanceAfter,
    required this.source,
    required this.type,
  });

  final String paymentId;
  final int amountCents;
  final DateTime date;
  final int appliedBalanceAfter;
  final PaymentSource source;
  final PaymentType type;

  @override
  List<Object?> get props => [
    paymentId,
    amountCents,
    date,
    appliedBalanceAfter,
    source,
    type,
  ];
}

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
    this.completionProof,
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
  final MonthlyActionCompletionProof? completionProof;

  MonthlyActionItem copyWith({
    bool? isCompleted,
    bool? isOverdue,
    bool? isUpcoming,
    MonthlyActionCompletionProof? completionProof,
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
      completionProof: completionProof ?? this.completionProof,
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
    completionProof,
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

  bool get isCompleted =>
      items.isNotEmpty && items.every((item) => item.isCompleted);

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
    required this.loggedTotalCents,
    this.latestLoggedAt,
    required this.remainingBalanceCents,
    required this.trackedDebtCount,
    required this.paidOffDebtCount,
    this.singleDebtId,
    this.singleDebtName,
    this.singleDebtDueDate,
    this.singleDebtStatus,
  });

  final int totalMinimumCents;
  final int totalExtraCents;
  final int totalDueCents;
  final int completedCount;
  final int totalCount;
  final int overdueCount;
  final int loggedTotalCents;
  final DateTime? latestLoggedAt;
  final int remainingBalanceCents;
  final int trackedDebtCount;
  final int paidOffDebtCount;
  final String? singleDebtId;
  final String? singleDebtName;
  final DateTime? singleDebtDueDate;
  final DebtStatus? singleDebtStatus;

  bool get allCompleted => totalCount > 0 && completedCount == totalCount;
  bool get hasSingleTrackedDebt =>
      trackedDebtCount == 1 && singleDebtId != null;
  bool get singleTrackedDebtPaidOff =>
      hasSingleTrackedDebt &&
      (singleDebtStatus == DebtStatus.paidOff || remainingBalanceCents <= 0);

  @override
  List<Object?> get props => [
    totalMinimumCents,
    totalExtraCents,
    totalDueCents,
    completedCount,
    totalCount,
    overdueCount,
    loggedTotalCents,
    latestLoggedAt,
    remainingBalanceCents,
    trackedDebtCount,
    paidOffDebtCount,
    singleDebtId,
    singleDebtName,
    singleDebtDueDate,
    singleDebtStatus,
  ];
}
