import 'package:equatable/equatable.dart';

import '../../../core/models/scenario_lab_models.dart';
import '../../../domain/enums/strategy.dart';

enum ScenarioLabStatus { idle, loading, previewReady, saving, saved, error }

class ScenarioLabState extends Equatable {
  const ScenarioLabState({
    this.status = ScenarioLabStatus.idle,
    this.selectedTemplate = ScenarioLabTemplate.extraMonthly,
    this.selectedStrategy = Strategy.avalanche,
    this.preview,
    this.savedResult,
    this.errorMessage,
  });

  final ScenarioLabStatus status;
  final ScenarioLabTemplate selectedTemplate;
  final Strategy selectedStrategy;
  final ScenarioLabPreview? preview;
  final SavedScenarioResult? savedResult;
  final String? errorMessage;

  bool get isBusy =>
      status == ScenarioLabStatus.loading || status == ScenarioLabStatus.saving;

  ScenarioLabState copyWith({
    ScenarioLabStatus? status,
    ScenarioLabTemplate? selectedTemplate,
    Strategy? selectedStrategy,
    ScenarioLabPreview? preview,
    SavedScenarioResult? savedResult,
    String? errorMessage,
    bool clearPreview = false,
    bool clearSavedResult = false,
    bool clearError = false,
  }) {
    return ScenarioLabState(
      status: status ?? this.status,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      selectedStrategy: selectedStrategy ?? this.selectedStrategy,
      preview: clearPreview ? null : preview ?? this.preview,
      savedResult: clearSavedResult ? null : savedResult ?? this.savedResult,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedTemplate,
    selectedStrategy,
    preview,
    savedResult,
    errorMessage,
  ];
}
