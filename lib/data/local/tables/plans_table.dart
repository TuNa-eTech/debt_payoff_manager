import 'package:drift/drift.dart';

/// Plans table definition for Drift.
///
/// Per financial-engine-spec.md §3.3 (Plan entity)
class PlansTable extends Table {
  @override
  String get tableName => 'plans';

  TextColumn get id => text()();
  TextColumn get strategy => text()();             // Strategy enum
  IntColumn get extraMonthlyAmount => integer()(); // cents
  TextColumn get extraPaymentCadence => text()();  // PaymentCadence enum
  TextColumn get customOrder => text().nullable()(); // JSON array of debt IDs
  DateTimeColumn get lastRecastAt => dateTime().nullable()();
  DateTimeColumn get projectedDebtFreeDate => dateTime().nullable()();
  IntColumn get totalInterestProjected => integer().nullable()();
  IntColumn get totalInterestSavedVsMinimumOnly => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
