import 'dart:math';

import '../core/constants/app_constants.dart';
import '../core/extensions/date_extensions.dart';
import '../domain/entities/debt.dart';
import '../domain/entities/plan.dart';
import '../domain/entities/timeline_projection.dart';
import '../domain/enums/debt_status.dart';
import 'interest_calculator.dart';
import 'min_payment_calculator.dart';
import 'strategy_sorter.dart';

/// Month-by-month timeline simulation engine.
///
/// Reference: financial-engine-spec.md §9
///
/// Pure Dart, deterministic, idempotent per spec §1 principle 6.
abstract final class TimelineSimulator {
  /// Run a full simulation.
  ///
  /// Per §9.1 algorithm:
  /// 1. Accrue interest on all active debts
  /// 2. Pay minimum on all active debts
  /// 3. Apply extra + rollover
  /// 4. Remove paid-off debts
  ///
  /// Returns a [TimelineProjection] with month-by-month data.
  static TimelineProjection simulate({
    required List<Debt> debts,
    required Plan plan,
    required DateTime startDate,
    required DateTime generatedAt,
    int maxMonths = AppConstants.maxSimulationMonths,
  }) {
    // Working copies of balances (cents)
    final balances = {for (final d in debts) d.id: d.currentBalance};
    final activeIds = debts
        .where(
          (d) =>
              d.currentBalance > 0 &&
              (d.status == DebtStatus.active || d.status == DebtStatus.paused),
        )
        .map((d) => d.id)
        .toSet();
    final debtMap = {for (final d in debts) d.id: d};

    final months = <MonthProjection>[];
    var monthIndex = 0;
    var recurringRolloverPool = 0;

    while (activeIds.isNotEmpty && monthIndex < maxMonths) {
      final currentDate = startDate.addMonths(monthIndex);
      final entries = <DebtMonthEntry>[];

      // ── Step 1: Accrue interest on all active ──
      final interestMap = <String, int>{};
      final pausedIds = <String>{};
      for (final id in activeIds) {
        final debt = debtMap[id]!;
        final balance = balances[id]!;

        if (debt.isPaused(currentDate)) {
          pausedIds.add(id);
          interestMap[id] = 0;
          continue;
        }

        final interest = InterestCalculator.computeMonthlyInterest(
          balanceCents: balance,
          apr: debt.apr,
          method: debt.interestMethod,
          daysInMonth: currentDate.daysInMonth,
        );
        interestMap[id] = interest;
        balances[id] = balance + interest;
      }

      // ── Step 2: Pay minimum on all active ──
      final minPayments = <String, int>{};
      final scheduledMinimums = <String, int>{};
      for (final id in activeIds) {
        final debt = debtMap[id]!;
        if (pausedIds.contains(id)) {
          minPayments[id] = 0;
          scheduledMinimums[id] = 0;
          continue;
        }

        final interest = interestMap[id] ?? 0;
        final minPay = MinPaymentCalculator.compute(
          balanceCents: balances[id]!,
          interestCents: interest,
          type: debt.minimumPaymentType,
          fixedAmountCents: debt.minimumPayment,
          percent: debt.minimumPaymentPercent,
          floorCents: debt.minimumPaymentFloor,
        );
        scheduledMinimums[id] = minPay;
        final actualMin = min(minPay, balances[id]!);
        minPayments[id] = actualMin;
        balances[id] = balances[id]! - actualMin;
      }

      // ── Step 3: Apply extra + rollover ──
      final extraPayments = <String, int>{};
      final activeDebts = activeIds
          .where((id) => !pausedIds.contains(id))
          .map((id) => debtMap[id]!)
          .toList();

      final sorted = StrategySorter.sort(
        activeDebts.where((d) => !d.excludeFromStrategy).toList(),
        plan.strategy,
        plan.customOrder,
      );

      var extraPool = plan.extraMonthlyAmount + recurringRolloverPool;
      for (final debt in sorted) {
        if (extraPool <= 0) break;
        final balance = balances[debt.id]!;
        if (balance <= 0) continue;

        final applied = min(extraPool, balance);
        extraPayments[debt.id] = applied;
        balances[debt.id] = balance - applied;
        extraPool -= applied;
      }

      // ── Step 4: Build entries & detect paid-off ──
      final newlyPaidOff = <String>[];
      for (final id in activeIds) {
        // Reconstruct starting balance before this month
        final interest = interestMap[id] ?? 0;
        final totalPaid = (minPayments[id] ?? 0) + (extraPayments[id] ?? 0);
        final endBalance = balances[id]!;
        final reconstructedStart = endBalance + totalPaid - interest;

        final interestPortion = min(interest, totalPaid);
        final principalPortion = totalPaid - interestPortion;

        entries.add(
          DebtMonthEntry(
            debtId: id,
            startingBalance: max(0, reconstructedStart),
            interestAccrued: interest,
            paymentApplied: totalPaid,
            principalPortion: principalPortion,
            interestPortion: interestPortion,
            endingBalance: max(0, endBalance),
            isPaidOffThisMonth: endBalance <= 0,
          ),
        );

        if (endBalance <= 0) {
          newlyPaidOff.add(id);
        }
      }

      // Freed minimums become recurring pool in following months.
      for (final id in newlyPaidOff) {
        recurringRolloverPool += scheduledMinimums[id] ?? 0;
      }

      // Remove paid-off debts.
      activeIds.removeAll(newlyPaidOff);

      months.add(
        MonthProjection(
          monthIndex: monthIndex,
          yearMonth: currentDate.yearMonth,
          entries: entries,
          totalPaymentThisMonth: entries.fold(
            0,
            (s, e) => s + e.paymentApplied,
          ),
          totalInterestThisMonth: entries.fold(
            0,
            (s, e) => s + e.interestAccrued,
          ),
          totalBalanceEndOfMonth: entries.fold(
            0,
            (s, e) => s + e.endingBalance,
          ),
        ),
      );

      monthIndex++;
    }

    return TimelineProjection(
      planId: plan.id,
      generatedAt: generatedAt,
      months: months,
    );
  }

  /// Run simulation with minimum-only payments for comparison.
  ///
  /// Per §9.4: interest_saved = total_interest_minimum_only - total_interest_projected
  static TimelineProjection simulateMinimumOnly({
    required List<Debt> debts,
    required Plan plan,
    required DateTime startDate,
    required DateTime generatedAt,
    int maxMonths = AppConstants.maxSimulationMonths,
  }) {
    final minOnlyPlan = Plan(
      id: '${plan.id}_min_only',
      scenarioId: plan.scenarioId,
      strategy: plan.strategy,
      extraMonthlyAmount: 0,
      extraPaymentCadence: plan.extraPaymentCadence,
      customOrder: plan.customOrder,
      lastRecastAt: plan.lastRecastAt,
      projectedDebtFreeDate: plan.projectedDebtFreeDate,
      totalInterestProjected: plan.totalInterestProjected,
      totalInterestSaved: plan.totalInterestSaved,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
    );
    return simulate(
      debts: debts,
      plan: minOnlyPlan,
      startDate: startDate,
      generatedAt: generatedAt,
      maxMonths: maxMonths,
    );
  }
}
