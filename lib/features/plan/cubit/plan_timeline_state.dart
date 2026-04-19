import 'package:equatable/equatable.dart';

import '../../../../core/models/recast_delta.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/entities/timeline_projection.dart';

class PlanTimelineState extends Equatable {
  const PlanTimelineState({
    this.isLoading = true,
    this.debts = const [],
    this.plan,
    this.projection,
    this.delta,
    this.errorMessage,
  });

  final bool isLoading;
  final List<Debt> debts;
  final Plan? plan;
  final TimelineProjection? projection;
  final RecastDelta? delta;
  final String? errorMessage;

  bool get hasTrackedDebts => debts.isNotEmpty;
  bool get allTrackedDebtsPaidOff =>
      debts.isNotEmpty && debts.every((debt) => debt.currentBalance == 0);

  PlanTimelineState copyWith({
    bool? isLoading,
    List<Debt>? debts,
    Plan? plan,
    TimelineProjection? projection,
    RecastDelta? delta,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PlanTimelineState(
      isLoading: isLoading ?? this.isLoading,
      debts: debts ?? this.debts,
      plan: plan ?? this.plan,
      projection: projection ?? this.projection,
      delta: delta ?? this.delta,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        debts,
        plan,
        projection,
        delta,
        errorMessage,
      ];
}
