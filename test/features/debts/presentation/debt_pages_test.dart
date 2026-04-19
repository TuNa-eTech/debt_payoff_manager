import 'dart:ui' show SemanticsAction;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/widgets/debt_card.dart'
    as shared_debt_card;
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

    testWidgets(
      'shared debt form clears inline validation as fields become valid',
      (tester) async {
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

        await tester.enterText(
          _textFormFieldFor(AppTestKeys.debtFormName),
          'Visa',
        );
        await tester.pump();

        expect(find.text('Nhập tên khoản nợ.'), findsNothing);
      },
    );

    testWidgets('shared overdue debt card renders an overdue badge', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: shared_debt_card.DebtCard(
                name: 'Past Due Card',
                balance: '\$1,200',
                apr: '19.99%',
                minPayment: '\$45/tháng',
                dueDate: 'Ngày 15',
                state: shared_debt_card.DebtCardState.overdue,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('QUÁ HẠN'), findsOneWidget);
        expect(find.text('Ngày 15'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('debts list surfaces overdue state from debt data', (
      tester,
    ) async {
      final cubit = _TestDebtsCubit()
        ..seed(
          DebtsState(
            isLoading: false,
            debts: [
              makeRepoDebt(
                id: 'overdue-live',
                name: 'Overdue debt',
                dueDayOfMonth: 10,
                firstDueDate: DateTime(2026, 1, 10),
              ),
            ],
          ),
        );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DebtsCubit>.value(
            value: cubit,
            child: DebtsListPage(referenceDate: DateTime(2026, 4, 18)),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Overdue debt'), findsOneWidget);
      expect(find.textContaining('Quá hạn 8 ngày'), findsOneWidget);
    });

    testWidgets('debts list exposes tappable debt card semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final cubit = _TestDebtsCubit()
        ..seed(
          DebtsState(
            isLoading: false,
            debts: [makeRepoDebt(id: 'accessible', name: 'Accessible debt')],
          ),
        );
      addTearDown(cubit.close);

      try {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<DebtsCubit>.value(
              value: cubit,
              child: const DebtsListPage(),
            ),
          ),
        );
        await tester.pump();

        final addButtonData = tester
            .getSemantics(find.byKey(AppTestKeys.debtsAddFab))
            .getSemanticsData();
        expect(addButtonData.hasAction(SemanticsAction.tap), isTrue);
        expect(addButtonData.label, contains('Thêm nợ'));

        final cardData = tester
            .getSemantics(_debtCardTapTarget('accessible'))
            .getSemanticsData();
        expect(cardData.hasAction(SemanticsAction.tap), isTrue);
        expect(cardData.label, contains('Accessible debt'));
        expect(cardData.label, contains('APR'));
      } finally {
        semantics.dispose();
      }
    });

    testWidgets(
      'shared debt form exposes labeled text fields and save action',
      (tester) async {
        final semantics = tester.ensureSemantics();

        try {
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

          final nameFieldData = tester
              .getSemantics(_textFormFieldFor(AppTestKeys.debtFormName))
              .getSemanticsData();
          expect(nameFieldData.flagsCollection.isTextField, isTrue);
          expect(nameFieldData.label, contains('Tên khoản nợ'));

          final balanceFieldData = tester
              .getSemantics(
                _textFormFieldFor(AppTestKeys.debtFormCurrentBalance),
              )
              .getSemanticsData();
          expect(balanceFieldData.flagsCollection.isTextField, isTrue);
          expect(balanceFieldData.label, contains('Số dư'));

          final saveButtonData = tester
              .getSemantics(find.byKey(AppTestKeys.debtFormSave))
              .getSemanticsData();
          expect(saveButtonData.hasAction(SemanticsAction.tap), isTrue);
          expect(saveButtonData.label, contains('Lưu khoản nợ'));
        } finally {
          semantics.dispose();
        }
      },
    );

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
            create: (_) =>
                DebtFormCubit.edit(debtRepository: repo, debt: existingDebt),
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

Finder _debtCardTapTarget(String debtId) {
  return find.descendant(
    of: find.byKey(AppTestKeys.debtCard(debtId)),
    matching: find.byWidgetPredicate((widget) => widget is GestureDetector),
  );
}

Finder _textFormFieldFor(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextFormField),
  );
}
