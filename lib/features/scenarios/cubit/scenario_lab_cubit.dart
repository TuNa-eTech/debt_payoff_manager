import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/scenario_lab_models.dart';
import '../../../core/services/scenario_lab_service.dart';
import '../../../domain/enums/strategy.dart';
import 'scenario_lab_state.dart';

class ScenarioLabCubit extends Cubit<ScenarioLabState> {
  ScenarioLabCubit({required ScenarioLabService scenarioLabService})
    : _scenarioLabService = scenarioLabService,
      super(const ScenarioLabState());

  final ScenarioLabService _scenarioLabService;

  void selectTemplate(ScenarioLabTemplate template) {
    emit(
      state.copyWith(
        selectedTemplate: template,
        status: ScenarioLabStatus.idle,
        clearPreview: true,
        clearSavedResult: true,
        clearError: true,
      ),
    );
  }

  void selectStrategy(Strategy strategy) {
    emit(
      state.copyWith(
        selectedStrategy: strategy,
        status: ScenarioLabStatus.idle,
        clearPreview: true,
        clearSavedResult: true,
        clearError: true,
      ),
    );
  }

  Future<void> previewExtraMonthly({
    required int deltaExtraMonthlyCents,
    String? name,
  }) async {
    await _runPreview(
      () => _scenarioLabService.previewExtraMonthly(
        deltaExtraMonthlyCents: deltaExtraMonthlyCents,
        name: name,
      ),
    );
  }

  Future<void> previewStrategyChange({String? name}) async {
    await _runPreview(
      () => _scenarioLabService.previewStrategyChange(
        strategy: state.selectedStrategy,
        name: name,
      ),
    );
  }

  Future<void> savePreview() async {
    final preview = state.preview;
    if (preview == null) return;
    emit(
      state.copyWith(
        status: ScenarioLabStatus.saving,
        clearError: true,
        clearSavedResult: true,
      ),
    );
    try {
      final result = await _scenarioLabService.savePreview(preview);
      emit(
        state.copyWith(
          status: ScenarioLabStatus.saved,
          savedResult: result,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ScenarioLabStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> activateSavedScenario() async {
    final scenarioId = state.savedResult?.scenario.id;
    if (scenarioId == null) return;
    await _scenarioLabService.activateScenario(scenarioId);
  }

  Future<void> _runPreview(
    Future<ScenarioLabPreview> Function() buildPreview,
  ) async {
    emit(
      state.copyWith(
        status: ScenarioLabStatus.loading,
        clearPreview: true,
        clearSavedResult: true,
        clearError: true,
      ),
    );
    try {
      final preview = await buildPreview();
      emit(
        state.copyWith(
          status: ScenarioLabStatus.previewReady,
          preview: preview,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ScenarioLabStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
