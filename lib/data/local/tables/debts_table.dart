import 'package:drift/drift.dart';

/// Debts table definition for Drift.
///
/// Per financial-engine-spec.md §3.1 (Debt entity)
///
/// All money values stored as INTEGER (cents).
/// APR stored as TEXT (Decimal string) to avoid floating-point issues.
class DebtsTable extends Table {
  @override
  String get tableName => 'debts';

  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get type => text()(); // DebtType enum name
  IntColumn get originalPrincipal => integer()();  // cents
  IntColumn get currentBalance => integer()();     // cents
  TextColumn get apr => text()();                   // Decimal as string
  TextColumn get interestMethod => text()();        // InterestMethod enum
  IntColumn get minimumPayment => integer()();      // cents
  TextColumn get minimumPaymentType => text()();    // MinPaymentType enum
  TextColumn get minimumPaymentPercent => text().nullable()(); // Decimal string
  IntColumn get minimumPaymentFloor => integer().nullable()(); // cents
  TextColumn get paymentCadence => text()();         // PaymentCadence enum
  IntColumn get dueDayOfMonth => integer()();
  DateTimeColumn get firstDueDate => dateTime()();
  TextColumn get status => text()();                 // DebtStatus enum
  DateTimeColumn get pausedUntil => dateTime().nullable()();
  IntColumn get priority => integer().nullable()();
  BoolColumn get excludeFromStrategy => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get paidOffAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
