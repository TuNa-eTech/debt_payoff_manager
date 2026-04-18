import 'package:decimal/decimal.dart';

import 'package:debt_payoff_manager/domain/entities/debt.dart';
import 'package:debt_payoff_manager/domain/entities/plan.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/domain/enums/interest_method.dart';
import 'package:debt_payoff_manager/domain/enums/min_payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/payment_cadence.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';

/// Shared test helpers for engine tests.
///
/// Provides factory functions so each test file doesn't
/// duplicate boilerplate Debt/Plan construction.
final testGeneratedAt = DateTime.utc(2026, 1, 1, 12);

/// Create a test [Debt] with sensible defaults.
///
/// All money params are in cents.
Debt makeDebt({
  String id = 'test-debt',
  String name = 'Test Debt',
  DebtType type = DebtType.creditCard,
  int originalPrincipal = 500000,
  int currentBalance = 500000,
  String apr = '0.1899',
  InterestMethod interestMethod = InterestMethod.simpleMonthly,
  int minimumPayment = 2500,
  MinPaymentType minimumPaymentType = MinPaymentType.fixed,
  String? minimumPaymentPercent,
  int? minimumPaymentFloor,
  PaymentCadence paymentCadence = PaymentCadence.monthly,
  int dueDayOfMonth = 15,
  DateTime? firstDueDate,
  DebtStatus status = DebtStatus.active,
  DateTime? pausedUntil,
  bool excludeFromStrategy = false,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return Debt(
    id: id,
    name: name,
    type: type,
    originalPrincipal: originalPrincipal,
    currentBalance: currentBalance,
    apr: Decimal.parse(apr),
    interestMethod: interestMethod,
    minimumPayment: minimumPayment,
    minimumPaymentType: minimumPaymentType,
    minimumPaymentPercent: minimumPaymentPercent != null
        ? Decimal.parse(minimumPaymentPercent)
        : null,
    minimumPaymentFloor: minimumPaymentFloor,
    paymentCadence: paymentCadence,
    dueDayOfMonth: dueDayOfMonth,
    firstDueDate: firstDueDate ?? DateTime(2026, 1, 15),
    status: status,
    pausedUntil: pausedUntil,
    excludeFromStrategy: excludeFromStrategy,
    createdAt: now,
    updatedAt: now,
  );
}

/// Create a test [Plan] with sensible defaults.
///
/// [extraMonthlyAmount] is in cents.
Plan makePlan({
  String id = 'test-plan',
  Strategy strategy = Strategy.snowball,
  int extraMonthlyAmount = 0,
  PaymentCadence extraPaymentCadence = PaymentCadence.monthly,
  List<String>? customOrder,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return Plan(
    id: id,
    strategy: strategy,
    extraMonthlyAmount: extraMonthlyAmount,
    extraPaymentCadence: extraPaymentCadence,
    customOrder: customOrder,
    createdAt: now,
    updatedAt: now,
  );
}
