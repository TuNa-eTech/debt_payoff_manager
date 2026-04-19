import 'package:equatable/equatable.dart';

import '../../core/extensions/date_extensions.dart';
import '../../core/models/recast_delta.dart';
import '../../core/models/strategy_preview.dart';
import '../../data/local/stores/sync_state_store.dart';
import '../../data/local/stores/timeline_cache_store.dart';
import '../../data/repositories/debt_repository_impl.dart';
import '../../data/repositories/plan_repository_impl.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/timeline_projection.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/strategy.dart';
import '../../engine/timeline_simulator.dart';

/// Rebuilds cached payoff projections and keeps persisted plan summaries fresh.
class PlanRecastService {
  PlanRecastService({
    required DebtRepositoryImpl debtRepository,
    required PlanRepositoryImpl planRepository,
    required SyncStateStore syncStateStore,
    required TimelineCacheStore timelineCacheStore,
  }) : _debtRepository = debtRepository,
       _planRepository = planRepository,
       _syncStateStore = syncStateStore,
       _timelineCacheStore = timelineCacheStore;

  final DebtRepositoryImpl _debtRepository;
  final PlanRepositoryImpl _planRepository;
  final SyncStateStore _syncStateStore;
  final TimelineCacheStore _timelineCacheStore;
  final Map<String, RecastDelta?> _latestDeltaByScenario = {};

  RecastDelta? lastDeltaFor(String scenarioId) {
    return _latestDeltaByScenario[scenarioId];
  }

  Future<PlanRecastResult?> recast({
    String scenarioId = 'main',
    DateTime? referenceDate,
  }) async {
    final plan = await _planRepository.getCurrentPlan(scenarioId: scenarioId);
    if (plan == null) return null;

    final debts = await _debtRepository.getAllDebts(scenarioId: scenarioId);
    final generatedAt = DateTime.now().toUtc();
    final computation = _compute(
      plan: plan,
      debts: debts,
      referenceDate: (referenceDate ?? DateTime.now()).startOfMonth,
      generatedAt: generatedAt,
    );

    final delta = RecastDelta(
      previousDebtFreeDate: plan.projectedDebtFreeDate,
      newDebtFreeDate: computation.projectedDebtFreeDate,
      previousTotalInterestProjected: plan.totalInterestProjected,
      newTotalInterestProjected: computation.totalInterestProjected,
      previousTotalInterestSaved: plan.totalInterestSaved,
      newTotalInterestSaved: computation.totalInterestSaved,
    );

    await _timelineCacheStore.replaceProjection(computation.projection);

    final persisted = await _planRepository.savePlan(
      plan.copyWith(
        lastRecastAt: generatedAt,
        projectedDebtFreeDate: computation.projectedDebtFreeDate,
        totalInterestProjected: computation.totalInterestProjected,
        totalInterestSaved: computation.totalInterestSaved,
        updatedAt: generatedAt,
      ),
    );
    await _syncStateStore.markDirty('plans');

    _latestDeltaByScenario[scenarioId] = delta;

    return PlanRecastResult(
      plan: persisted,
      projection: computation.projection,
      preview: computation.toPreview(persisted.strategy),
      delta: delta,
    );
  }

  Future<StrategyPreview> previewPlan({
    required Plan plan,
    required List<Debt> debts,
    DateTime? referenceDate,
  }) async {
    final computation = _compute(
      plan: plan,
      debts: debts,
      referenceDate: (referenceDate ?? DateTime.now()).startOfMonth,
      generatedAt: DateTime.now().toUtc(),
    );
    return computation.toPreview(plan.strategy);
  }

  _ProjectionComputation _compute({
    required Plan plan,
    required List<Debt> debts,
    required DateTime referenceDate,
    required DateTime generatedAt,
  }) {
    final trackedDebts = debts
        .where((debt) => debt.status != DebtStatus.archived)
        .toList(growable: false);
    final activeDebts = trackedDebts
        .where(
          (debt) =>
              debt.currentBalance > 0 &&
              (debt.status == DebtStatus.active || debt.status == DebtStatus.paused),
        )
        .toList(growable: false);
    final totalBalance = trackedDebts.fold<int>(
      0,
      (sum, debt) => sum + debt.currentBalance,
    );

    if (activeDebts.isEmpty) {
      return _ProjectionComputation(
        projection: TimelineProjection(
          planId: plan.id,
          generatedAt: generatedAt,
          months: const [],
        ),
        projectedDebtFreeDate: referenceDate,
        totalInterestProjected: 0,
        totalInterestSaved: 0,
        totalBalance: totalBalance,
      );
    }

    final projected = TimelineSimulator.simulate(
      debts: trackedDebts,
      plan: plan,
      startDate: referenceDate,
      generatedAt: generatedAt,
    );
    final minimumOnly = TimelineSimulator.simulateMinimumOnly(
      debts: trackedDebts,
      plan: plan,
      startDate: referenceDate,
      generatedAt: generatedAt,
    );

    final totalInterestProjected = projected.months.fold<int>(
      0,
      (sum, month) => sum + month.totalInterestThisMonth,
    );
    final totalInterestMinimumOnly = minimumOnly.months.fold<int>(
      0,
      (sum, month) => sum + month.totalInterestThisMonth,
    );

    return _ProjectionComputation(
      projection: projected,
      projectedDebtFreeDate: _resolveDebtFreeDate(projected, referenceDate),
      totalInterestProjected: totalInterestProjected,
      totalInterestSaved: totalInterestMinimumOnly - totalInterestProjected,
      totalBalance: totalBalance,
    );
  }

  static DateTime _resolveDebtFreeDate(
    TimelineProjection projection,
    DateTime fallbackDate,
  ) {
    if (projection.months.isEmpty) {
      return fallbackDate;
    }

    final lastMonth = projection.months.last.yearMonth.split('-');
    return DateTime(
      int.parse(lastMonth[0]),
      int.parse(lastMonth[1]),
    );
  }
}

class PlanRecastResult extends Equatable {
  const PlanRecastResult({
    required this.plan,
    required this.projection,
    required this.preview,
    required this.delta,
  });

  final Plan plan;
  final TimelineProjection projection;
  final StrategyPreview preview;
  final RecastDelta delta;

  @override
  List<Object?> get props => [plan, projection, preview, delta];
}

class _ProjectionComputation {
  const _ProjectionComputation({
    required this.projection,
    required this.projectedDebtFreeDate,
    required this.totalInterestProjected,
    required this.totalInterestSaved,
    required this.totalBalance,
  });

  final TimelineProjection projection;
  final DateTime projectedDebtFreeDate;
  final int totalInterestProjected;
  final int totalInterestSaved;
  final int totalBalance;

  StrategyPreview toPreview(Strategy strategy) {
    return StrategyPreview(
      strategy: strategy,
      projectedDebtFreeDate: projectedDebtFreeDate,
      projectedMonths: projection.months.length,
      totalInterestProjected: totalInterestProjected,
      totalInterestSaved: totalInterestSaved,
      totalBalance: totalBalance,
    );
  }
}
