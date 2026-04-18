import 'package:drift/drift.dart';

import '../converters/datetime_converters.dart';

/// TimelineCache table — cached timeline projection data.
///
/// Reference: data-schema.md §10
///
/// Local only, NOT synced. Recomputed after any change to
/// debts, payments, plans, or interest_rate_history.
@DataClassName('TimelineCacheRow')
class TimelineCacheTable extends Table {
  @override
  String get tableName => 'timeline_cache';

  TextColumn get planId => text()();
  IntColumn get monthIndex => integer()(); // 0 = current month
  TextColumn get yearMonth => text()(); // "2026-04"
  TextColumn get entriesJson => text()(); // JSON [DebtMonthEntry]
  IntColumn get totalPaymentCents => integer()();
  IntColumn get totalInterestCents => integer()();
  IntColumn get totalBalanceEndCents => integer()();
  TextColumn get generatedAt =>
      text().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {planId, monthIndex};
}
