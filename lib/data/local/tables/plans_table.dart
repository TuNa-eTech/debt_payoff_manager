import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../converters/datetime_converters.dart';
import '../converters/enum_converters.dart';

/// Plans table — singleton per scenario.
///
/// Reference: data-schema.md §5
///
/// Invariant: exactly 1 Plan per scenarioId (enforced via unique index).
@TableIndex.sql(
  'CREATE UNIQUE INDEX idx_plans_scenario '
  'ON plans (scenario_id) WHERE deleted_at IS NULL',
)
@DataClassName('PlanRow')
class PlansTable extends Table {
  @override
  String get tableName => 'plans';

  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get scenarioId => text().withDefault(const Constant('main'))();

  // Strategy
  TextColumn get strategy => text().map(const StrategyConverter())();
  IntColumn get extraMonthlyAmountCents =>
      integer().withDefault(const Constant(0))();
  TextColumn get extraPaymentCadence => text().map(const CadenceConverter())();

  // Custom ordering (JSON array of debt IDs)
  TextColumn get customOrderJson => text().nullable()();

  // Cached compute (recomputed on recast)
  TextColumn get lastRecastAt => text().map(const UtcDateTimeConverter())();
  TextColumn get projectedDebtFreeDate =>
      text().nullable().map(const LocalDateConverter())();
  IntColumn get totalInterestProjectedCents => integer().nullable()();
  IntColumn get totalInterestSavedCents => integer().nullable()();

  // Standard
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
