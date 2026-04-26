import 'package:equatable/equatable.dart';

import '../../../domain/entities/scenario.dart';

class ScenariosState extends Equatable {
  const ScenariosState({
    this.isLoading = true,
    this.scenarios = const [],
    this.activeScenarioId = 'main',
    this.error,
  });

  final bool isLoading;
  final List<Scenario> scenarios;
  final String activeScenarioId;
  final String? error;

  ScenariosState copyWith({
    bool? isLoading,
    List<Scenario>? scenarios,
    String? activeScenarioId,
    String? error,
    bool clearError = false,
  }) {
    return ScenariosState(
      isLoading: isLoading ?? this.isLoading,
      scenarios: scenarios ?? this.scenarios,
      activeScenarioId: activeScenarioId ?? this.activeScenarioId,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, scenarios, activeScenarioId, error];
}
