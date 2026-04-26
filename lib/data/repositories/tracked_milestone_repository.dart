import '../../domain/entities/milestone.dart';
import '../../domain/enums/milestone_type.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../local/stores/sync_state_store.dart';
import 'milestone_repository_impl.dart';

class TrackedMilestoneRepository implements MilestoneRepository {
  TrackedMilestoneRepository({
    required MilestoneRepositoryImpl base,
    required SyncStateStore syncStateStore,
  }) : _base = base,
       _syncStateStore = syncStateStore;

  final MilestoneRepositoryImpl _base;
  final SyncStateStore _syncStateStore;

  @override
  Future<Milestone> addMilestone(Milestone milestone) async {
    final added = await _base.addMilestone(milestone);
    await _syncStateStore.markDirty('milestones');
    return added;
  }

  @override
  Future<List<Milestone>> getUnseenMilestones({String scenarioId = 'main'}) =>
      _base.getUnseenMilestones(scenarioId: scenarioId);

  @override
  Future<List<Milestone>> getMilestonesForDebt(String debtId) =>
      _base.getMilestonesForDebt(debtId);

  @override
  Future<void> markSeen(String id) => _base.markSeen(id);

  @override
  Future<bool> milestoneExists(MilestoneType type, {String? debtId}) =>
      _base.milestoneExists(type, debtId: debtId);

  @override
  Stream<List<Milestone>> watchUnseenMilestones({String scenarioId = 'main'}) =>
      _base.watchUnseenMilestones(scenarioId: scenarioId);
}
