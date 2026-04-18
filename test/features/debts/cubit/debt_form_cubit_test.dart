import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debt_form_cubit.dart';

import '../../../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DebtRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DebtFormCubit', () {
    test('maps default interest method by debt type', () {
      final cubit = DebtFormCubit.create(
        debtRepository: repo,
        mode: DebtFormMode.create,
      );

      cubit.setDebtType(DebtType.carLoan);
      expect(cubit.state.interestMethod.label, 'Compound Monthly');

      cubit.setDebtType(DebtType.studentLoan);
      expect(cubit.state.interestMethod.label, 'Simple Monthly');

      cubit.close();
    });

    test('save uses current balance as original principal and default due day', () async {
      final cubit = DebtFormCubit.create(
        debtRepository: repo,
        mode: DebtFormMode.onboarding,
      );

      final debt = await cubit.save(
        nameInput: 'Visa',
        originalPrincipalInput: '',
        currentBalanceInput: '1200',
        aprInput: '19.99',
        minimumPaymentInput: '45',
        dueDayInput: '',
        minimumPaymentPercentInput: '',
        minimumPaymentFloorInput: '',
      );

      expect(debt, isNotNull);
      expect(debt!.originalPrincipal, 120000);
      expect(debt.dueDayOfMonth, 15);
      expect(debt.firstDueDate.day, 15);

      await cubit.close();
    });

    test('requires pausedUntil when paused', () async {
      final cubit = DebtFormCubit.create(
        debtRepository: repo,
        mode: DebtFormMode.create,
      );
      cubit.setStatus(DebtStatus.paused);

      final debt = await cubit.save(
        nameInput: 'Paused debt',
        originalPrincipalInput: '1000',
        currentBalanceInput: '900',
        aprInput: '12',
        minimumPaymentInput: '40',
        dueDayInput: '12',
        minimumPaymentPercentInput: '',
        minimumPaymentFloorInput: '',
      );

      expect(debt, isNull);
      expect(cubit.state.pausedUntilError, 'Chọn ngày kết thúc tạm dừng.');

      await cubit.close();
    });

    test('generates soft warnings for high APR and negative amortization', () {
      final cubit = DebtFormCubit.create(
        debtRepository: repo,
        mode: DebtFormMode.create,
      );

      cubit.refreshWarnings(
        originalPrincipalInput: '1000',
        currentBalanceInput: '1700',
        aprInput: '49',
        minimumPaymentInput: '5',
      );

      expect(cubit.state.warnings, isNotEmpty);
      expect(
        cubit.state.warnings.any((warning) => warning.contains('APR cao')),
        isTrue,
      );

      cubit.close();
    });

    test('edit mode preserves existing id and paidOffAt when saved', () async {
      final existing = makeRepoDebt(
        id: 'paid-off',
        currentBalance: 0,
        originalPrincipal: 150000,
        apr: Decimal.parse('0.12'),
        status: DebtStatus.paidOff,
      );
      await repo.addDebt(existing.copyWith(paidOffAt: DateTime.utc(2026, 1, 10)));

      final cubit = DebtFormCubit.edit(
        debtRepository: repo,
        debt: (await repo.getDebtById('paid-off'))!,
      );

      final saved = await cubit.save(
        nameInput: 'Paid off debt',
        originalPrincipalInput: '1500',
        currentBalanceInput: '0',
        aprInput: '12',
        minimumPaymentInput: '40',
        dueDayInput: '15',
        minimumPaymentPercentInput: '',
        minimumPaymentFloorInput: '',
      );

      expect(saved, isNotNull);
      expect(saved!.id, 'paid-off');
      expect(saved.paidOffAt, isNotNull);

      await cubit.close();
    });
  });
}
