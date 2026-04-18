import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debt_form_cubit.dart';

import '../data/repositories/repository_test_helpers.dart';
import '../helpers/test_app_harness.dart';

void main() {
  group('Phase 3 E2 integration', () {
    test('debt save + plan persistence + onboarding completion stay consistent', () async {
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
      expect(storedDebts.map((debt) => debt.name), containsAll(['Visa', 'Car Loan']));
      expect(storedPlan!.strategy, Strategy.avalanche);
      expect(storedPlan.extraMonthlyAmount, 25000);
      expect(storedSettings.onboardingCompleted, isTrue);
      expect(storedSettings.onboardingCompletedAt, isNotNull);
    });

    test('debt CRUD integration preserves archive/delete semantics', () async {
      final harness = await TestAppHarness.create();
      addTearDown(harness.dispose);

      final paidOffDebt = makeRepoDebt(
        id: 'paid-off',
        name: 'Paid Off',
        currentBalance: 0,
        status: DebtStatus.paidOff,
      );
      final activeDebt = makeRepoDebt(
        id: 'active',
        name: 'Active',
      );

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
  });
}
