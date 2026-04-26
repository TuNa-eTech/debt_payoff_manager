import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/scenario.dart';
import '../../../domain/repositories/scenario_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'scenarios_state.dart';

class ScenariosCubit extends Cubit<ScenariosState> {
  ScenariosCubit({
    required ScenarioRepository scenarioRepository,
    required SettingsRepository settingsRepository,
  })  : _scenarioRepository = scenarioRepository,
        _settingsRepository = settingsRepository,
        super(const ScenariosState());

  final ScenarioRepository _scenarioRepository;
  final SettingsRepository _settingsRepository;

  StreamSubscription<void>? _sub;

  void start() {
    _sub = _scenarioRepository.watchAllScenarios().listen((_) => _reload());
  }

  Future<void> _reload() async {
    final scenarios = await _scenarioRepository.getAllScenarios();
    final settings = await _settingsRepository.getSettings();
    emit(state.copyWith(
      isLoading: false,
      scenarios: scenarios,
      activeScenarioId: settings.activeScenarioId,
    ));
  }

  Future<void> setActive(String id) async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.updateSettings(
      settings.copyWith(activeScenarioId: id),
    );
    emit(state.copyWith(activeScenarioId: id));
  }

  Future<void> addScenario(String name) async {
    if (name.trim().isEmpty) return;
    final now = DateTime.now().toUtc();
    final scenario = Scenario(
      id: const Uuid().v4(),
      name: name.trim(),
      createdAt: now,
    );
    await _scenarioRepository.addScenario(scenario);
  }

  Future<void> duplicateScenario(String sourceId, String newName) async {
    if (newName.trim().isEmpty) return;
    await _scenarioRepository.duplicateScenario(sourceId, newName.trim());
  }

  Future<void> deleteScenario(String id) async {
    if (id == 'main') return;
    final deleted = await _scenarioRepository.deleteScenario(id);
    if (deleted && state.activeScenarioId == id) {
      await setActive('main');
    }
  }

  /// Copies all active debts from [sourceId] into [targetId].
  /// Returns the number of debts copied.
  Future<int> copyDebtsToScenario(String sourceId, String targetId) =>
      _scenarioRepository.copyDebtsToScenario(sourceId, targetId);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
