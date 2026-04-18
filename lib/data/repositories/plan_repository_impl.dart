import 'package:drift/drift.dart';

import '../../domain/entities/plan.dart';
import '../../domain/enums/strategy.dart';
import '../../domain/repositories/plan_repository.dart';
import '../local/database.dart';
import '../mappers/plan_mapper.dart';

/// Concrete implementation of [PlanRepository] using Drift (SQLite).
///
/// Plans are singleton per scenario — upsert pattern.
class PlanRepositoryImpl implements PlanRepository {
  PlanRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<Plan?> getCurrentPlan({String scenarioId = 'main'}) async {
    final query = _db.select(_db.plansTable)
      ..where((p) => p.scenarioId.equals(scenarioId))
      ..where((p) => p.deletedAt.isNull());

    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<Plan> savePlan(Plan plan) async {
    _validatePlan(plan);
    final now = DateTime.now().toUtc();

    return _db.transaction(() async {
      final current = await getCurrentPlan(scenarioId: plan.scenarioId);
      final updated = (current ?? plan).copyWith(
        id: current?.id ?? plan.id,
        scenarioId: plan.scenarioId,
        strategy: plan.strategy,
        extraMonthlyAmount: plan.extraMonthlyAmount,
        extraPaymentCadence: plan.extraPaymentCadence,
        customOrder: plan.customOrder,
        lastRecastAt: plan.lastRecastAt,
        projectedDebtFreeDate: plan.projectedDebtFreeDate,
        totalInterestProjected: plan.totalInterestProjected,
        totalInterestSaved: plan.totalInterestSaved,
        createdAt: current?.createdAt ?? plan.createdAt,
        updatedAt: now,
        deletedAt: null,
      );

      if (current == null) {
        await _db.into(_db.plansTable).insert(updated.toCompanion());
      } else {
        await (_db.update(
          _db.plansTable,
        )..where((p) => p.id.equals(current.id))).write(updated.toCompanion());
      }

      return updated;
    });
  }

  @override
  Future<void> deletePlan(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.plansTable)..where((p) => p.id.equals(id))).write(
      PlansTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  @override
  Stream<Plan?> watchCurrentPlan({String scenarioId = 'main'}) {
    final query = _db.select(_db.plansTable)
      ..where((p) => p.scenarioId.equals(scenarioId))
      ..where((p) => p.deletedAt.isNull());

    return query.watchSingleOrNull().map((row) => row?.toDomain());
  }

  void _validatePlan(Plan plan) {
    if (plan.extraMonthlyAmount < 0) {
      throw ArgumentError('extraMonthlyAmount must be >= 0');
    }

    if (plan.strategy == Strategy.custom) {
      final customOrder = plan.customOrder;
      if (customOrder == null || customOrder.isEmpty) {
        throw ArgumentError('customOrder required when strategy is custom');
      }

      if (customOrder.any((id) => id.trim().isEmpty)) {
        throw ArgumentError('customOrder cannot contain empty debt IDs');
      }

      if (customOrder.toSet().length != customOrder.length) {
        throw ArgumentError('customOrder cannot contain duplicate debt IDs');
      }
    }
  }
}
