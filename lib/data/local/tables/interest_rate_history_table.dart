import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../converters/datetime_converters.dart';
import '../converters/decimal_converter.dart';
import 'debts_table.dart';

/// InterestRateHistory table — APR change history per debt.
///
/// Reference: data-schema.md §6
///
/// Used for promo rates, refinancing (Tier 2 feature 2.2).
/// `effectiveTo == null` means the rate is currently active.
@DataClassName('InterestRateHistoryRow')
class InterestRateHistoryTable extends Table {
  @override
  String get tableName => 'interest_rate_history';

  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get debtId => text().references(DebtsTable, #id)();

  TextColumn get apr => text().map(const DecimalConverter())();
  TextColumn get effectiveFrom => text().map(const LocalDateConverter())();
  TextColumn get effectiveTo =>
      text().nullable().map(const LocalDateConverter())();
  TextColumn get reason => text().nullable().withLength(max: 120)();

  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
