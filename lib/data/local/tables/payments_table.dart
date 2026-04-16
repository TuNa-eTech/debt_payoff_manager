import 'package:drift/drift.dart';

/// Payments table definition for Drift.
///
/// Per financial-engine-spec.md §3.2 (Payment entity)
class PaymentsTable extends Table {
  @override
  String get tableName => 'payments';

  TextColumn get id => text()();
  TextColumn get debtId => text()();
  IntColumn get amount => integer()();             // cents
  IntColumn get principalPortion => integer()();   // cents
  IntColumn get interestPortion => integer()();    // cents
  IntColumn get feePortion => integer().withDefault(const Constant(0))();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()();                  // PaymentType enum
  TextColumn get source => text()();                // PaymentSource enum
  TextColumn get note => text().nullable()();
  TextColumn get status => text()();                // PaymentStatus enum
  IntColumn get appliedBalanceBefore => integer()(); // cents
  IntColumn get appliedBalanceAfter => integer()();  // cents
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
