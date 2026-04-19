import '../../core/services/plan_recast_service.dart';
import '../local/stores/sync_state_store.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/plan_repository.dart';
import 'plan_repository_impl.dart';

/// Decorates plan writes with sync bookkeeping and plan recasts.
class TrackedPlanRepository implements PlanRepository {
  TrackedPlanRepository({
    required PlanRepositoryImpl base,
    required SyncStateStore syncStateStore,
    required PlanRecastService planRecastService,
  }) : _base = base,
       _syncStateStore = syncStateStore,
       _planRecastService = planRecastService;

  final PlanRepositoryImpl _base;
  final SyncStateStore _syncStateStore;
  final PlanRecastService _planRecastService;

  @override
  Future<void> deletePlan(String id) async {
    await _base.deletePlan(id);
    await _syncStateStore.markDirty('plans');
    await _planRecastService.recast();
  }

  @override
  Future<Plan?> getCurrentPlan({String scenarioId = 'main'}) {
    return _base.getCurrentPlan(scenarioId: scenarioId);
  }

  @override
  Future<Plan> savePlan(Plan plan) async {
    final saved = await _base.savePlan(plan);
    await _syncStateStore.markDirty('plans');
    final recast = await _planRecastService.recast(scenarioId: saved.scenarioId);
    return recast?.plan ?? saved;
  }

  @override
  Stream<Plan?> watchCurrentPlan({String scenarioId = 'main'}) {
    return _base.watchCurrentPlan(scenarioId: scenarioId);
  }
}
