import 'package:equatable/equatable.dart';

import '../../../../domain/entities/debt.dart';
import '../../../../domain/enums/debt_status.dart';

enum DebtsFilter { all, active, paidOff, archived }

class DebtActionFeedback extends Equatable {
  const DebtActionFeedback({
    required this.message,
    required this.sequence,
  });

  final String message;
  final int sequence;

  @override
  List<Object?> get props => [message, sequence];
}

class DebtsState extends Equatable {
  const DebtsState({
    this.isLoading = true,
    this.debts = const [],
    this.filter = DebtsFilter.all,
    this.inlineError,
    this.lastActionFeedback,
  });

  final bool isLoading;
  final List<Debt> debts;
  final DebtsFilter filter;
  final String? inlineError;
  final DebtActionFeedback? lastActionFeedback;

  List<Debt> get visibleDebts {
    switch (filter) {
      case DebtsFilter.all:
        return debts;
      case DebtsFilter.active:
        return debts
            .where(
              (debt) =>
                  debt.status == DebtStatus.active ||
                  debt.status == DebtStatus.paused,
            )
            .toList();
      case DebtsFilter.paidOff:
        return debts
            .where((debt) => debt.status == DebtStatus.paidOff)
            .toList();
      case DebtsFilter.archived:
        return debts
            .where((debt) => debt.status == DebtStatus.archived)
            .toList();
    }
  }

  int get totalBalanceCents => debts.fold(
        0,
        (sum, debt) => sum + debt.currentBalance,
      );

  int get activeCount => debts
      .where(
        (debt) =>
            debt.status == DebtStatus.active ||
            debt.status == DebtStatus.paused,
      )
      .length;

  int get paidOffCount =>
      debts.where((debt) => debt.status == DebtStatus.paidOff).length;

  int get archivedCount =>
      debts.where((debt) => debt.status == DebtStatus.archived).length;

  DebtsState copyWith({
    bool? isLoading,
    List<Debt>? debts,
    DebtsFilter? filter,
    String? inlineError,
    bool clearInlineError = false,
    DebtActionFeedback? lastActionFeedback,
    bool clearLastActionFeedback = false,
  }) {
    return DebtsState(
      isLoading: isLoading ?? this.isLoading,
      debts: debts ?? this.debts,
      filter: filter ?? this.filter,
      inlineError: clearInlineError ? null : (inlineError ?? this.inlineError),
      lastActionFeedback: clearLastActionFeedback
          ? null
          : (lastActionFeedback ?? this.lastActionFeedback),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        debts,
        filter,
        inlineError,
        lastActionFeedback,
      ];
}
