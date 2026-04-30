import 'package:drift/drift.dart';

import '../../domain/entities/interest_rate_history.dart';
import '../../domain/repositories/interest_rate_history_repository.dart';
import '../local/database.dart';
import '../mappers/interest_rate_history_mapper.dart';

class InterestRateHistoryRepositoryImpl
    implements InterestRateHistoryRepository {
  InterestRateHistoryRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Stream<List<InterestRateHistory>> watchByDebtId(String debtId) {
    return (_db.select(_db.interestRateHistoryTable)
          ..where((row) => row.debtId.equals(debtId))
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.effectiveFrom)]))
        .watch()
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  @override
  Future<List<InterestRateHistory>> getByDebtId(String debtId) async {
    final rows =
        await (_db.select(_db.interestRateHistoryTable)
              ..where((row) => row.debtId.equals(debtId))
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.desc(row.effectiveFrom)]))
            .get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<InterestRateHistory?> getById(String id) async {
    final row =
        await (_db.select(_db.interestRateHistoryTable)
              ..where((entry) => entry.id.equals(id))
              ..where((entry) => entry.deletedAt.isNull()))
            .getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<void> addRateHistory(InterestRateHistory rate) async {
    await _validateRateHistory(rate);
    await _db
        .into(_db.interestRateHistoryTable)
        .insert(rate.toInsertCompanion());
  }

  @override
  Future<void> updateRateHistory(InterestRateHistory rate) async {
    await _validateRateHistory(rate);
    await (_db.update(
      _db.interestRateHistoryTable,
    )..where((row) => row.id.equals(rate.id))).write(rate.toUpdateCompanion());
  }

  @override
  Future<bool> deleteRateHistory(String id) async {
    final now = DateTime.now().toUtc();
    final count =
        await (_db.update(
          _db.interestRateHistoryTable,
        )..where((row) => row.id.equals(id))).write(
          InterestRateHistoryTableCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return count > 0;
  }

  Future<void> _validateRateHistory(InterestRateHistory rate) async {
    final effectiveTo = rate.effectiveTo;
    if (effectiveTo != null && effectiveTo.isBefore(rate.effectiveFrom)) {
      throw ArgumentError('effectiveTo must be on or after effectiveFrom');
    }

    final existing = await getByDebtId(rate.debtId);
    final overlapping = existing.any(
      (entry) =>
          entry.id != rate.id &&
          _rangesOverlap(
            startA: rate.effectiveFrom,
            endA: rate.effectiveTo,
            startB: entry.effectiveFrom,
            endB: entry.effectiveTo,
          ),
    );
    if (overlapping) {
      throw ArgumentError('Interest rate history periods cannot overlap');
    }
  }

  bool _rangesOverlap({
    required DateTime startA,
    required DateTime? endA,
    required DateTime startB,
    required DateTime? endB,
  }) {
    final aEndsBeforeB = endA != null && endA.isBefore(startB);
    final bEndsBeforeA = endB != null && endB.isBefore(startA);
    return !aEndsBeforeB && !bEndsBeforeA;
  }
}
