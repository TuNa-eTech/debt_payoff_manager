import '../../core/services/plan_recast_service.dart';
import '../../domain/entities/interest_rate_history.dart';
import '../../domain/repositories/interest_rate_history_repository.dart';
import '../local/stores/sync_state_store.dart';
import 'debt_repository_impl.dart';
import 'interest_rate_history_repository_impl.dart';

class TrackedInterestRateHistoryRepository
    implements InterestRateHistoryRepository {
  TrackedInterestRateHistoryRepository({
    required InterestRateHistoryRepositoryImpl base,
    required DebtRepositoryImpl debtRepository,
    required SyncStateStore syncStateStore,
    required PlanRecastService planRecastService,
  }) : _base = base,
       _debtRepository = debtRepository,
       _syncStateStore = syncStateStore,
       _planRecastService = planRecastService;

  static const _syncCollection = 'interestRateHistory';

  final InterestRateHistoryRepositoryImpl _base;
  final DebtRepositoryImpl _debtRepository;
  final SyncStateStore _syncStateStore;
  final PlanRecastService _planRecastService;

  @override
  Stream<List<InterestRateHistory>> watchByDebtId(String debtId) =>
      _base.watchByDebtId(debtId);

  @override
  Future<List<InterestRateHistory>> getByDebtId(String debtId) =>
      _base.getByDebtId(debtId);

  @override
  Future<InterestRateHistory?> getById(String id) => _base.getById(id);

  @override
  Future<void> addRateHistory(InterestRateHistory rate) async {
    await _base.addRateHistory(rate);
    await _syncStateStore.markDirty(_syncCollection);
    await _recastDebtScenario(rate.debtId);
  }

  @override
  Future<void> updateRateHistory(InterestRateHistory rate) async {
    await _base.updateRateHistory(rate);
    await _syncStateStore.markDirty(_syncCollection);
    await _recastDebtScenario(rate.debtId);
  }

  @override
  Future<bool> deleteRateHistory(String id) async {
    final current = await _base.getById(id);
    final result = await _base.deleteRateHistory(id);
    if (result) {
      await _syncStateStore.markDirty(_syncCollection);
      if (current != null) {
        await _recastDebtScenario(current.debtId);
      }
    }
    return result;
  }

  Future<void> _recastDebtScenario(String debtId) async {
    final debt = await _debtRepository.getDebtById(debtId);
    if (debt == null) return;
    await _planRecastService.recast(scenarioId: debt.scenarioId);
  }
}
