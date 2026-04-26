import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/scenario.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../local/database.dart';
import '../mappers/debt_mapper.dart';
import '../mappers/plan_mapper.dart';
import '../mappers/scenario_mapper.dart';

class ScenarioRepositoryImpl implements ScenarioRepository {
  ScenarioRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;
  final _uuid = const Uuid();

  @override
  Future<List<Scenario>> getAllScenarios() async {
    final query = _db.select(_db.scenariosTable)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]);
    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Stream<List<Scenario>> watchAllScenarios() {
    final query = _db.select(_db.scenariosTable)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]);
    return query.watch().map(
      (rows) => rows.map((r) => r.toDomain()).toList(),
    );
  }

  @override
  Future<Scenario> addScenario(Scenario scenario) async {
    await _db.into(_db.scenariosTable).insert(scenario.toCompanion());
    return scenario;
  }

  @override
  Future<bool> deleteScenario(String id) async {
    if (id == 'main') return false;
    final now = DateTime.now().toUtc();
    await (_db.update(_db.scenariosTable)..where((s) => s.id.equals(id)))
        .write(ScenariosTableCompanion(deletedAt: Value(now)));
    return true;
  }

  @override
  Future<String> duplicateScenario(String sourceId, String newName) async {
    final newId = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _db.transaction(() async {
      // Copy scenario metadata
      await _db.into(_db.scenariosTable).insert(
        ScenariosTableCompanion.insert(
          id: Value(newId),
          name: newName,
          createdAt: now,
        ),
      );

      // Copy debts (new IDs, new scenarioId, reset balance to original)
      final sourceDebts = await (_db.select(_db.debtsTable)
            ..where((d) => d.scenarioId.equals(sourceId))
            ..where((d) => d.deletedAt.isNull()))
          .get();

      for (final debtRow in sourceDebts) {
        final debt = debtRow.toDomain();
        final newDebtId = _uuid.v4();
        await _db.into(_db.debtsTable).insert(
          debt
              .copyWith(
                id: newDebtId,
                scenarioId: newId,
                currentBalance: debt.originalPrincipal,
                createdAt: now,
                updatedAt: now,
              )
              .toCompanion(),
        );
      }

      // Copy plan (new scenarioId)
      final sourcePlan = await (_db.select(_db.plansTable)
            ..where((p) => p.scenarioId.equals(sourceId))
            ..where((p) => p.deletedAt.isNull()))
          .getSingleOrNull();

      if (sourcePlan != null) {
        final plan = sourcePlan.toDomain();
        await _db.into(_db.plansTable).insert(
          plan
              .copyWith(
                id: _uuid.v4(),
                scenarioId: newId,
                lastRecastAt: now,
                projectedDebtFreeDate: null,
                totalInterestProjected: null,
                totalInterestSaved: null,
                createdAt: now,
                updatedAt: now,
              )
              .toCompanion(),
        );
      }
    });

    return newId;
  }
}
