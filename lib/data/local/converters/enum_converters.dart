import 'package:drift/drift.dart';

import '../../../domain/enums/debt_status.dart';
import '../../../domain/enums/debt_type.dart';
import '../../../domain/enums/interest_method.dart';
import '../../../domain/enums/milestone_type.dart';
import '../../../domain/enums/min_payment_type.dart';
import '../../../domain/enums/payment_cadence.dart';
import '../../../domain/enums/payment_type.dart';
import '../../../domain/enums/strategy.dart';

/// Enum ↔ String converters for Drift.
///
/// Stores enum values as their `.name` string (e.g., "creditCard").
/// Parses back using `.byName()`.
///
/// Reference: data-schema.md §2, ADR-007

class DebtTypeConverter extends TypeConverter<DebtType, String> {
  const DebtTypeConverter();

  @override
  DebtType fromSql(String fromDb) => DebtType.values.byName(fromDb);

  @override
  String toSql(DebtType value) => value.name;
}

class DebtStatusConverter extends TypeConverter<DebtStatus, String> {
  const DebtStatusConverter();

  @override
  DebtStatus fromSql(String fromDb) => DebtStatus.values.byName(fromDb);

  @override
  String toSql(DebtStatus value) => value.name;
}

class InterestMethodConverter extends TypeConverter<InterestMethod, String> {
  const InterestMethodConverter();

  @override
  InterestMethod fromSql(String fromDb) =>
      InterestMethod.values.byName(fromDb);

  @override
  String toSql(InterestMethod value) => value.name;
}

class MinPaymentTypeConverter extends TypeConverter<MinPaymentType, String> {
  const MinPaymentTypeConverter();

  @override
  MinPaymentType fromSql(String fromDb) =>
      MinPaymentType.values.byName(fromDb);

  @override
  String toSql(MinPaymentType value) => value.name;
}

class CadenceConverter extends TypeConverter<PaymentCadence, String> {
  const CadenceConverter();

  @override
  PaymentCadence fromSql(String fromDb) =>
      PaymentCadence.values.byName(fromDb);

  @override
  String toSql(PaymentCadence value) => value.name;
}

class PaymentTypeConverter extends TypeConverter<PaymentType, String> {
  const PaymentTypeConverter();

  @override
  PaymentType fromSql(String fromDb) => PaymentType.values.byName(fromDb);

  @override
  String toSql(PaymentType value) => value.name;
}

class PaymentSourceConverter extends TypeConverter<PaymentSource, String> {
  const PaymentSourceConverter();

  @override
  PaymentSource fromSql(String fromDb) => PaymentSource.values.byName(fromDb);

  @override
  String toSql(PaymentSource value) => value.name;
}

class PaymentStatusConverter extends TypeConverter<PaymentStatus, String> {
  const PaymentStatusConverter();

  @override
  PaymentStatus fromSql(String fromDb) => PaymentStatus.values.byName(fromDb);

  @override
  String toSql(PaymentStatus value) => value.name;
}

class StrategyConverter extends TypeConverter<Strategy, String> {
  const StrategyConverter();

  @override
  Strategy fromSql(String fromDb) => Strategy.values.byName(fromDb);

  @override
  String toSql(Strategy value) => value.name;
}

class MilestoneTypeConverter extends TypeConverter<MilestoneType, String> {
  const MilestoneTypeConverter();

  @override
  MilestoneType fromSql(String fromDb) => MilestoneType.values.byName(fromDb);

  @override
  String toSql(MilestoneType value) => value.name;
}
