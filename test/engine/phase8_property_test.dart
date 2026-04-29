import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test;

import 'package:debt_payoff_manager/domain/entities/interest_rate_history.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/engine/timeline_simulator.dart';

import 'test_helpers.dart';

/// Property-based tests for Phase 8 features:
/// forbearance/pause, interest rate change, new charge (balance increase).
///
/// Properties are directional invariants — not exact values,
/// only monotonic relationships that must hold across arbitrary inputs.
void main() {
  final startDate = DateTime(2026, 1, 1);
  final generatedAt = DateTime(2026, 1, 1, 12);

  // ── Generators ──────────────────────────────────────────────────────────

  final aprGen = any.int.map((i) {
    final bp = (i.abs() % 2200) + 300; // 3.00%–24.99%
    return Decimal.parse((bp / 10000).toStringAsFixed(4));
  });

  final aprDeltaGen = any.int.map((i) {
    final bp = (i.abs() % 500) + 100; // 1.00%–6.00% increase
    return Decimal.parse((bp / 10000).toStringAsFixed(4));
  });

  final balanceGen = any.int.map((i) => (i.abs() % 90000) + 10000); // $100–$1000

  final chargeDeltaGen = any.int.map((i) => (i.abs() % 50000) + 1000); // $10–$510

  // ── Helper ──────────────────────────────────────────────────────────────

  int safeMinimum(int balanceCents, Decimal apr) {
    final monthlyInterest = (balanceCents * apr.toDouble() / 12).ceil();
    return (monthlyInterest + 1000).clamp(2500, balanceCents);
  }

  // Pause window: months Jan–Mar 2026; resume April 2026.
  // MonthProjection.yearMonth is "YYYY-MM" so string compare works.
  const pauseWindowEnd = '2026-04'; // exclusive

  // ── Group 1: Forbearance/Pause ───────────────────────────────────────────

  group('Phase 8 — Forbearance properties', () {
    Glados2(balanceGen, aprGen).test(
      'paused debt receives no principal payment during pause window',
      (balance, apr) {
        final pauseUntil = DateTime(2026, 4, 1);
        final debt = makeDebt(
          id: 'paused-debt',
          currentBalance: balance,
          apr: apr.toString(),
          minimumPayment: safeMinimum(balance, apr),
          status: DebtStatus.paused,
          pausedUntil: pauseUntil,
        );
        final plan = makePlan(extraMonthlyAmount: 5000);

        final projection = TimelineSimulator.simulate(
          debts: [debt],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );

        for (final month in projection.months) {
          if (month.yearMonth.compareTo(pauseWindowEnd) < 0) {
            final entry = month.entries
                .where((e) => e.debtId == 'paused-debt')
                .firstOrNull;
            if (entry != null) {
              expect(
                entry.principalPortion,
                equals(0),
                reason:
                    'Paused debt must not receive principal on ${month.yearMonth}',
              );
            }
          }
        }
      },
    );

    Glados2(balanceGen, aprGen).test(
      'paused then resumed debt eventually pays off',
      (balance, apr) {
        final pauseUntil = DateTime(2026, 3, 1);
        final debt = makeDebt(
          id: 'resume-debt',
          currentBalance: balance,
          apr: apr.toString(),
          minimumPayment: safeMinimum(balance, apr),
          status: DebtStatus.paused,
          pausedUntil: pauseUntil,
        );
        final plan = makePlan(extraMonthlyAmount: 10000);

        final projection = TimelineSimulator.simulate(
          debts: [debt],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );

        // Simulation must fully pay off (last month balance = 0)
        expect(
          projection.months.last.totalBalanceEndOfMonth,
          equals(0),
          reason: 'Debt must eventually reach zero after resume',
        );
      },
    );
  });

  // ── Group 2: Interest Rate Change ───────────────────────────────────────

  group('Phase 8 — Interest rate change properties', () {
    Glados3(balanceGen, aprGen, aprDeltaGen).test(
      'higher APR yields timeline that is same length or longer',
      (balance, baseApr, delta) {
        final higherApr = baseApr + delta;
        final minPayment = safeMinimum(balance, higherApr);

        final debtBase = makeDebt(
          id: 'debt-base',
          currentBalance: balance,
          apr: baseApr.toString(),
          minimumPayment: minPayment,
        );
        final debtHigher = makeDebt(
          id: 'debt-higher',
          currentBalance: balance,
          apr: higherApr.toString(),
          minimumPayment: minPayment,
        );
        final plan = makePlan(extraMonthlyAmount: 5000);

        final projBase = TimelineSimulator.simulate(
          debts: [debtBase],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );
        final projHigher = TimelineSimulator.simulate(
          debts: [debtHigher],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );

        expect(
          projHigher.months.length,
          greaterThanOrEqualTo(projBase.months.length),
          reason: 'Higher APR must not yield a shorter timeline',
        );
      },
    );

    Glados2(balanceGen, aprGen).test(
      'empty rate history produces same result as no rate history',
      (balance, apr) {
        final debt = makeDebt(
          id: 'debt-rh',
          currentBalance: balance,
          apr: apr.toString(),
          minimumPayment: safeMinimum(balance, apr),
        );
        final plan = makePlan(extraMonthlyAmount: 5000);

        final projNoHistory = TimelineSimulator.simulate(
          debts: [debt],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );

        final projEmptyHistory = TimelineSimulator.simulate(
          debts: [debt],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
          rateHistoryByDebt: {'debt-rh': []},
        );

        expect(
          projEmptyHistory.months.length,
          equals(projNoHistory.months.length),
          reason: 'Empty rate history must behave identically to no history',
        );
      },
    );

    test('promotional low rate shortens or equals timeline vs original high rate', () {
      final highApr = Decimal.parse('0.2499');
      final lowApr = Decimal.parse('0.0599');
      const balance = 500000;

      final debt = makeDebt(
        id: 'debt-promo',
        currentBalance: balance,
        apr: highApr.toString(),
        minimumPayment: 15000,
      );
      final plan = makePlan(extraMonthlyAmount: 10000);

      final projHigh = TimelineSimulator.simulate(
        debts: [debt],
        plan: plan,
        startDate: startDate,
        generatedAt: generatedAt,
      );

      final promoHistory = InterestRateHistory(
        id: 'promo-rate',
        debtId: 'debt-promo',
        apr: lowApr,
        effectiveFrom: startDate,
      );

      final projPromo = TimelineSimulator.simulate(
        debts: [debt],
        plan: plan,
        startDate: startDate,
        generatedAt: generatedAt,
        rateHistoryByDebt: {
          'debt-promo': [promoHistory],
        },
      );

      expect(
        projPromo.months.length,
        lessThanOrEqualTo(projHigh.months.length),
        reason: 'Promotional low rate must not extend the payoff timeline',
      );
    });
  });

  // ── Group 3: New Charge (balance increase) ───────────────────────────────

  group('Phase 8 — New charge properties', () {
    Glados3(balanceGen, aprGen, chargeDeltaGen).test(
      'new charge (higher opening balance) yields timeline that is same or longer',
      (balance, apr, charge) {
        final minPayment = safeMinimum(balance + charge, apr);

        final debtBefore = makeDebt(
          id: 'debt-before',
          currentBalance: balance,
          apr: apr.toString(),
          minimumPayment: minPayment,
        );
        final debtAfter = makeDebt(
          id: 'debt-after',
          currentBalance: balance + charge,
          apr: apr.toString(),
          minimumPayment: minPayment,
        );
        final plan = makePlan(extraMonthlyAmount: 5000);

        final projBefore = TimelineSimulator.simulate(
          debts: [debtBefore],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );
        final projAfter = TimelineSimulator.simulate(
          debts: [debtAfter],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );

        expect(
          projAfter.months.length,
          greaterThanOrEqualTo(projBefore.months.length),
          reason: 'Adding a charge must not shorten the payoff timeline',
        );
      },
    );

    Glados2(balanceGen, aprGen).test(
      'simulate is deterministic (same input → same output)',
      (balance, apr) {
        final debt = makeDebt(
          id: 'debt-det',
          currentBalance: balance,
          apr: apr.toString(),
          minimumPayment: safeMinimum(balance, apr),
        );
        final plan = makePlan(extraMonthlyAmount: 5000);

        final proj1 = TimelineSimulator.simulate(
          debts: [debt],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );
        final proj2 = TimelineSimulator.simulate(
          debts: [debt],
          plan: plan,
          startDate: startDate,
          generatedAt: generatedAt,
        );

        expect(proj2.months.length, equals(proj1.months.length));
        expect(
          proj2.months.last.totalBalanceEndOfMonth,
          equals(proj1.months.last.totalBalanceEndOfMonth),
        );
      },
    );
  });
}
