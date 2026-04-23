import 'package:uuid/uuid.dart';

import '../../domain/entities/debt.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/milestone_type.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/milestone_repository.dart';

class MilestoneService {
  MilestoneService({
    required MilestoneRepository milestoneRepository,
    required DebtRepository debtRepository,
  }) : _milestoneRepository = milestoneRepository,
       _debtRepository = debtRepository;

  final MilestoneRepository _milestoneRepository;
  final DebtRepository _debtRepository;
  final Uuid _uuid = const Uuid();

  Future<void> evaluatePaymentMilestones({
    required Debt originalDebt,
    required Debt updatedDebt,
    required DateTime paymentDate,
  }) async {
    final achievedAt = paymentDate.toUtc();

    await _awardGlobalMilestone(
      type: MilestoneType.firstPayment,
      scenarioId: updatedDebt.scenarioId,
      achievedAt: achievedAt,
    );

    await _awardProgressMilestone(
      originalDebt: originalDebt,
      updatedDebt: updatedDebt,
      achievedAt: achievedAt,
    );

    if (updatedDebt.currentBalance == 0 ||
        updatedDebt.status == DebtStatus.paidOff) {
      await _awardDebtMilestone(
        type: MilestoneType.debtPaidOff,
        scenarioId: updatedDebt.scenarioId,
        debtId: updatedDebt.id,
        achievedAt: achievedAt,
      );
      await _awardAllDebtFreeMilestone(
        scenarioId: updatedDebt.scenarioId,
        achievedAt: achievedAt,
        updatedDebt: updatedDebt,
      );
    }
  }

  Future<void> _awardProgressMilestone({
    required Debt originalDebt,
    required Debt updatedDebt,
    required DateTime achievedAt,
  }) async {
    if (originalDebt.originalPrincipal <= 0) return;

    final previousProgress = _progressForDebt(originalDebt);
    final currentProgress = _progressForDebt(updatedDebt);
    final crossedMilestone = _highestCrossedProgressMilestone(
      previousProgress: previousProgress,
      currentProgress: currentProgress,
    );
    if (crossedMilestone == null) return;

    await _awardDebtMilestone(
      type: crossedMilestone,
      scenarioId: updatedDebt.scenarioId,
      debtId: updatedDebt.id,
      achievedAt: achievedAt,
    );
  }

  Future<void> _awardAllDebtFreeMilestone({
    required String scenarioId,
    required DateTime achievedAt,
    required Debt updatedDebt,
  }) async {
    final debts = await _debtRepository.getAllDebts(scenarioId: scenarioId);
    final trackedDebts = debts
        .map((debt) => debt.id == updatedDebt.id ? updatedDebt : debt)
        .where((debt) => debt.status != DebtStatus.archived)
        .toList(growable: false);
    if (trackedDebts.isEmpty) return;
    final allPaidOff = trackedDebts.every(
      (debt) => debt.currentBalance == 0 || debt.status == DebtStatus.paidOff,
    );
    if (!allPaidOff) return;

    await _awardGlobalMilestone(
      type: MilestoneType.allDebtFree,
      scenarioId: scenarioId,
      achievedAt: achievedAt,
    );
  }

  Future<void> _awardGlobalMilestone({
    required MilestoneType type,
    required String scenarioId,
    required DateTime achievedAt,
  }) async {
    final exists = await _milestoneRepository.milestoneExists(type);
    if (exists) return;

    await _milestoneRepository.addMilestone(
      Milestone(
        id: _uuid.v4(),
        scenarioId: scenarioId,
        type: type,
        achievedAt: achievedAt,
        createdAt: achievedAt,
      ),
    );
  }

  Future<void> _awardDebtMilestone({
    required MilestoneType type,
    required String scenarioId,
    required String debtId,
    required DateTime achievedAt,
  }) async {
    final exists = await _milestoneRepository.milestoneExists(
      type,
      debtId: debtId,
    );
    if (exists) return;

    await _milestoneRepository.addMilestone(
      Milestone(
        id: _uuid.v4(),
        scenarioId: scenarioId,
        type: type,
        debtId: debtId,
        achievedAt: achievedAt,
        createdAt: achievedAt,
      ),
    );
  }

  double _progressForDebt(Debt debt) {
    if (debt.originalPrincipal <= 0) return 0;
    final paid = debt.originalPrincipal - debt.currentBalance;
    return (paid / debt.originalPrincipal).clamp(0.0, 1.0);
  }

  MilestoneType? _highestCrossedProgressMilestone({
    required double previousProgress,
    required double currentProgress,
  }) {
    final thresholds = <(double, MilestoneType)>[
      (0.75, MilestoneType.percentComplete75),
      (0.50, MilestoneType.percentComplete50),
      (0.25, MilestoneType.percentComplete25),
    ];

    for (final (threshold, type) in thresholds) {
      if (previousProgress < threshold && currentProgress >= threshold) {
        return type;
      }
    }
    return null;
  }
}
