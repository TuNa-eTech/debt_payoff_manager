import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/scenario.dart';
import '../../../domain/repositories/scenario_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../pricing/domain/entitlement_service.dart';
import 'scenarios_state.dart';

class ScenariosCubit extends Cubit<ScenariosState> {
  ScenariosCubit({
    required ScenarioRepository scenarioRepository,
    required SettingsRepository settingsRepository,
    required EntitlementService entitlementService,
  }) : _scenarioRepository = scenarioRepository,
       _settingsRepository = settingsRepository,
       _entitlementService = entitlementService,
       super(const ScenariosState());

  final ScenarioRepository _scenarioRepository;
  final SettingsRepository _settingsRepository;
  final EntitlementService _entitlementService;

  StreamSubscription<void>? _sub;

  void start() {
    _sub = _scenarioRepository.watchAllScenarios().listen((_) => _reload());
  }

  Future<void> _reload() async {
    final scenarios = await _scenarioRepository.getAllScenarios();
    final settings = await _settingsRepository.getSettings();
    emit(
      state.copyWith(
        isLoading: false,
        scenarios: scenarios,
        activeScenarioId: settings.activeScenarioId,
      ),
    );
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
    if (!await _requirePremium()) return;
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
    if (!await _requirePremium()) return;
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
  Future<int> copyDebtsToScenario(String sourceId, String targetId) async {
    if (!await _requirePremium()) return 0;
    return _scenarioRepository.copyDebtsToScenario(sourceId, targetId);
  }

  Future<bool> _requirePremium() async {
    final settings = await _settingsRepository.getSettings();
    if (_entitlementService.isPremiumActive(settings)) {
      return true;
    }
    emit(state.copyWith(error: 'Premium access is required.'));
    return false;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
