import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/payment_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/engine/timeline_simulator.dart';

import '../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepo;
  late PaymentRepositoryImpl paymentRepo;
  late PlanRepositoryImpl planRepo;
  late SettingsRepositoryImpl settingsRepo;

  final startDate = DateTime(2026, 1, 1);
  final generatedAt = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    debtRepo = DebtRepositoryImpl(db: db);
    paymentRepo = PaymentRepositoryImpl(db: db);
    planRepo = PlanRepositoryImpl(db: db);
    settingsRepo = SettingsRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('fresh database seeds singleton records for E1', () async {
    final settings = await settingsRepo.getSettings();
    final plan = await planRepo.getCurrentPlan();

    expect(settings.id, 'singleton');
    expect(plan, isNotNull);
    expect(plan!.scenarioId, 'main');
    expect(plan.strategy, Strategy.snowball);
  });

  test('code-only Phase 1 flow produces debt-free projections', () async {
    await debtRepo.addDebt(
      makeRepoDebt(
        id: 'card-a',
        name: 'Card A',
        currentBalance: 50000,
        originalPrincipal: 50000,
        apr: makeRepoDebt().apr,
        minimumPayment: 2500,
      ),
    );
    await debtRepo.addDebt(
      makeRepoDebt(
        id: 'loan-b',
        name: 'Loan B',
        currentBalance: 150000,
        originalPrincipal: 150000,
        apr: Decimal.parse('0.20'),
        minimumPayment: 3500,
      ),
    );

    await paymentRepo.addPayment(
      makeRepoPayment(
        id: 'logged-payment',
        debtId: 'card-a',
        amount: 3000,
        principalPortion: 2200,
        interestPortion: 800,
        appliedBalanceBefore: 50000,
        appliedBalanceAfter: 47800,
      ),
    );

    final debts = await debtRepo.getActiveDebts();
    final seededPlan = await planRepo.getCurrentPlan();
    final snowballPlan = await planRepo.savePlan(
      seededPlan!.copyWith(
        strategy: Strategy.snowball,
        extraMonthlyAmount: 10000,
      ),
    );
    final avalanchePlan = await planRepo.savePlan(
      makeRepoPlan(
        id: 'what-if-avalanche',
        scenarioId: 'what-if-avalanche',
        strategy: Strategy.avalanche,
        extraMonthlyAmount: 10000,
      ),
    );

    final snowball = TimelineSimulator.simulate(
      debts: debts,
      plan: snowballPlan,
      startDate: startDate,
      generatedAt: generatedAt,
    );
    final avalanche = TimelineSimulator.simulate(
      debts: debts,
      plan: avalanchePlan,
      startDate: startDate,
      generatedAt: generatedAt,
    );

    final paymentsForCard = await paymentRepo.getPaymentsForDebt('card-a');
    final snowballInterest = snowball.months.fold<int>(
      0,
      (sum, month) => sum + month.totalInterestThisMonth,
    );
    final avalancheInterest = avalanche.months.fold<int>(
      0,
      (sum, month) => sum + month.totalInterestThisMonth,
    );

    expect(paymentsForCard, hasLength(1));
    expect(snowball.months, isNotEmpty);
    expect(avalanche.months, isNotEmpty);
    expect(snowball.months.last.totalBalanceEndOfMonth, 0);
    expect(avalanche.months.last.totalBalanceEndOfMonth, 0);
    expect(avalancheInterest, lessThanOrEqualTo(snowballInterest));
    expect(snowballPlan.id, seededPlan.id);
  });
}
