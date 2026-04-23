import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/services/milestone_service.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/milestone_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/milestone_type.dart';

import '../../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepository;
  late MilestoneRepositoryImpl milestoneRepository;
  late MilestoneService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    debtRepository = DebtRepositoryImpl(db: db);
    milestoneRepository = MilestoneRepositoryImpl(db: db);
    service = MilestoneService(
      milestoneRepository: milestoneRepository,
      debtRepository: debtRepository,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'awards first-payment and highest crossed progress milestone once',
    () async {
      final originalDebt = makeRepoDebt(
        id: 'visa',
        originalPrincipal: 100000,
        currentBalance: 100000,
      );
      final updatedDebt = originalDebt.copyWith(
        currentBalance: 70000,
        updatedAt: DateTime.utc(2026, 4, 15),
      );

      await debtRepository.addDebt(originalDebt);
      await debtRepository.updateDebt(updatedDebt);

      await service.evaluatePaymentMilestones(
        originalDebt: originalDebt,
        updatedDebt: updatedDebt,
        paymentDate: DateTime.utc(2026, 4, 15),
      );
      await service.evaluatePaymentMilestones(
        originalDebt: originalDebt,
        updatedDebt: updatedDebt,
        paymentDate: DateTime.utc(2026, 4, 15),
      );

      final unseen = await milestoneRepository.getUnseenMilestones();

      expect(
        unseen.where(
          (milestone) => milestone.type == MilestoneType.firstPayment,
        ),
        hasLength(1),
      );
      expect(
        unseen.where(
          (milestone) =>
              milestone.type == MilestoneType.percentComplete25 &&
              milestone.debtId == originalDebt.id,
        ),
        hasLength(1),
      );
    },
  );

  test(
    'awards payoff and all-debt-free milestones when the final debt is cleared',
    () async {
      final partialDebt = makeRepoDebt(
        id: 'loan',
        originalPrincipal: 100000,
        currentBalance: 70000,
      );
      final paidOffDebt = partialDebt.copyWith(
        currentBalance: 0,
        status: DebtStatus.paidOff,
        paidOffAt: DateTime.utc(2026, 5, 1),
        updatedAt: DateTime.utc(2026, 5, 1),
      );

      await debtRepository.addDebt(partialDebt);
      await debtRepository.updateDebt(paidOffDebt);

      await service.evaluatePaymentMilestones(
        originalDebt: partialDebt,
        updatedDebt: paidOffDebt,
        paymentDate: DateTime.utc(2026, 5, 1),
      );

      final unseen = await milestoneRepository.getUnseenMilestones();

      expect(
        unseen.where(
          (milestone) =>
              milestone.type == MilestoneType.percentComplete75 &&
              milestone.debtId == paidOffDebt.id,
        ),
        hasLength(1),
      );
      expect(
        unseen.where(
          (milestone) =>
              milestone.type == MilestoneType.debtPaidOff &&
              milestone.debtId == paidOffDebt.id,
        ),
        hasLength(1),
      );
      expect(
        unseen.where(
          (milestone) => milestone.type == MilestoneType.allDebtFree,
        ),
        hasLength(1),
      );
    },
  );
}
