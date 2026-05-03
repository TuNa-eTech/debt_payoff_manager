import '../../domain/entities/scenario.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../local/stores/sync_state_store.dart';
import 'scenario_repository_impl.dart';

class TrackedScenarioRepository implements ScenarioRepository {
  TrackedScenarioRepository({
    required ScenarioRepositoryImpl base,
    required SyncStateStore syncStateStore,
  }) : _base = base,
       _syncStateStore = syncStateStore;

  final ScenarioRepositoryImpl _base;
  final SyncStateStore _syncStateStore;

  @override
  Future<List<Scenario>> getAllScenarios() => _base.getAllScenarios();

  @override
  Stream<List<Scenario>> watchAllScenarios() => _base.watchAllScenarios();

  @override
  Future<Scenario> addScenario(Scenario scenario) async {
    final added = await _base.addScenario(scenario);
    await _syncStateStore.markDirty('scenarios');
    return added;
  }

  @override
  Future<void> renameScenario(String id, String name) async {
    await _base.renameScenario(id, name);
    await _syncStateStore.markDirty('scenarios');
  }

  @override
  Future<bool> deleteScenario(String id) async {
    final result = await _base.deleteScenario(id);
    if (result) await _syncStateStore.markDirty('scenarios');
    return result;
  }

  @override
  Future<String> duplicateScenario(String sourceId, String newName) async {
    final newId = await _base.duplicateScenario(sourceId, newName);
    await _syncStateStore.markDirty('scenarios');
    return newId;
  }

  @override
  Future<int> copyDebtsToScenario(String sourceId, String targetId) async {
    final count = await _base.copyDebtsToScenario(sourceId, targetId);
    if (count > 0) await _syncStateStore.markDirty('scenarios');
    return count;
  }
}
