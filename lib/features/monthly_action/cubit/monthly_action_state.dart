import 'package:equatable/equatable.dart';

import '../../../../core/models/monthly_action_models.dart';
import '../../../../core/models/recast_delta.dart';
import '../../../../domain/entities/plan.dart';

class MonthlyActionState extends Equatable {
  const MonthlyActionState({
    this.isLoading = true,
    this.referenceDate,
    this.plan,
    this.delta,
    this.sections = const [],
    this.summary,
    this.submittingIds = const <String>{},
    this.errorMessage,
    this.hasTrackedDebts = false,
  });

  final bool isLoading;
  final DateTime? referenceDate;
  final Plan? plan;
  final RecastDelta? delta;
  final List<MonthlyActionSection> sections;
  final MonthlyActionSummary? summary;
  final Set<String> submittingIds;
  final String? errorMessage;
  final bool hasTrackedDebts;

  bool get hasActionItems => sections.any((section) => section.items.isNotEmpty);

  MonthlyActionState copyWith({
    bool? isLoading,
    DateTime? referenceDate,
    Plan? plan,
    RecastDelta? delta,
    List<MonthlyActionSection>? sections,
    MonthlyActionSummary? summary,
    Set<String>? submittingIds,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? hasTrackedDebts,
  }) {
    return MonthlyActionState(
      isLoading: isLoading ?? this.isLoading,
      referenceDate: referenceDate ?? this.referenceDate,
      plan: plan ?? this.plan,
      delta: delta ?? this.delta,
      sections: sections ?? this.sections,
      summary: summary ?? this.summary,
      submittingIds: submittingIds ?? this.submittingIds,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      hasTrackedDebts: hasTrackedDebts ?? this.hasTrackedDebts,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        referenceDate,
        plan,
        delta,
        sections,
        summary,
        submittingIds,
        errorMessage,
        hasTrackedDebts,
      ];
}
