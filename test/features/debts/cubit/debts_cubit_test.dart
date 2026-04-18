import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_cubit.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_state.dart';

import '../../../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl repo;
  late DebtsCubit cubit;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DebtRepositoryImpl(db: db);
    cubit = DebtsCubit(debtRepository: repo);
    await cubit.start();
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  group('DebtsCubit', () {
    test('hydrates live debts from repository stream', () async {
      await repo.addDebt(makeRepoDebt(id: 'debt-a', name: 'Debt A'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.debts, hasLength(1));
      expect(cubit.state.debts.single.name, 'Debt A');
    });

    test('filters debts by lifecycle bucket', () async {
      await repo.addDebt(
        makeRepoDebt(id: 'active', status: DebtStatus.active),
      );
      await repo.addDebt(
        makeRepoDebt(id: 'paid', status: DebtStatus.paidOff),
      );
      await repo.addDebt(
        makeRepoDebt(id: 'archived', status: DebtStatus.archived),
      );
      await repo.addDebt(
        makeRepoDebt(
          id: 'paused',
          status: DebtStatus.paused,
          pausedUntil: DateTime.utc(2026, 2, 1),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      cubit.setFilter(DebtsFilter.active);
      expect(cubit.state.visibleDebts.map((debt) => debt.id), ['active', 'paused']);

      cubit.setFilter(DebtsFilter.paidOff);
      expect(cubit.state.visibleDebts.map((debt) => debt.id), ['paid']);

      cubit.setFilter(DebtsFilter.archived);
      expect(cubit.state.visibleDebts.map((debt) => debt.id), ['archived']);
    });

    test('archive, delete, and restore update repository state', () async {
      final debt = makeRepoDebt(id: 'target', name: 'Target Debt');
      await repo.addDebt(debt);
      await Future<void>.delayed(Duration.zero);

      await cubit.archiveDebt(debt.copyWith(status: DebtStatus.paidOff));
      final archived = await repo.getDebtById('target');
      expect(archived!.status, DebtStatus.archived);

      await cubit.deleteDebt(archived);
      expect(await repo.getDebtById('target'), isNull);

      await cubit.restoreDebt(archived);
      final restored = await repo.getDebtById('target');
      expect(restored, isNotNull);
      expect(restored!.deletedAt, isNull);
    });

    test('surfaces repository validation errors inline', () async {
      final invalid = makeRepoDebt(
        id: 'paused-missing-date',
        status: DebtStatus.paused,
      );

      await cubit.addDebt(invalid);

      expect(cubit.state.inlineError, contains('pausedUntil required'));
    });
  });
}
