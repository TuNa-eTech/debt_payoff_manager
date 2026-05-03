import 'package:drift/drift.dart';

import '../../domain/entities/scenario_assumption.dart';
import '../../domain/repositories/scenario_assumption_repository.dart';
import '../local/database.dart';
import '../mappers/scenario_assumption_mapper.dart';

class ScenarioAssumptionRepositoryImpl implements ScenarioAssumptionRepository {
  ScenarioAssumptionRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<List<ScenarioAssumption>> getByScenario(String scenarioId) async {
    final query = _db.select(_db.scenarioAssumptionsTable)
      ..where((row) => row.scenarioId.equals(scenarioId))
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    final rows = await query.get();
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }

  @override
  Stream<List<ScenarioAssumption>> watchByScenario(String scenarioId) {
    final query = _db.select(_db.scenarioAssumptionsTable)
      ..where((row) => row.scenarioId.equals(scenarioId))
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
    );
  }

  @override
  Future<ScenarioAssumption> addAssumption(
    ScenarioAssumption assumption,
  ) async {
    await _db
        .into(_db.scenarioAssumptionsTable)
        .insert(assumption.toCompanion());
    return assumption;
  }

  @override
  Future<void> updateAssumption(ScenarioAssumption assumption) async {
    final updated = assumption.copyWith(updatedAt: DateTime.now().toUtc());
    await (_db.update(_db.scenarioAssumptionsTable)
          ..where((row) => row.id.equals(assumption.id)))
        .write(updated.toCompanion());
  }

  @override
  Future<void> deleteAssumption(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(
      _db.scenarioAssumptionsTable,
    )..where((row) => row.id.equals(id))).write(
      ScenarioAssumptionsTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
