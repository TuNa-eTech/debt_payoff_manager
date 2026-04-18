import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/engine/timeline_simulator.dart';

import 'test_helpers.dart';

/// Edge case tests per financial-engine-spec.md §10.
///
/// Covers boundary conditions that could cause incorrect
/// results if not handled properly.
void main() {
  final startDate = DateTime(2026, 1, 1);

  group('Edge case: 0% APR timeline', () {
    // Per §10.6: APR == 0 is valid (medical debt, promo credit card).
    // interest_this_month = 0, balance decreases linearly.

    test('zero interest throughout, balance decreases linearly', () {
      final debts = [
        makeDebt(
          id: 'zero-apr',
          currentBalance: 60000, // $600
          originalPrincipal: 60000,
          apr: '0.0',
          minimumPayment: 10000, // $100 fixed
        ),
      ];

      final plan = makePlan(extraMonthlyAmount: 0);

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      // Should take exactly 6 months: $600 / $100 = 6
      expect(result.months.length, 6);

      // Every month: zero interest
      for (final m in result.months) {
        expect(m.totalInterestThisMonth, 0);
      }

      // Balance decreases by $100 each month
      for (var i = 0; i < result.months.length; i++) {
        final expected = 60000 - (i + 1) * 10000;
        expect(result.months[i].totalBalanceEndOfMonth, expected);
      }

      // Last month balance = 0
      expect(result.months.last.totalBalanceEndOfMonth, 0);
    });
  });

  group('Edge case: Forbearance (paused debt)', () {
    // Per §10.3: pausedUntil — no payments, no interest accrual during pause.

    test('paused debt: no payment, no interest, no balance change', () {
      final debts = [
        makeDebt(
          id: 'paused',
          currentBalance: 100000, // $1000
          originalPrincipal: 100000,
          apr: '0.12',
          minimumPayment: 5000,
          status: DebtStatus.paused,
          pausedUntil: DateTime(2027, 1, 1), // paused for all of 2026
        ),
      ];

      final plan = makePlan(extraMonthlyAmount: 0);

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
        maxMonths: 6,
      );

      // Debt is paused — should be active (in activeIds) but
      // no interest or payment applied.
      // The simulation continues because the debt is still "active"
      // but paused, so it stays in the loop.
      for (final m in result.months) {
        for (final e in m.entries) {
          if (e.debtId == 'paused') {
            expect(e.interestAccrued, 0);
            expect(e.paymentApplied, 0);
            // Balance stays unchanged
            expect(e.endingBalance, 100000);
          }
        }
      }
    });
  });

  group('Edge case: Negative amortization', () {
    // Per §10.1: When min payment < monthly interest,
    // balance increases (negative amortization).

    test('balance increases when payment < interest', () {
      final debts = [
        makeDebt(
          id: 'neg-am',
          currentBalance: 1000000, // $10,000
          originalPrincipal: 1000000,
          apr: '0.24', // 24% APR → ~$200/month interest
          minimumPayment: 5000, // $50 min payment (< $200 interest)
        ),
      ];

      final plan = makePlan(extraMonthlyAmount: 0);

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
        maxMonths: 3,
      );

      // Month 1: balance should INCREASE
      // Interest ≈ $10,000 × 24%/12 = $200
      // Payment = $50
      // Net: balance goes up by ~$150
      final month1 = result.months[0];
      final entry1 = month1.entries.first;
      expect(entry1.endingBalance, greaterThan(1000000));

      // Month 2: balance increases further
      final month2 = result.months[1];
      final entry2 = month2.entries.first;
      expect(entry2.endingBalance, greaterThan(entry1.endingBalance));
    });
  });

  group('Edge case: Single debt paid off immediately', () {
    // Extra > balance → debt paid off month 1.

    test('debt paid off in month 1 when extra exceeds balance', () {
      final debts = [
        makeDebt(
          id: 'tiny',
          currentBalance: 5000, // $50
          originalPrincipal: 5000,
          apr: '0.10',
          minimumPayment: 2500, // $25
        ),
      ];

      final plan = makePlan(
        strategy: Strategy.snowball,
        extraMonthlyAmount: 50000, // $500 extra — way more than needed
      );

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      // Should be paid off in month 1
      expect(result.months.length, 1);
      expect(result.months.first.totalBalanceEndOfMonth, 0);
      expect(result.months.first.entries.first.isPaidOffThisMonth, true);
    });
  });

  group('Edge case: All debts excluded from strategy', () {
    // Only minimum payments are made, no extra applied.

    test('excluded debts only receive minimum payments', () {
      final debts = [
        makeDebt(
          id: 'excluded',
          currentBalance: 100000, // $1000
          originalPrincipal: 100000,
          apr: '0.10',
          minimumPayment: 5000, // $50
          excludeFromStrategy: true,
        ),
      ];

      final plan = makePlan(
        strategy: Strategy.snowball,
        extraMonthlyAmount: 50000, // $500 extra — but excluded!
      );

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
        maxMonths: 3,
      );

      // Month 1: should only pay minimum ($50), not extra
      final month1 = result.months[0];
      final entry = month1.entries.first;

      // Payment should be just the minimum (interest + whatever min covers)
      // Interest = $1000 × 10%/12 ≈ $8.33
      // Min payment = $50
      // No extra because excluded
      expect(entry.paymentApplied, closeTo(5000, 100));
    });
  });

  group('Edge case: Multiple debts, one paid off mid-simulation', () {
    test('simulation continues with remaining debts after one pays off', () {
      final debts = [
        makeDebt(
          id: 'small',
          currentBalance: 10000, // $100
          originalPrincipal: 10000,
          apr: '0.05',
          minimumPayment: 5000,
        ),
        makeDebt(
          id: 'large',
          currentBalance: 500000, // $5000
          originalPrincipal: 500000,
          apr: '0.15',
          minimumPayment: 10000,
        ),
      ];

      final plan = makePlan(
        strategy: Strategy.snowball,
        extraMonthlyAmount: 5000, // $50 extra
      );

      final result = TimelineSimulator.simulate(
        debts: debts,
        plan: plan,
        startDate: startDate,
        generatedAt: testGeneratedAt,
      );

      // Small debt should be paid off early
      final paidOffMonth = result.months.indexWhere(
        (m) =>
            m.entries.any((e) => e.debtId == 'small' && e.isPaidOffThisMonth),
      );
      expect(paidOffMonth, lessThan(3)); // within first 3 months

      // After that, only large debt remains
      final afterPayoff = result.months[paidOffMonth + 1];
      final largeOnly = afterPayoff.entries.where((e) => e.debtId == 'large');
      expect(largeOnly.length, 1);

      // Simulation eventually completes
      expect(result.months.last.totalBalanceEndOfMonth, 0);
    });
  });
}
