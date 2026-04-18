import 'package:drift/drift.dart';

import '../converters/datetime_converters.dart';
import '../converters/enum_converters.dart';
import 'debts_table.dart';

/// Payments table — log actual or planned payments.
///
/// Reference: data-schema.md §4
///
/// Invariant (repository-level):
///   `amountCents == principalPortionCents + interestPortionCents + feePortionCents`
@DataClassName('PaymentRow')
class PaymentsTable extends Table {
  @override
  String get tableName => 'payments';

  TextColumn get id => text()();
  TextColumn get scenarioId =>
      text().withDefault(const Constant('main'))();
  TextColumn get debtId => text().references(DebtsTable, #id)();

  // Money (cents) — invariant: amount = principal + interest + fee
  IntColumn get amountCents =>
      integer().check(amountCents.isBiggerThanValue(0))();
  IntColumn get principalPortionCents => integer()();
  IntColumn get interestPortionCents => integer()();
  IntColumn get feePortionCents =>
      integer().withDefault(const Constant(0))();

  // Meta
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get type => text().map(const PaymentTypeConverter())();
  TextColumn get source => text().map(const PaymentSourceConverter())();
  TextColumn get note => text().nullable().withLength(max: 200)();
  TextColumn get status => text().map(const PaymentStatusConverter())();

  // Audit trail (snapshot, không update)
  IntColumn get appliedBalanceBeforeCents => integer()();
  IntColumn get appliedBalanceAfterCents => integer()();

  // Standard
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
