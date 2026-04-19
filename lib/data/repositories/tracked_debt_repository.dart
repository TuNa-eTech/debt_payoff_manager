import '../../core/services/plan_recast_service.dart';
import '../local/stores/sync_state_store.dart';
import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';
import 'debt_repository_impl.dart';

/// Decorates debt writes with sync bookkeeping and plan recasts.
class TrackedDebtRepository implements DebtRepository {
  TrackedDebtRepository({
    required DebtRepositoryImpl base,
    required SyncStateStore syncStateStore,
    required PlanRecastService planRecastService,
  }) : _base = base,
       _syncStateStore = syncStateStore,
       _planRecastService = planRecastService;

  final DebtRepositoryImpl _base;
  final SyncStateStore _syncStateStore;
  final PlanRecastService _planRecastService;

  @override
  Future<Debt> addDebt(Debt debt) async {
    final added = await _base.addDebt(debt);
    await _syncStateStore.markDirty('debts');
    await _planRecastService.recast(scenarioId: added.scenarioId);
    return added;
  }

  @override
  Future<void> deleteDebt(String id) async {
    await _base.deleteDebt(id);
    await _syncStateStore.markDirty('debts');
    await _planRecastService.recast();
  }

  @override
  Future<List<Debt>> getActiveDebts({String scenarioId = 'main'}) {
    return _base.getActiveDebts(scenarioId: scenarioId);
  }

  @override
  Future<List<Debt>> getAllDebts({
    String scenarioId = 'main',
    List<String>? statusFilter,
  }) {
    return _base.getAllDebts(scenarioId: scenarioId, statusFilter: statusFilter);
  }

  @override
  Future<Debt?> getDebtById(String id) {
    return _base.getDebtById(id);
  }

  @override
  Future<void> restoreDebt(String id) async {
    await _base.restoreDebt(id);
    await _syncStateStore.markDirty('debts');
    await _planRecastService.recast();
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    await _base.updateDebt(debt);
    await _syncStateStore.markDirty('debts');
    await _planRecastService.recast(scenarioId: debt.scenarioId);
  }

  @override
  Stream<List<Debt>> watchActiveDebts({String scenarioId = 'main'}) {
    return _base.watchActiveDebts(scenarioId: scenarioId);
  }

  @override
  Stream<List<Debt>> watchAllDebts({String scenarioId = 'main'}) {
    return _base.watchAllDebts(scenarioId: scenarioId);
  }

  @override
  Stream<Debt?> watchDebtById(String id) {
    return _base.watchDebtById(id);
  }
}
