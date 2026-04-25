import 'dart:math';

import 'package:equatable/equatable.dart';

import '../../core/extensions/date_extensions.dart';
import '../../core/models/monthly_action_models.dart';
import '../../core/models/recast_delta.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/plan.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/payment_type.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../engine/interest_calculator.dart';
import '../../engine/min_payment_calculator.dart';
import '../../engine/strategy_sorter.dart';
import 'plan_recast_service.dart';

/// Computes the monthly action checklist directly from live debt and plan data.
class MonthlyActionService {
  MonthlyActionService({
    required DebtRepository debtRepository,
    required PaymentRepository paymentRepository,
    required PlanRepository planRepository,
    required PlanRecastService planRecastService,
  }) : _debtRepository = debtRepository,
       _paymentRepository = paymentRepository,
       _planRepository = planRepository,
       _planRecastService = planRecastService;

  final DebtRepository _debtRepository;
  final PaymentRepository _paymentRepository;
  final PlanRepository _planRepository;
  final PlanRecastService _planRecastService;

  Future<MonthlyActionSnapshot> load({
    String scenarioId = 'main',
    DateTime? referenceDate,
  }) async {
    final effectiveDate = _localDay(referenceDate ?? DateTime.now());
    var plan = await _planRepository.getCurrentPlan(scenarioId: scenarioId);
    final debts = await _debtRepository.getAllDebts(scenarioId: scenarioId);
    final trackedDebts = debts
        .where((debt) => debt.status != DebtStatus.archived)
        .toList(growable: false);

    if (plan == null) {
      return MonthlyActionSnapshot(
        referenceDate: effectiveDate,
        plan: null,
        delta: null,
        sections: const [],
        summary: const MonthlyActionSummary(
          totalMinimumCents: 0,
          totalExtraCents: 0,
          totalDueCents: 0,
          completedCount: 0,
          totalCount: 0,
          overdueCount: 0,
          loggedTotalCents: 0,
          remainingBalanceCents: 0,
          trackedDebtCount: 0,
          paidOffDebtCount: 0,
        ),
        hasTrackedDebts: trackedDebts.isNotEmpty,
      );
    }

    if (trackedDebts.isNotEmpty && plan.projectedDebtFreeDate == null) {
      final recast = await _planRecastService.recast(
        scenarioId: scenarioId,
        referenceDate: effectiveDate,
      );
      plan = recast?.plan ?? plan;
    }

    final payments = await _paymentRepository.getPaymentsForMonth(
      effectiveDate.yearMonth,
      scenarioId: scenarioId,
    );
    final completedMonthPayments = payments
        .where((payment) => payment.status == PaymentStatus.completed)
        .toList(growable: false);
    final items = _computeItems(
      debts: trackedDebts,
      plan: plan,
      completedPayments: completedMonthPayments,
      referenceDate: effectiveDate,
    );

    final grouped = <String, List<MonthlyActionItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.debtId, () => <MonthlyActionItem>[]).add(item);
    }

    final sections = grouped.values
        .map(
          (groupItems) => MonthlyActionSection(
            debtId: groupItems.first.debtId,
            debtName: groupItems.first.debtName,
            debtType: groupItems.first.debtType,
            totalDueCents: groupItems.fold<int>(
              0,
              (sum, item) => sum + item.amountCents,
            ),
            items: groupItems,
          ),
        )
        .toList(growable: false);

    final singleDebt = trackedDebts.length == 1 ? trackedDebts.single : null;
    final summary = MonthlyActionSummary(
      totalMinimumCents: items
          .where((item) => item.kind == MonthlyActionKind.minimum)
          .fold<int>(0, (sum, item) => sum + item.amountCents),
      totalExtraCents: items
          .where((item) => item.kind == MonthlyActionKind.extra)
          .fold<int>(0, (sum, item) => sum + item.amountCents),
      totalDueCents: items.fold<int>(0, (sum, item) => sum + item.amountCents),
      completedCount: items.where((item) => item.isCompleted).length,
      totalCount: items.length,
      overdueCount: items.where((item) => item.isOverdue).length,
      loggedTotalCents: completedMonthPayments.fold<int>(
        0,
        (sum, payment) => sum + payment.amount,
      ),
      latestLoggedAt: _latestPayment(completedMonthPayments)?.date,
      remainingBalanceCents: trackedDebts.fold<int>(
        0,
        (sum, debt) => sum + max(0, debt.currentBalance),
      ),
      trackedDebtCount: trackedDebts.length,
      paidOffDebtCount: trackedDebts
          .where(
            (debt) =>
                debt.status == DebtStatus.paidOff || debt.currentBalance <= 0,
          )
          .length,
      singleDebtId: singleDebt?.id,
      singleDebtName: singleDebt?.name,
      singleDebtDueDate: singleDebt == null
          ? null
          : _resolveDueDate(effectiveDate, singleDebt.dueDayOfMonth),
      singleDebtStatus: singleDebt?.status,
    );

    return MonthlyActionSnapshot(
      referenceDate: effectiveDate,
      plan: plan,
      delta: _planRecastService.lastDeltaFor(scenarioId),
      sections: sections,
      summary: summary,
      hasTrackedDebts: trackedDebts.isNotEmpty,
    );
  }

  List<MonthlyActionItem> _computeItems({
    required List<Debt> debts,
    required Plan plan,
    required List<Payment> completedPayments,
    required DateTime referenceDate,
  }) {
    final currentMonthStart = referenceDate.startOfMonth;
    final currentMonthEnd = referenceDate.endOfMonth;
    final eligibleDebts = debts
        .where((debt) {
          if (debt.currentBalance <= 0) return false;
          if (debt.status != DebtStatus.active &&
              debt.status != DebtStatus.paused) {
            return false;
          }
          if (debt.firstDueDate.isAfter(currentMonthEnd)) return false;
          if (debt.isPaused(currentMonthStart)) return false;
          return true;
        })
        .toList(growable: false);

    final scheduledMinimums = <String, int>{};
    final balanceAfterMinimum = <String, int>{};
    final dueDates = <String, DateTime>{};

    for (final debt in eligibleDebts) {
      final interest = InterestCalculator.computeMonthlyInterest(
        balanceCents: debt.currentBalance,
        apr: debt.apr,
        method: debt.interestMethod,
        daysInMonth: currentMonthStart.daysInMonth,
      );
      final accruedBalance = debt.currentBalance + interest;
      final minimumPayment = min(
        MinPaymentCalculator.compute(
          balanceCents: accruedBalance,
          interestCents: interest,
          type: debt.minimumPaymentType,
          fixedAmountCents: debt.minimumPayment,
          percent: debt.minimumPaymentPercent,
          floorCents: debt.minimumPaymentFloor,
        ),
        accruedBalance,
      );

      scheduledMinimums[debt.id] = minimumPayment;
      balanceAfterMinimum[debt.id] = accruedBalance - minimumPayment;
      dueDates[debt.id] = _resolveDueDate(referenceDate, debt.dueDayOfMonth);
    }

    final extraAllocations = <String, int>{};
    final sortableDebts = eligibleDebts
        .where((debt) => !debt.excludeFromStrategy)
        .toList(growable: false);
    final ordered = StrategySorter.sort(
      sortableDebts,
      plan.strategy,
      plan.customOrder,
    );

    var extraPool = plan.extraMonthlyAmount;
    for (var index = 0; index < ordered.length; index++) {
      final debt = ordered[index];
      if (extraPool <= 0) break;
      final available = balanceAfterMinimum[debt.id] ?? 0;
      if (available <= 0) continue;
      final applied = min(extraPool, available);
      extraAllocations[debt.id] = applied;
      extraPool -= applied;
    }

    final minimumCompleted = <String, Payment>{};
    final extraCompleted = <String, Payment>{};
    for (final payment in completedPayments) {
      if (payment.type == PaymentType.minimum) {
        _storeLatestPayment(minimumCompleted, payment);
      } else if (payment.type == PaymentType.extra ||
          payment.type == PaymentType.lumpSum) {
        _storeLatestPayment(extraCompleted, payment);
      }
    }

    final items = <MonthlyActionItem>[];
    for (final debt in eligibleDebts) {
      final dueDate = dueDates[debt.id]!;
      final minimumAmount = scheduledMinimums[debt.id] ?? 0;
      final extraAmount = extraAllocations[debt.id] ?? 0;
      final minimumProofPayment = minimumCompleted[debt.id];
      final extraProofPayment = extraCompleted[debt.id];

      if (minimumAmount > 0) {
        items.add(
          MonthlyActionItem(
            id: '${debt.id}:${currentMonthStart.yearMonth}:minimum',
            debtId: debt.id,
            debtName: debt.name,
            debtType: debt.type,
            kind: MonthlyActionKind.minimum,
            paymentType: PaymentType.minimum,
            amountCents: minimumAmount,
            dueDate: dueDate,
            subtitle: '',
            isCompleted: minimumProofPayment != null,
            isOverdue: _isOverdue(
              dueDate: dueDate,
              referenceDate: referenceDate,
              isCompleted: minimumProofPayment != null,
            ),
            isUpcoming: _isUpcoming(
              dueDate: dueDate,
              referenceDate: referenceDate,
              isCompleted: minimumProofPayment != null,
            ),
            completionProof: minimumProofPayment == null
                ? null
                : _toCompletionProof(minimumProofPayment),
          ),
        );
      }

      if (extraAmount > 0) {
        final priorityRank = ordered.indexWhere(
          (candidate) => candidate.id == debt.id,
        );
        items.add(
          MonthlyActionItem(
            id: '${debt.id}:${currentMonthStart.yearMonth}:extra',
            debtId: debt.id,
            debtName: debt.name,
            debtType: debt.type,
            kind: MonthlyActionKind.extra,
            paymentType: PaymentType.extra,
            amountCents: extraAmount,
            dueDate: dueDate,
            subtitle: '',
            priorityRank: priorityRank == -1 ? null : priorityRank + 1,
            isCompleted: extraProofPayment != null,
            completionProof: extraProofPayment == null
                ? null
                : _toCompletionProof(extraProofPayment),
          ),
        );
      }
    }

    items.sort((a, b) {
      final dueCompare = a.dueDate.compareTo(b.dueDate);
      if (dueCompare != 0) return dueCompare;
      return a.kind.index.compareTo(b.kind.index);
    });
    return items;
  }

  static bool _isOverdue({
    required DateTime dueDate,
    required DateTime referenceDate,
    required bool isCompleted,
  }) {
    if (isCompleted) return false;
    final today = _localDay(referenceDate);
    return dueDate.isBefore(today);
  }

  static bool _isUpcoming({
    required DateTime dueDate,
    required DateTime referenceDate,
    required bool isCompleted,
  }) {
    if (isCompleted) return false;
    final delta = dueDate.difference(_localDay(referenceDate)).inDays;
    return delta >= 0 && delta <= 7;
  }

  static DateTime _resolveDueDate(DateTime referenceDate, int desiredDay) {
    final lastDay = DateTime(
      referenceDate.year,
      referenceDate.month + 1,
      0,
    ).day;
    return DateTime(
      referenceDate.year,
      referenceDate.month,
      min(desiredDay, lastDay),
    );
  }

  static DateTime _localDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static void _storeLatestPayment(
    Map<String, Payment> latestByDebt,
    Payment payment,
  ) {
    final current = latestByDebt[payment.debtId];
    if (current == null || _isNewerPayment(payment, current)) {
      latestByDebt[payment.debtId] = payment;
    }
  }

  static Payment? _latestPayment(List<Payment> payments) {
    Payment? latest;
    for (final payment in payments) {
      if (latest == null || _isNewerPayment(payment, latest)) {
        latest = payment;
      }
    }
    return latest;
  }

  static bool _isNewerPayment(Payment candidate, Payment current) {
    final dateCompare = candidate.date.compareTo(current.date);
    if (dateCompare != 0) return dateCompare > 0;
    final createdCompare = candidate.createdAt.compareTo(current.createdAt);
    if (createdCompare != 0) return createdCompare > 0;
    return candidate.id.compareTo(current.id) > 0;
  }

  static MonthlyActionCompletionProof _toCompletionProof(Payment payment) {
    return MonthlyActionCompletionProof(
      paymentId: payment.id,
      amountCents: payment.amount,
      date: payment.date,
      appliedBalanceAfter: payment.appliedBalanceAfter,
      source: payment.source,
      type: payment.type,
    );
  }
}

class MonthlyActionSnapshot extends Equatable {
  const MonthlyActionSnapshot({
    required this.referenceDate,
    required this.plan,
    required this.delta,
    required this.sections,
    required this.summary,
    required this.hasTrackedDebts,
  });

  final DateTime referenceDate;
  final Plan? plan;
  final RecastDelta? delta;
  final List<MonthlyActionSection> sections;
  final MonthlyActionSummary summary;
  final bool hasTrackedDebts;

  bool get hasActionItems =>
      sections.any((section) => section.items.isNotEmpty);

  @override
  List<Object?> get props => [
    referenceDate,
    plan,
    delta,
    sections,
    summary,
    hasTrackedDebts,
  ];
}
