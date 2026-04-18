import 'package:drift/drift.dart';

import '../../domain/entities/milestone.dart';
import '../../domain/enums/milestone_type.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../local/database.dart';
import '../mappers/milestone_mapper.dart';

/// Concrete implementation of [MilestoneRepository] using Drift (SQLite).
class MilestoneRepositoryImpl implements MilestoneRepository {
  MilestoneRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<List<Milestone>> getUnseenMilestones({
    String scenarioId = 'main',
  }) async {
    final query = _db.select(_db.milestonesTable)
      ..where((m) => m.scenarioId.equals(scenarioId))
      ..where((m) => m.seen.equals(false))
      ..where((m) => m.deletedAt.isNull())
      ..orderBy([(m) => OrderingTerm.desc(m.achievedAt)]);

    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<List<Milestone>> getMilestonesForDebt(String debtId) async {
    final query = _db.select(_db.milestonesTable)
      ..where((m) => m.debtId.equals(debtId))
      ..where((m) => m.deletedAt.isNull())
      ..orderBy([(m) => OrderingTerm.desc(m.achievedAt)]);

    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Milestone> addMilestone(Milestone milestone) async {
    // Check uniqueness: (type, debtId) pair should be unique
    final exists = await milestoneExists(
      milestone.type,
      debtId: milestone.debtId,
    );
    if (exists) {
      throw ArgumentError(
        'Milestone ${milestone.type.name} already exists'
        '${milestone.debtId != null ? ' for debt ${milestone.debtId}' : ''}',
      );
    }

    await _db.into(_db.milestonesTable).insert(milestone.toCompanion());
    return milestone;
  }

  @override
  Future<void> markSeen(String id) async {
    await (_db.update(_db.milestonesTable)
          ..where((m) => m.id.equals(id)))
        .write(const MilestonesTableCompanion(seen: Value(true)));
  }

  @override
  Future<bool> milestoneExists(
    MilestoneType type, {
    String? debtId,
  }) async {
    final query = _db.select(_db.milestonesTable)
      ..where((m) => m.type.equals(type.name))
      ..where((m) => m.deletedAt.isNull());

    if (debtId != null) {
      query.where((m) => m.debtId.equals(debtId));
    } else {
      query.where((m) => m.debtId.isNull());
    }

    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Stream<List<Milestone>> watchUnseenMilestones({
    String scenarioId = 'main',
  }) {
    final query = _db.select(_db.milestonesTable)
      ..where((m) => m.scenarioId.equals(scenarioId))
      ..where((m) => m.seen.equals(false))
      ..where((m) => m.deletedAt.isNull())
      ..orderBy([(m) => OrderingTerm.desc(m.achievedAt)]);

    return query.watch().map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }
}
