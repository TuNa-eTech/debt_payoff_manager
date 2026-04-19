import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../domain/entities/timeline_projection.dart';
import '../database.dart';

/// Local helper for timeline projection cache rows.
class TimelineCacheStore {
  TimelineCacheStore({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Future<void> replaceProjection(TimelineProjection projection) async {
    await _db.transaction(() async {
      await clearPlan(projection.planId);
      for (final month in projection.months) {
        await _db.into(_db.timelineCacheTable).insert(
              TimelineCacheTableCompanion.insert(
                planId: projection.planId,
                monthIndex: month.monthIndex,
                yearMonth: month.yearMonth,
                entriesJson: jsonEncode(
                  month.entries.map(_entryToJson).toList(growable: false),
                ),
                totalPaymentCents: month.totalPaymentThisMonth,
                totalInterestCents: month.totalInterestThisMonth,
                totalBalanceEndCents: month.totalBalanceEndOfMonth,
                generatedAt: projection.generatedAt,
              ),
            );
      }
    });
  }

  Future<void> clearPlan(String planId) async {
    await (_db.delete(_db.timelineCacheTable)
          ..where((row) => row.planId.equals(planId)))
        .go();
  }

  Future<TimelineProjection?> getProjection(String planId) async {
    final rows = await (_db.select(_db.timelineCacheTable)
          ..where((row) => row.planId.equals(planId))
          ..orderBy([(row) => OrderingTerm.asc(row.monthIndex)]))
        .get();

    return _rowsToProjection(planId, rows);
  }

  Stream<TimelineProjection?> watchProjection(String planId) {
    return (_db.select(_db.timelineCacheTable)
          ..where((row) => row.planId.equals(planId))
          ..orderBy([(row) => OrderingTerm.asc(row.monthIndex)]))
        .watch()
        .map((rows) => _rowsToProjection(planId, rows));
  }

  TimelineProjection? _rowsToProjection(
    String planId,
    List<TimelineCacheRow> rows,
  ) {
    if (rows.isEmpty) return null;

    return TimelineProjection(
      planId: planId,
      generatedAt: rows.first.generatedAt,
      months: rows
          .map(
            (row) => MonthProjection(
              monthIndex: row.monthIndex,
              yearMonth: row.yearMonth,
              entries: (jsonDecode(row.entriesJson) as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .map(_entryFromJson)
                  .toList(growable: false),
              totalPaymentThisMonth: row.totalPaymentCents,
              totalInterestThisMonth: row.totalInterestCents,
              totalBalanceEndOfMonth: row.totalBalanceEndCents,
            ),
          )
          .toList(growable: false),
    );
  }

  static Map<String, dynamic> _entryToJson(DebtMonthEntry entry) => {
        'debtId': entry.debtId,
        'startingBalance': entry.startingBalance,
        'interestAccrued': entry.interestAccrued,
        'paymentApplied': entry.paymentApplied,
        'principalPortion': entry.principalPortion,
        'interestPortion': entry.interestPortion,
        'endingBalance': entry.endingBalance,
        'isPaidOffThisMonth': entry.isPaidOffThisMonth,
      };

  static DebtMonthEntry _entryFromJson(Map<String, dynamic> json) {
    return DebtMonthEntry(
      debtId: json['debtId'] as String,
      startingBalance: json['startingBalance'] as int,
      interestAccrued: json['interestAccrued'] as int,
      paymentApplied: json['paymentApplied'] as int,
      principalPortion: json['principalPortion'] as int,
      interestPortion: json['interestPortion'] as int,
      endingBalance: json['endingBalance'] as int,
      isPaidOffThisMonth: json['isPaidOffThisMonth'] as bool? ?? false,
    );
  }
}
