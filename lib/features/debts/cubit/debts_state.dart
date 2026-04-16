import 'package:equatable/equatable.dart';

import '../../../../domain/entities/debt.dart';

/// State for debts list management.
sealed class DebtsState extends Equatable {
  const DebtsState();

  @override
  List<Object?> get props => [];
}

class DebtsInitial extends DebtsState {
  const DebtsInitial();
}

class DebtsLoading extends DebtsState {
  const DebtsLoading();
}

class DebtsLoaded extends DebtsState {
  const DebtsLoaded({required this.debts});

  final List<Debt> debts;

  int get activeCount => debts.where((d) => d.status.name == 'active').length;
  int get totalBalanceCents => debts.fold(0, (s, d) => s + d.currentBalance);

  @override
  List<Object?> get props => [debts];
}

class DebtsError extends DebtsState {
  const DebtsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
