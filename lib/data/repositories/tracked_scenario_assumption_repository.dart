import '../../domain/entities/scenario_assumption.dart';
import '../../domain/repositories/scenario_assumption_repository.dart';
import '../local/stores/sync_state_store.dart';
import 'scenario_assumption_repository_impl.dart';

class TrackedScenarioAssumptionRepository
    implements ScenarioAssumptionRepository {
  TrackedScenarioAssumptionRepository({
    required ScenarioAssumptionRepositoryImpl base,
    required SyncStateStore syncStateStore,
  }) : _base = base,
       _syncStateStore = syncStateStore;

  final ScenarioAssumptionRepositoryImpl _base;
  final SyncStateStore _syncStateStore;

  @override
  Future<ScenarioAssumption> addAssumption(
    ScenarioAssumption assumption,
  ) async {
    final added = await _base.addAssumption(assumption);
    await _syncStateStore.markDirty('scenarioAssumptions');
    return added;
  }

  @override
  Future<void> deleteAssumption(String id) async {
    await _base.deleteAssumption(id);
    await _syncStateStore.markDirty('scenarioAssumptions');
  }

  @override
  Future<List<ScenarioAssumption>> getByScenario(String scenarioId) {
    return _base.getByScenario(scenarioId);
  }

  @override
  Future<void> updateAssumption(ScenarioAssumption assumption) async {
    await _base.updateAssumption(assumption);
    await _syncStateStore.markDirty('scenarioAssumptions');
  }

  @override
  Stream<List<ScenarioAssumption>> watchByScenario(String scenarioId) {
    return _base.watchByScenario(scenarioId);
  }
}
