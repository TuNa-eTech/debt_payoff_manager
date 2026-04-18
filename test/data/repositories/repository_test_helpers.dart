import 'package:decimal/decimal.dart';

import 'package:debt_payoff_manager/domain/entities/debt.dart';
import 'package:debt_payoff_manager/domain/entities/milestone.dart';
import 'package:debt_payoff_manager/domain/entities/payment.dart';
import 'package:debt_payoff_manager/domain/entities/plan.dart';
import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/domain/enums/interest_method.dart';
import 'package:debt_payoff_manager/domain/enums/milestone_type.dart';
import 'package:debt_payoff_manager/domain/enums/min_payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/payment_cadence.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';

DateTime localDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

Debt makeRepoDebt({
  String id = 'debt-1',
  String scenarioId = 'main',
  String name = 'Credit Card',
  DebtType type = DebtType.creditCard,
  int originalPrincipal = 500000,
  int currentBalance = 480000,
  Decimal? apr,
  InterestMethod interestMethod = InterestMethod.simpleMonthly,
  int minimumPayment = 5000,
  MinPaymentType minimumPaymentType = MinPaymentType.fixed,
  Decimal? minimumPaymentPercent,
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
    scenarioId: scenarioId,
    name: name,
    type: type,
    originalPrincipal: originalPrincipal,
    currentBalance: currentBalance,
    apr: apr ?? Decimal.parse('0.1899'),
    interestMethod: interestMethod,
    minimumPayment: minimumPayment,
    minimumPaymentType: minimumPaymentType,
    minimumPaymentPercent: minimumPaymentPercent,
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

Plan makeRepoPlan({
  String id = 'plan-1',
  String scenarioId = 'main',
  Strategy strategy = Strategy.snowball,
  int extraMonthlyAmount = 0,
  PaymentCadence extraPaymentCadence = PaymentCadence.monthly,
  List<String>? customOrder,
  DateTime? lastRecastAt,
  DateTime? projectedDebtFreeDate,
  int? totalInterestProjected,
  int? totalInterestSaved,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return Plan(
    id: id,
    scenarioId: scenarioId,
    strategy: strategy,
    extraMonthlyAmount: extraMonthlyAmount,
    extraPaymentCadence: extraPaymentCadence,
    customOrder: customOrder,
    lastRecastAt: lastRecastAt ?? now,
    projectedDebtFreeDate: projectedDebtFreeDate,
    totalInterestProjected: totalInterestProjected,
    totalInterestSaved: totalInterestSaved,
    createdAt: now,
    updatedAt: now,
  );
}

Payment makeRepoPayment({
  String id = 'payment-1',
  String scenarioId = 'main',
  String debtId = 'debt-1',
  int amount = 5000,
  int principalPortion = 4200,
  int interestPortion = 800,
  int feePortion = 0,
  DateTime? date,
  PaymentType type = PaymentType.minimum,
  PaymentSource source = PaymentSource.manual,
  String? note = 'January payment',
  PaymentStatus status = PaymentStatus.completed,
  int appliedBalanceBefore = 480000,
  int appliedBalanceAfter = 475800,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return Payment(
    id: id,
    scenarioId: scenarioId,
    debtId: debtId,
    amount: amount,
    principalPortion: principalPortion,
    interestPortion: interestPortion,
    feePortion: feePortion,
    date: localDay(date ?? DateTime.now()),
    type: type,
    source: source,
    note: note,
    status: status,
    appliedBalanceBefore: appliedBalanceBefore,
    appliedBalanceAfter: appliedBalanceAfter,
    createdAt: now,
    updatedAt: now,
  );
}

Milestone makeRepoMilestone({
  String id = 'milestone-1',
  String scenarioId = 'main',
  MilestoneType type = MilestoneType.firstPayment,
  String? debtId,
  DateTime? achievedAt,
  bool seen = false,
  String? metadata = '{"savedAmount": 1200}',
}) {
  final now = DateTime.utc(2026, 1, 1);
  return Milestone(
    id: id,
    scenarioId: scenarioId,
    type: type,
    debtId: debtId,
    achievedAt: achievedAt ?? now,
    seen: seen,
    metadata: metadata,
    createdAt: now,
  );
}

UserSettings makeRepoSettings({
  String id = 'singleton',
  int trustLevel = 0,
  String? firebaseUid,
  String currencyCode = 'USD',
  String localeCode = 'en-US',
  String dayCountConvention = 'actual365',
  bool notifPaymentReminder = true,
  int notifPaymentReminderDaysBefore = 3,
  bool notifMilestone = true,
  bool notifMonthlyLog = true,
  int onboardingStep = 0,
  bool onboardingCompleted = false,
  DateTime? onboardingCompletedAt,
  bool isPremium = false,
  DateTime? premiumExpiresAt,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return UserSettings(
    id: id,
    trustLevel: trustLevel,
    firebaseUid: firebaseUid,
    currencyCode: currencyCode,
    localeCode: localeCode,
    dayCountConvention: dayCountConvention,
    notifPaymentReminder: notifPaymentReminder,
    notifPaymentReminderDaysBefore: notifPaymentReminderDaysBefore,
    notifMilestone: notifMilestone,
    notifMonthlyLog: notifMonthlyLog,
    onboardingStep: onboardingStep,
    onboardingCompleted: onboardingCompleted,
    onboardingCompletedAt: onboardingCompletedAt,
    isPremium: isPremium,
    premiumExpiresAt: premiumExpiresAt,
    createdAt: now,
    updatedAt: now,
  );
}
