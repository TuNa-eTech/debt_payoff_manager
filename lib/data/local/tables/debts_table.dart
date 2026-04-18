import 'package:drift/drift.dart';

import '../converters/datetime_converters.dart';
import '../converters/decimal_converter.dart';
import '../converters/enum_converters.dart';

/// Debts table — 1 row = 1 khoản nợ.
///
/// Reference: data-schema.md §3
///
/// All money values stored as INTEGER (cents) with `_cents` suffix.
/// APR stored as TEXT (Decimal string "0.1899" = 18.99%).
/// Enums stored as TEXT (string name).
@DataClassName('DebtRow')
class DebtsTable extends Table {
  @override
  String get tableName => 'debts';

  // Identity & sync
  TextColumn get id => text()();
  TextColumn get scenarioId =>
      text().withDefault(const Constant('main'))();

  // Basic info
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get type => text().map(const DebtTypeConverter())();

  // Money (cents)
  IntColumn get originalPrincipalCents =>
      integer().check(originalPrincipalCents.isBiggerThanValue(0))();
  IntColumn get currentBalanceCents =>
      integer().check(currentBalanceCents.isBiggerOrEqualValue(0))();

  // Interest
  TextColumn get apr => text().map(const DecimalConverter())();
  TextColumn get interestMethod =>
      text().map(const InterestMethodConverter())();

  // Minimum payment
  IntColumn get minimumPaymentCents =>
      integer().withDefault(const Constant(0))();
  TextColumn get minimumPaymentType =>
      text().map(const MinPaymentTypeConverter())();
  TextColumn get minimumPaymentPercent =>
      text().nullable().map(const DecimalConverter())();
  IntColumn get minimumPaymentFloorCents => integer().nullable()();

  // Schedule
  TextColumn get paymentCadence => text().map(const CadenceConverter())();
  IntColumn get dueDayOfMonth => integer()
      .nullable()
      .check(dueDayOfMonth.isBetweenValues(1, 31))();
  TextColumn get firstDueDate => text().map(const LocalDateConverter())();

  // Lifecycle
  TextColumn get status => text().map(const DebtStatusConverter())();
  TextColumn get pausedUntil =>
      text().nullable().map(const LocalDateConverter())();

  // Strategy
  IntColumn get priority => integer().nullable()();
  BoolColumn get excludeFromStrategy =>
      boolean().withDefault(const Constant(false))();

  // Audit
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get paidOffAt =>
      text().nullable().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
