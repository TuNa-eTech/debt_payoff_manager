import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/domain/entities/debt.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debt_form_cubit.dart';

import '../data/repositories/repository_test_helpers.dart';
import '../helpers/test_app_harness.dart';

void main() {
  group('Phase 3 E2 integration', () {
    test(
      'debt save + plan persistence + onboarding completion stay consistent',
      () async {
        final harness = await TestAppHarness.create();
        addTearDown(harness.dispose);

        final firstDebtCubit = DebtFormCubit.create(
          debtRepository: harness.debtRepository,
          mode: DebtFormMode.onboarding,
        );
        addTearDown(firstDebtCubit.close);

        final secondDebtCubit = DebtFormCubit.create(
          debtRepository: harness.debtRepository,
          mode: DebtFormMode.create,
        );
        addTearDown(secondDebtCubit.close);

        final firstDebt = await firstDebtCubit.save(
          nameInput: 'Visa',
          originalPrincipalInput: '',
          currentBalanceInput: '1200',
          aprInput: '19.99',
          minimumPaymentInput: '45',
          dueDayInput: '',
          minimumPaymentPercentInput: '',
          minimumPaymentFloorInput: '',
        );
        final secondDebt = await secondDebtCubit.save(
          nameInput: 'Car Loan',
          originalPrincipalInput: '8000',
          currentBalanceInput: '7200',
          aprInput: '6.5',
          minimumPaymentInput: '180',
          dueDayInput: '20',
          minimumPaymentPercentInput: '',
          minimumPaymentFloorInput: '',
        );

        expect(firstDebt, isNotNull);
        expect(secondDebt, isNotNull);

        final seededPlan = await harness.planRepository.getCurrentPlan();
        await harness.planRepository.savePlan(
          seededPlan!.copyWith(
            strategy: Strategy.avalanche,
            extraMonthlyAmount: 25000,
          ),
        );
        await harness.onboardingCubit.completeOnboarding();
        await Future<void>.delayed(Duration.zero);

        final storedDebts = await harness.debtRepository.getAllDebts();
        final storedPlan = await harness.planRepository.getCurrentPlan();
        final storedSettings = await harness.settingsRepository.getSettings();

        expect(storedDebts, hasLength(2));
        expect(
          storedDebts.map((debt) => debt.name),
          containsAll(['Visa', 'Car Loan']),
        );
        expect(storedPlan!.strategy, Strategy.avalanche);
        expect(storedPlan.extraMonthlyAmount, 25000);
        expect(storedSettings.onboardingCompleted, isTrue);
        expect(storedSettings.onboardingCompletedAt, isNotNull);
      },
    );

    test('debt CRUD integration preserves archive/delete semantics', () async {
      final harness = await TestAppHarness.create();
      addTearDown(harness.dispose);

      final paidOffDebt = makeRepoDebt(
        id: 'paid-off',
        name: 'Paid Off',
        currentBalance: 0,
        status: DebtStatus.paidOff,
      );
      final activeDebt = makeRepoDebt(id: 'active', name: 'Active');

      await harness.debtRepository.addDebt(paidOffDebt);
      await harness.debtRepository.addDebt(activeDebt);
      await Future<void>.delayed(Duration.zero);

      await harness.debtsCubit.archiveDebt(paidOffDebt);
      expect(
        (await harness.debtRepository.getDebtById('paid-off'))!.status,
        DebtStatus.archived,
      );

      await harness.debtsCubit.deleteDebt(activeDebt);
      expect(await harness.debtRepository.getDebtById('active'), isNull);

      await harness.debtsCubit.restoreDebt(activeDebt);
      final restored = await harness.debtRepository.getDebtById('active');
      expect(restored, isNotNull);
      expect(restored!.deletedAt, isNull);
    });

    test(
      'creating five debts, editing one, and archiving one keeps DB state consistent',
      () async {
        final harness = await TestAppHarness.create();
        addTearDown(harness.dispose);

        final createdDebts = [
          await _createDebt(
            harness: harness,
            name: 'Visa Platinum',
            type: DebtType.creditCard,
            originalPrincipalInput: '5000',
            currentBalanceInput: '4200',
            aprInput: '19.99',
            minimumPaymentInput: '120',
            dueDayInput: '15',
          ),
          await _createDebt(
            harness: harness,
            name: 'Student Loan',
            type: DebtType.studentLoan,
            originalPrincipalInput: '24000',
            currentBalanceInput: '21000',
            aprInput: '4.25',
            minimumPaymentInput: '280',
            dueDayInput: '8',
          ),
          await _createDebt(
            harness: harness,
            name: 'Car Loan',
            type: DebtType.carLoan,
            originalPrincipalInput: '18000',
            currentBalanceInput: '14600',
            aprInput: '6.10',
            minimumPaymentInput: '320',
            dueDayInput: '20',
          ),
          await _createDebt(
            harness: harness,
            name: 'Medical Bill',
            type: DebtType.medical,
            originalPrincipalInput: '3500',
            currentBalanceInput: '2800',
            aprInput: '0',
            minimumPaymentInput: '90',
            dueDayInput: '11',
          ),
          await _createDebt(
            harness: harness,
            name: 'Paid Off Auto',
            type: DebtType.carLoan,
            status: DebtStatus.paidOff,
            originalPrincipalInput: '12000',
            currentBalanceInput: '0',
            aprInput: '5.75',
            minimumPaymentInput: '250',
            dueDayInput: '18',
          ),
        ];

        expect(createdDebts, hasLength(5));

        final debtsAfterCreate = await harness.debtRepository.getAllDebts();
        expect(debtsAfterCreate, hasLength(5));
        expect(
          debtsAfterCreate.map((debt) => debt.name),
          containsAll([
            'Visa Platinum',
            'Student Loan',
            'Car Loan',
            'Medical Bill',
            'Paid Off Auto',
          ]),
        );

        final debtToEdit = debtsAfterCreate.firstWhere(
          (debt) => debt.name == 'Student Loan',
        );
        final editCubit = DebtFormCubit.edit(
          debtRepository: harness.debtRepository,
          debt: debtToEdit,
        );
        addTearDown(editCubit.close);

        final editedDebt = await editCubit.save(
          nameInput: 'Student Loan Refi',
          originalPrincipalInput: '24000',
          currentBalanceInput: '20500',
          aprInput: '3.90',
          minimumPaymentInput: '300',
          dueDayInput: '10',
          minimumPaymentPercentInput: '',
          minimumPaymentFloorInput: '',
        );

        expect(editedDebt, isNotNull);

        final debtToArchive = debtsAfterCreate.firstWhere(
          (debt) => debt.name == 'Paid Off Auto',
        );
        await harness.debtsCubit.archiveDebt(debtToArchive);
        await Future<void>.delayed(Duration.zero);

        final storedDebts = await harness.debtRepository.getAllDebts();
        expect(storedDebts, hasLength(5));

        final storedEditedDebt = storedDebts.firstWhere(
          (debt) => debt.id == debtToEdit.id,
        );
        expect(storedEditedDebt.name, 'Student Loan Refi');
        expect(storedEditedDebt.currentBalance, 2050000);
        expect(storedEditedDebt.minimumPayment, 30000);
        expect(storedEditedDebt.dueDayOfMonth, 10);

        final storedArchivedDebt = storedDebts.firstWhere(
          (debt) => debt.id == debtToArchive.id,
        );
        expect(storedArchivedDebt.status, DebtStatus.archived);
        expect(storedArchivedDebt.currentBalance, 0);
      },
    );
  });
}

Future<Debt> _createDebt({
  required TestAppHarness harness,
  required String name,
  required DebtType type,
  required String originalPrincipalInput,
  required String currentBalanceInput,
  required String aprInput,
  required String minimumPaymentInput,
  required String dueDayInput,
  DebtStatus status = DebtStatus.active,
}) async {
  final cubit = DebtFormCubit.create(
    debtRepository: harness.debtRepository,
    mode: DebtFormMode.create,
  );

  try {
    cubit.setDebtType(type);
    cubit.setStatus(status);

    final debt = await cubit.save(
      nameInput: name,
      originalPrincipalInput: originalPrincipalInput,
      currentBalanceInput: currentBalanceInput,
      aprInput: aprInput,
      minimumPaymentInput: minimumPaymentInput,
      dueDayInput: dueDayInput,
      minimumPaymentPercentInput: '',
      minimumPaymentFloorInput: '',
    );

    expect(debt, isNotNull, reason: 'Expected $name to save successfully.');
    return debt!;
  } finally {
    await cubit.close();
  }
}
