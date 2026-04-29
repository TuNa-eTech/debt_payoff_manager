import 'package:drift/drift.dart';

import '../../domain/entities/interest_rate_history.dart';
import '../local/database.dart';

extension InterestRateHistoryRowMapper on InterestRateHistoryRow {
  InterestRateHistory toDomain() {
    return InterestRateHistory(
      id: id,
      debtId: debtId,
      apr: apr,
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
      reason: reason,
    );
  }
}

extension InterestRateHistoryInsertMapper on InterestRateHistory {
  InterestRateHistoryTableCompanion toInsertCompanion() {
    final now = DateTime.now().toUtc();
    return InterestRateHistoryTableCompanion.insert(
      id: Value(id),
      debtId: debtId,
      apr: apr,
      effectiveFrom: effectiveFrom,
      effectiveTo: Value(effectiveTo),
      reason: Value(reason),
      createdAt: now,
      updatedAt: now,
    );
  }

  InterestRateHistoryTableCompanion toUpdateCompanion() {
    return InterestRateHistoryTableCompanion(
      apr: Value(apr),
      effectiveFrom: Value(effectiveFrom),
      effectiveTo: Value(effectiveTo),
      reason: Value(reason),
      updatedAt: Value(DateTime.now().toUtc()),
    );
  }
}
