import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debt_form_cubit.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_cubit.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_state.dart';
import 'package:debt_payoff_manager/features/debts/presentation/pages/add_debt_page.dart';
import 'package:debt_payoff_manager/features/debts/presentation/pages/debts_list_page.dart';

import '../../../data/repositories/repository_test_helpers.dart';

class _MockDebtRepository extends Mock implements DebtRepository {}

class _TestDebtsCubit extends DebtsCubit {
  _TestDebtsCubit() : super(debtRepository: _MockDebtRepository());

  void seed(DebtsState nextState) => emit(nextState);
}

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

  group('Debt pages', () {
    testWidgets('debts list filters visible debts by chip', (tester) async {
      final cubit = _TestDebtsCubit()
        ..seed(
          DebtsState(
            isLoading: false,
            debts: [
              makeRepoDebt(id: 'active', name: 'Active debt'),
              makeRepoDebt(
                id: 'paid',
                name: 'Paid debt',
                currentBalance: 0,
                status: DebtStatus.paidOff,
              ),
              makeRepoDebt(
                id: 'archived',
                name: 'Archived debt',
                currentBalance: 0,
                status: DebtStatus.archived,
              ),
            ],
          ),
        );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DebtsCubit>.value(
            value: cubit,
            child: const DebtsListPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Active debt'), findsOneWidget);
      expect(find.text('Paid debt'), findsOneWidget);

      await tester.tap(find.text('Đã trả (1)'));
      await tester.pump();

      expect(find.text('Paid debt'), findsOneWidget);
      expect(find.text('Active debt'), findsNothing);

      await tester.tap(find.text('Đã lưu trữ (1)'));
      await tester.pump();

      expect(find.text('Archived debt'), findsOneWidget);
      expect(find.text('Paid debt'), findsNothing);
    });

    testWidgets('shared debt form validates required fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => DebtFormCubit.create(
              debtRepository: repo,
              mode: DebtFormMode.create,
            ),
            child: DebtFormScaffold(
              mode: DebtFormMode.create,
              title: 'Thêm khoản nợ',
              primaryActionLabel: 'Lưu khoản nợ',
              onSaved: (context, debt) {},
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Lưu khoản nợ'));
      await tester.pump();

      expect(find.text('Nhập tên khoản nợ.'), findsOneWidget);
    });

    testWidgets('edit debt form prefills existing values', (tester) async {
      final existingDebt = makeRepoDebt(
        id: 'edit-me',
        name: 'Editable debt',
        currentBalance: 150000,
        originalPrincipal: 180000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => DebtFormCubit.edit(
              debtRepository: repo,
              debt: existingDebt,
            ),
            child: DebtFormScaffold(
              mode: DebtFormMode.edit,
              title: 'Chỉnh sửa khoản nợ',
              primaryActionLabel: 'Lưu thay đổi',
              onSaved: (context, debt) {},
              onCancel: () {},
              initialDebt: existingDebt,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Editable debt'), findsOneWidget);
      expect(find.text('1500.00'), findsOneWidget);
      expect(find.text('1800.00'), findsOneWidget);
    });
  });
}
