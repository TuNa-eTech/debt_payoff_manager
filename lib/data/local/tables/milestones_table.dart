import 'package:drift/drift.dart';

import '../converters/datetime_converters.dart';
import '../converters/enum_converters.dart';
import 'debts_table.dart';

/// Milestones table — progress & motivation tracking.
///
/// Reference: data-schema.md §8
///
/// Tracks user achievements. `debtId` is nullable because some
/// milestones are global (e.g., allDebtFree, streaks).
@DataClassName('MilestoneRow')
class MilestonesTable extends Table {
  @override
  String get tableName => 'milestones';

  TextColumn get id => text()();
  TextColumn get scenarioId =>
      text().withDefault(const Constant('main'))();

  // Milestone info
  TextColumn get type => text().map(const MilestoneTypeConverter())();
  TextColumn get debtId =>
      text().nullable().references(DebtsTable, #id)();
  TextColumn get achievedAt =>
      text().map(const UtcDateTimeConverter())();
  BoolColumn get seen =>
      boolean().withDefault(const Constant(false))();
  TextColumn get metadata => text().nullable()(); // JSON

  // Standard
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
