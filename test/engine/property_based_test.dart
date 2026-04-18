import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;

import 'package:debt_payoff_manager/domain/entities/timeline_projection.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/engine/timeline_simulator.dart';

import 'test_helpers.dart';

/// Property-based tests per financial-engine-spec.md §11.3.
///
/// E1 acceptance requires 4 mandatory invariants:
/// monotonicity, avalanche optimality, principal conservation,
/// and rollover correctness. Non-negative balances remain as an
/// additional safety property.
void main() {
  final startDate = DateTime(2026, 1, 1);
  final explore1000 = ExploreConfig(numRuns: 1000);
  final explore250 = ExploreConfig(numRuns: 250);

  final aprGen = any.int.map((i) {
    final basisPoints = (i.abs() % 2200) + 300; // 3.00% -> 24.99%
    return Decimal.parse((basisPoints / 10000).toStringAsFixed(4));
  });

  // Keep balances moderate so 1000-run property tests finish quickly
  // while still exercising meaningful payoff timelines.
  final balanceGen = any.int.map((i) => (i.abs() % 110000) + 10000);
  final smallBalanceGen = any.int.map((i) => (i.abs() % 9000) + 1000);
  final largeBalanceGen = any.int.map((i) => (i.abs() % 100000) + 50000);

  int safeMinimum(int balanceCents, Decimal apr) {
    final monthlyInterest = (balanceCents * apr.toDouble() / 12).ceil();
    return max(monthlyInterest + 1000, 2500);
  }

  int totalInterest(TimelineProjection projection) {
    return projection.months.fold<int>(
      0,
      (sum, month) => sum + month.totalInterestThisMonth,
    );
  }

  int totalPrincipalPaid(TimelineProjection projection) {
    return projection.months.fold<int>(
      0,
      (sum, month) =>
          sum +
          month.entries.fold<int>(
            0,
            (entrySum, entry) => entrySum + entry.principalPortion,
          ),
    );
  }

  group('Property-based: Engine invariants (§11.3)', () {
    Glados2(balanceGen, aprGen, explore1000).test(
      'P1 Monotonicity: more extra never takes more months',
      (balance, apr) {
        final debt = makeDebt(
          id: 'mono',
          currentBalance: balance,
          originalPrincipal: balance,
          apr: apr.toString(),
          minimumPayment: safeMinimum(balance, apr),
        );

        final lowExtra = makePlan(
          id: 'mono-low',
          strategy: Strategy.snowball,
          extraMonthlyAmount: 1000,
        );
        final highExtra = makePlan(
          id: 'mono-high',
          strategy: Strategy.snowball,
          extraMonthlyAmount: 5000,
        );

        final resultLow = TimelineSimulator.simulate(
          debts: [debt],
          plan: lowExtra,
          startDate: startDate,
          generatedAt: testGeneratedAt,
          maxMonths: 240,
        );
        final resultHigh = TimelineSimulator.simulate(
          debts: [debt],
          plan: highExtra,
          startDate: startDate,
          generatedAt: testGeneratedAt,
          maxMonths: 240,
        );

        expect(resultLow.months, isNotEmpty);
        expect(resultHigh.months, isNotEmpty);
        expect(resultLow.months.last.totalBalanceEndOfMonth, 0);
        expect(resultHigh.months.last.totalBalanceEndOfMonth, 0);
        expect(
          resultHigh.months.length,
          lessThanOrEqualTo(resultLow.months.length),
        );
      },
    );

    Glados3(balanceGen, balanceGen, aprGen, explore1000).test(
      'P2 Principal conservation: principal paid + final balance == initial balance',
      (balanceA, balanceB, apr) {
        final debtA = makeDebt(
          id: 'cons-a',
          currentBalance: balanceA,
          originalPrincipal: balanceA,
          apr: apr.toString(),
          minimumPayment: safeMinimum(balanceA, apr),
        );
        final aprB = Decimal.parse(
          min(apr.toDouble() + 0.04, 0.2999).toStringAsFixed(4),
        );
        final adjustedBalanceB = balanceB + 5000;
        final debtB = makeDebt(
          id: 'cons-b',
          currentBalance: adjustedBalanceB,
          originalPrincipal: adjustedBalanceB,
          apr: aprB.toString(),
          minimumPayment: safeMinimum(adjustedBalanceB, aprB),
        );

        final result = TimelineSimulator.simulate(
          debts: [debtA, debtB],
          plan: makePlan(
            id: 'cons-plan',
            strategy: Strategy.avalanche,
            extraMonthlyAmount: 4000,
          ),
          startDate: startDate,
          generatedAt: testGeneratedAt,
          maxMonths: 240,
        );

        expect(result.months, isNotEmpty);
        expect(result.months.last.totalBalanceEndOfMonth, 0);
        expect(
          totalPrincipalPaid(result) +
              result.months.last.totalBalanceEndOfMonth,
          balanceA + adjustedBalanceB,
        );
      },
    );

    Glados2(smallBalanceGen, largeBalanceGen, explore1000).test(
      'P3 Avalanche optimality: avalanche interest <= snowball interest',
      (smallBalance, largeBalance) {
        final lowApr = Decimal.parse('0.0800');
        final highApr = Decimal.parse('0.2200');
        final debtA = makeDebt(
          id: 'aval-a',
          currentBalance: smallBalance,
          originalPrincipal: smallBalance,
          apr: lowApr.toString(),
          minimumPayment: safeMinimum(smallBalance, lowApr),
        );
        final debtB = makeDebt(
          id: 'aval-b',
          currentBalance: largeBalance,
          originalPrincipal: largeBalance,
          apr: highApr.toString(),
          minimumPayment: safeMinimum(largeBalance, highApr),
        );

        final snowball = TimelineSimulator.simulate(
          debts: [debtA, debtB],
          plan: makePlan(
            id: 'snowball-plan',
            strategy: Strategy.snowball,
            extraMonthlyAmount: 5000,
          ),
          startDate: startDate,
          generatedAt: testGeneratedAt,
          maxMonths: 240,
        );
        final avalanche = TimelineSimulator.simulate(
          debts: [debtA, debtB],
          plan: makePlan(
            id: 'avalanche-plan',
            strategy: Strategy.avalanche,
            extraMonthlyAmount: 5000,
          ),
          startDate: startDate,
          generatedAt: testGeneratedAt,
          maxMonths: 240,
        );

        expect(snowball.months, isNotEmpty);
        expect(avalanche.months, isNotEmpty);
        expect(snowball.months.last.totalBalanceEndOfMonth, 0);
        expect(avalanche.months.last.totalBalanceEndOfMonth, 0);
        expect(
          totalInterest(avalanche),
          lessThanOrEqualTo(totalInterest(snowball)),
        );
      },
    );

    Glados2(smallBalanceGen, largeBalanceGen, explore1000).test(
      'P4 Rollover correctness: same-month payoff pushes extra to next debt',
      (smallBalance, largeBalance) {
        final debtA = makeDebt(
          id: 'roll-a',
          currentBalance: smallBalance,
          originalPrincipal: smallBalance,
          apr: '0.20',
          minimumPayment: 2500,
        );
        final debtB = makeDebt(
          id: 'roll-b',
          currentBalance: largeBalance,
          originalPrincipal: largeBalance,
          apr: '0.15',
          minimumPayment: 3000,
        );

        final result = TimelineSimulator.simulate(
          debts: [debtA, debtB],
          plan: makePlan(
            id: 'roll-plan',
            strategy: Strategy.snowball,
            extraMonthlyAmount: 20000,
          ),
          startDate: startDate,
          generatedAt: testGeneratedAt,
          maxMonths: 2,
        );

        expect(result.months, isNotEmpty);

        final month1 = result.months.first;
        final entryA = month1.entries.firstWhere(
          (entry) => entry.debtId == 'roll-a',
        );
        final entryB = month1.entries.firstWhere(
          (entry) => entry.debtId == 'roll-b',
        );

        expect(entryA.endingBalance, 0);
        expect(entryA.isPaidOffThisMonth, isTrue);
        expect(entryB.paymentApplied, greaterThan(debtB.minimumPayment));
      },
    );

    Glados2(balanceGen, aprGen, explore250).test(
      'Additional safety: ending balances never go negative',
      (balance, apr) {
        final debt = makeDebt(
          id: 'non-negative',
          currentBalance: balance,
          originalPrincipal: balance,
          apr: apr.toString(),
          minimumPayment: safeMinimum(balance, apr),
        );

        final result = TimelineSimulator.simulate(
          debts: [debt],
          plan: makePlan(
            id: 'non-negative-plan',
            strategy: Strategy.avalanche,
            extraMonthlyAmount: 7500,
          ),
          startDate: startDate,
          generatedAt: testGeneratedAt,
          maxMonths: 240,
        );

        for (final month in result.months) {
          for (final entry in month.entries) {
            expect(
              entry.endingBalance,
              greaterThanOrEqualTo(0),
              reason:
                  'Month ${month.monthIndex} debt ${entry.debtId} produced '
                  'negative ending balance ${entry.endingBalance}',
            );
          }
        }
      },
    );
  });
}
