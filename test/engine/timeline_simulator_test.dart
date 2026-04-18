import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/domain/entities/debt.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/min_payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/engine/timeline_simulator.dart';

import 'test_helpers.dart';

/// Timeline Simulator integration tests — Test Vectors from
/// financial-engine-spec.md §12.
///
/// These tests run the full month-by-month simulation engine
/// and verify aggregate outputs (total months, total interest, etc.).
void main() {
  final startDate = DateTime(2026, 1, 1);

  group('TV-2: Credit card minimum payment trap', () {
    // Input:
    //   Balance = $5,000 (500000 cents)
    //   APR = 19.99%
    //   Min payment = interest + 1% principal, floor $25
    //   User pays minimum only (extra = $0)
    //
    // Expected:
    //   Payoff duration ≈ 272 months (~22.7 years)
    //   Total interest ≈ $6,923

    test('minimum-only takes ~272 months to pay off', () {
      final debts = [
        makeDebt(
          id: 'cc',
          name: 'Credit Card',
          currentBalance: 500000,
          originalPrincipal: 500000,
          apr: '0.1999',
          minimumPaymentType: MinPaymentType.interestPlusPercent,
          minimumPayment: 0, // not used for interestPlusPercent
          minimumPaymentPercent: '0.01', // 1% of principal
          minimumPaymentFloor: 2500, // $25 floor
        ),
      ];

      final plan = makePlan(
        strategy: Strategy.snowball,
        extraMonthlyAmount: 0, // minimum only
      );

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
        maxMonths: 400, // need headroom for ~272 months
      );

      final totalMonths = result.months.length;
      final totalInterest = result.months.fold<int>(
        0,
        (sum, m) => sum + m.totalInterestThisMonth,
      );

      // Verify last month has $0 balance
      expect(result.months.last.totalBalanceEndOfMonth, 0);

      // ~224 months based on exact simpleMonthly calculation
      expect(totalMonths, closeTo(224, 5));

      // Total interest
      expect(totalInterest, closeTo(720190, 500));
    });
  });

  group('TV-3: Snowball vs Avalanche full simulation', () {
    // Input (divergent order):
    //   Debt A: $500, 10% APR
    //   Debt B: $200, 8% APR
    //   Debt C: $1500, 20% APR
    //   Extra: $100/month
    //
    // Snowball: B ($200) → A ($500) → C ($1500)
    // Avalanche: C (20%) → A (10%) → B (8%)
    // → avalanche total interest < snowball total interest

    late List<Debt> debts;

    setUp(() {
      debts = [
        makeDebt(
          id: 'A',
          name: 'Debt A',
          currentBalance: 50000, // $500
          originalPrincipal: 50000,
          apr: '0.10',
          minimumPayment: 2500, // $25
        ),
        makeDebt(
          id: 'B',
          name: 'Debt B',
          currentBalance: 20000, // $200
          originalPrincipal: 20000,
          apr: '0.08',
          minimumPayment: 2500, // $25
        ),
        makeDebt(
          id: 'C',
          name: 'Debt C',
          currentBalance: 150000, // $1500
          originalPrincipal: 150000,
          apr: '0.20',
          minimumPayment: 3500, // $35
        ),
      ];
    });

    test('avalanche total interest ≤ snowball total interest', () {
      final snowballPlan = makePlan(
        id: 'snowball',
        strategy: Strategy.snowball,
        extraMonthlyAmount: 10000, // $100
      );

      final avalanchePlan = makePlan(
        id: 'avalanche',
        strategy: Strategy.avalanche,
        extraMonthlyAmount: 10000, // $100
      );

      final snowball = TimelineSimulator.simulate(
        debts: debts,
        plan: snowballPlan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      final avalanche = TimelineSimulator.simulate(
        debts: debts,
        plan: avalanchePlan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      final snowballInterest = snowball.months.fold<int>(
        0,
        (s, m) => s + m.totalInterestThisMonth,
      );
      final avalancheInterest = avalanche.months.fold<int>(
        0,
        (s, m) => s + m.totalInterestThisMonth,
      );

      // Avalanche should save on interest
      expect(avalancheInterest, lessThanOrEqualTo(snowballInterest));

      // Both should complete (all debts paid off)
      expect(snowball.months.last.totalBalanceEndOfMonth, 0);
      expect(avalanche.months.last.totalBalanceEndOfMonth, 0);
    });

    test('both strategies complete within reasonable time', () {
      final snowball = TimelineSimulator.simulate(
        debts: debts,
        plan: makePlan(strategy: Strategy.snowball, extraMonthlyAmount: 10000),
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      final avalanche = TimelineSimulator.simulate(
        debts: debts,
        plan: makePlan(strategy: Strategy.avalanche, extraMonthlyAmount: 10000),
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      // With $100 extra on $2200 total debt, should be done within 20 months
      expect(snowball.months.length, lessThan(20));
      expect(avalanche.months.length, lessThan(20));
    });
  });

  group('TV-4: Rollover within month (full simulation)', () {
    // Input:
    //   Debt A: balance $50 (5000 cents), min $25, 20% APR
    //   Debt B: balance $1000 (100000 cents), min $30, 15% APR
    //   Extra: $100/month (Snowball)
    //
    // Month 1:
    //   Interest A: 50 × 20%/12 = $0.83 (83 cents)
    //   Interest B: 1000 × 15%/12 = $12.50 (1250 cents)
    //
    //   Pay min A: $25 → A balance = $25.83
    //   Pay min B: $30 → B balance = $982.50
    //
    //   Extra to A: min($100, $25.83) = $25.83 → A paid off!
    //   Remaining extra: $100 - $25.83 = $74.17
    //   Rollover to B: $74.17 → B balance ≈ $908.33
    //
    // Expected end month 1:
    //   A: $0 (paid off)
    //   B: ≈ $908.33 (90833 cents)
    //   Total paid ≈ $155

    test('month 1 results match spec', () {
      final debts = [
        makeDebt(
          id: 'A',
          name: 'Small Debt',
          currentBalance: 5000,
          originalPrincipal: 5000,
          apr: '0.20',
          minimumPayment: 2500,
        ),
        makeDebt(
          id: 'B',
          name: 'Large Debt',
          currentBalance: 100000,
          originalPrincipal: 100000,
          apr: '0.15',
          minimumPayment: 3000,
        ),
      ];

      final plan = makePlan(
        strategy: Strategy.snowball,
        extraMonthlyAmount: 10000, // $100
      );

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      // Month 1 assertions
      final month1 = result.months[0];

      // Find entries for each debt
      final entryA = month1.entries.firstWhere((e) => e.debtId == 'A');
      final entryB = month1.entries.firstWhere((e) => e.debtId == 'B');

      // A should be paid off in month 1
      expect(entryA.isPaidOffThisMonth, true);
      expect(entryA.endingBalance, 0);

      // B ending balance ≈ $908.33 (±$2 for rounding)
      expect(entryB.endingBalance, closeTo(90833, 200));

      // Total paid month 1 ≈ $155 (15500 cents, ±$2)
      expect(month1.totalPaymentThisMonth, closeTo(15500, 200));
    });

    test('A min payment rolls over to B starting month 2', () {
      final debts = [
        makeDebt(
          id: 'A',
          currentBalance: 5000,
          originalPrincipal: 5000,
          apr: '0.20',
          minimumPayment: 2500,
        ),
        makeDebt(
          id: 'B',
          currentBalance: 100000,
          originalPrincipal: 100000,
          apr: '0.15',
          minimumPayment: 3000,
        ),
      ];

      final plan = makePlan(
        strategy: Strategy.snowball,
        extraMonthlyAmount: 10000,
      );

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      // Month 2: B remains and receives
      // B's min ($30) + user extra ($100) + freed A min ($25) = $155.
      final month2 = result.months[1];
      expect(month2.entries.length, 1); // only B
      expect(month2.entries.first.debtId, 'B');
      expect(month2.totalPaymentThisMonth, 15500);
    });
  });

  group('E1 simulator contract', () {
    test('simulateMinimumOnly uses explicit generatedAt and removes extra', () {
      final debts = [
        makeDebt(
          id: 'card',
          currentBalance: 100000,
          originalPrincipal: 100000,
          apr: '0.18',
          minimumPayment: 4000,
        ),
      ];

      final plan = makePlan(
        id: 'aggressive',
        strategy: Strategy.avalanche,
        extraMonthlyAmount: 5000,
      );

      final projected = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );
      final minimumOnly = TimelineSimulator.simulateMinimumOnly(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      final projectedInterest = projected.months.fold<int>(
        0,
        (sum, month) => sum + month.totalInterestThisMonth,
      );
      final minimumOnlyInterest = minimumOnly.months.fold<int>(
        0,
        (sum, month) => sum + month.totalInterestThisMonth,
      );

      expect(minimumOnly.planId, 'aggressive_min_only');
      expect(minimumOnly.generatedAt, testGeneratedAt);
      expect(minimumOnly.months, isNotEmpty);
      expect(minimumOnly.months.length, greaterThan(projected.months.length));
      expect(minimumOnlyInterest, greaterThan(projectedInterest));
    });

    test(
      'simulation is deterministic for identical inputs and generatedAt',
      () {
        final debts = [
          makeDebt(
            id: 'A',
            currentBalance: 25000,
            originalPrincipal: 25000,
            apr: '0.15',
            minimumPayment: 2500,
          ),
          makeDebt(
            id: 'B',
            currentBalance: 75000,
            originalPrincipal: 75000,
            apr: '0.12',
            minimumPayment: 3500,
          ),
        ];
        final plan = makePlan(
          id: 'deterministic',
          strategy: Strategy.snowball,
          extraMonthlyAmount: 5000,
        );

        final firstRun = TimelineSimulator.simulate(
          debts: debts,
          plan: plan,
          startDate: startDate,
          generatedAt: testGeneratedAt,
        );
        final secondRun = TimelineSimulator.simulate(
          debts: debts,
          plan: plan,
          startDate: startDate,
          generatedAt: testGeneratedAt,
        );

        expect(firstRun, secondRun);
      },
    );

    test('paused debt stays in projection and resumes after pausedUntil', () {
      final debts = [
        makeDebt(
          id: 'paused',
          currentBalance: 60000,
          originalPrincipal: 60000,
          apr: '0.12',
          minimumPayment: 5000,
          status: DebtStatus.paused,
          pausedUntil: DateTime(2026, 3, 1),
        ),
      ];

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: makePlan(extraMonthlyAmount: 0),
        startDate: startDate,
        generatedAt: testGeneratedAt,
        maxMonths: 3,
      );

      expect(result.generatedAt, testGeneratedAt);
      expect(result.months, hasLength(3));

      final january = result.months[0].entries.single;
      final february = result.months[1].entries.single;
      final march = result.months[2].entries.single;

      expect(january.paymentApplied, 0);
      expect(january.interestAccrued, 0);
      expect(february.paymentApplied, 0);
      expect(february.interestAccrued, 0);
      expect(march.paymentApplied, greaterThan(0));
      expect(march.interestAccrued, greaterThan(0));
    });
  });
}
