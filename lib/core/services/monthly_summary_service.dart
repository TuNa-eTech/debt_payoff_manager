import '../../domain/entities/debt.dart';
import '../../domain/enums/payment_type.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/plan_repository.dart';

class DebtMonthlySummary {
  const DebtMonthlySummary({
    required this.debt,
    required this.paidCents,
    required this.principalCents,
    required this.interestCents,
    required this.chargeCents,
    required this.balanceBefore,
    required this.balanceAfter,
  });

  final Debt debt;
  final int paidCents;
  final int principalCents;
  final int interestCents;
  final int chargeCents;
  final int balanceBefore;
  final int balanceAfter;

  int get netChange => balanceAfter - balanceBefore;
}

class MonthlySummaryData {
  const MonthlySummaryData({
    required this.month,
    required this.totalPaidCents,
    required this.totalExtraPaidCents,
    required this.totalPrincipalCents,
    required this.totalInterestCents,
    required this.totalChargeCents,
    required this.plannedExtraCents,
    required this.perDebt,
  });

  final DateTime month;
  final int totalPaidCents;

  /// Sum of PaymentType.extra + PaymentType.lumpSum only (excludes minimums).
  final int totalExtraPaidCents;

  final int totalPrincipalCents;
  final int totalInterestCents;
  final int totalChargeCents;

  /// Extra monthly amount from the active plan (0 if no plan).
  final int plannedExtraCents;

  final List<DebtMonthlySummary> perDebt;

  /// Positive = paid more extra than committed; negative = under-paid vs commitment.
  /// Compares extra/lump-sum payments only — minimums are baseline and excluded.
  int get varianceCents => totalExtraPaidCents - plannedExtraCents;

  bool get hasActivity => totalPaidCents > 0 || totalChargeCents > 0;
}

class MonthlySummaryService {
  MonthlySummaryService({
    required DebtRepository debtRepository,
    required PaymentRepository paymentRepository,
    required PlanRepository planRepository,
  }) : _debtRepository = debtRepository,
       _paymentRepository = paymentRepository,
       _planRepository = planRepository;

  final DebtRepository _debtRepository;
  final PaymentRepository _paymentRepository;
  final PlanRepository _planRepository;

  Future<MonthlySummaryData> getSummary(
    DateTime month, {
    String scenarioId = 'main',
  }) async {
    final monthStart = DateTime.utc(month.year, month.month);
    final monthEnd = DateTime.utc(month.year, month.month + 1);

    final payments = await _paymentRepository.getAllPayments(
      scenarioId: scenarioId,
      fromDate: monthStart,
      toDate: monthEnd,
    );

    final debts = await _debtRepository.getAllDebts(scenarioId: scenarioId);
    final debtById = {for (final d in debts) d.id: d};

    final plan = await _planRepository.getCurrentPlan(scenarioId: scenarioId);

    int totalPaid = 0;
    int totalExtra = 0;
    int totalPrincipal = 0;
    int totalInterest = 0;
    int totalCharge = 0;

    // Per-debt accumulators
    final Map<String, _DebtAccumulator> accByDebt = {};

    for (final p in payments) {
      final debt = debtById[p.debtId];
      if (debt == null) continue;

      final acc = accByDebt.putIfAbsent(
        p.debtId,
        () => _DebtAccumulator(debt: debt),
      );

      if (p.type == PaymentType.charge) {
        final chargeAmt = p.amount.abs();
        totalCharge += chargeAmt;
        acc.chargeCents += chargeAmt;
        acc.balanceSnapshots.add(p.appliedBalanceAfter);
      } else if (p.type != PaymentType.refund) {
        totalPaid += p.amount;
        totalPrincipal += p.principalPortion;
        totalInterest += p.interestPortion;
        if (p.type == PaymentType.extra || p.type == PaymentType.lumpSum) {
          totalExtra += p.amount;
        }
        acc.paidCents += p.amount;
        acc.principalCents += p.principalPortion;
        acc.interestCents += p.interestPortion;
        acc.balanceSnapshots.add(p.appliedBalanceAfter);
        acc.balanceBefore ??= p.appliedBalanceBefore;
      }
    }

    final perDebt = accByDebt.values.map((acc) {
      final balanceBefore = acc.balanceBefore ?? acc.debt.currentBalance;
      final balanceAfter = acc.balanceSnapshots.isNotEmpty
          ? acc.balanceSnapshots.last
          : balanceBefore;
      return DebtMonthlySummary(
        debt: acc.debt,
        paidCents: acc.paidCents,
        principalCents: acc.principalCents,
        interestCents: acc.interestCents,
        chargeCents: acc.chargeCents,
        balanceBefore: balanceBefore,
        balanceAfter: balanceAfter,
      );
    }).toList()..sort((a, b) => b.paidCents.compareTo(a.paidCents));

    return MonthlySummaryData(
      month: month,
      totalPaidCents: totalPaid,
      totalExtraPaidCents: totalExtra,
      totalPrincipalCents: totalPrincipal,
      totalInterestCents: totalInterest,
      totalChargeCents: totalCharge,
      plannedExtraCents: plan?.extraMonthlyAmount ?? 0,
      perDebt: perDebt,
    );
  }
}

class _DebtAccumulator {
  _DebtAccumulator({required this.debt});

  final Debt debt;
  int paidCents = 0;
  int principalCents = 0;
  int interestCents = 0;
  int chargeCents = 0;
  int? balanceBefore;
  final List<int> balanceSnapshots = [];
}
