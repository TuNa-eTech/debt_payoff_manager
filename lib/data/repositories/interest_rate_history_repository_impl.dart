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
          ..where((row) => row.deletedAt.isNull()))
        .watch()
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  @override
  Future<List<InterestRateHistory>> getByDebtId(String debtId) async {
    final rows = await (_db.select(_db.interestRateHistoryTable)
          ..where((row) => row.debtId.equals(debtId))
          ..where((row) => row.deletedAt.isNull()))
        .get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<void> addRateHistory(InterestRateHistory rate) async {
    await _db
        .into(_db.interestRateHistoryTable)
        .insert(rate.toInsertCompanion());
  }

  @override
  Future<void> updateRateHistory(InterestRateHistory rate) async {
    await (_db.update(_db.interestRateHistoryTable)
          ..where((row) => row.id.equals(rate.id)))
        .write(rate.toUpdateCompanion());
  }

  @override
  Future<bool> deleteRateHistory(String id) async {
    final now = DateTime.now().toUtc();
    final count = await (_db.update(_db.interestRateHistoryTable)
          ..where((row) => row.id.equals(id)))
        .write(
          InterestRateHistoryTableCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return count > 0;
  }
}
