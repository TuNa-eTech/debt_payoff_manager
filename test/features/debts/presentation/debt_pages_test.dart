import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/l10n/app_localizations.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/di/injection.dart';
import 'package:debt_payoff_manager/core/services/payment_logging_service.dart';
import 'package:debt_payoff_manager/core/widgets/debt_card.dart'
    as shared_debt_card;
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/domain/entities/debt.dart';
import 'package:debt_payoff_manager/domain/entities/payment.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/payment_repository.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debt_form_cubit.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_cubit.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_state.dart';
import 'package:debt_payoff_manager/features/debts/presentation/pages/add_debt_page.dart';
import 'package:debt_payoff_manager/features/debts/presentation/pages/debt_detail_page.dart';
import 'package:debt_payoff_manager/features/debts/presentation/pages/debts_list_page.dart';
import 'package:debt_payoff_manager/features/debts/presentation/pages/log_payment_page.dart';
import 'package:debt_payoff_manager/features/debts/presentation/pages/payment_history_page.dart';

import '../../../data/repositories/repository_test_helpers.dart';

class _MockDebtRepository extends Mock implements DebtRepository {}

class _MockPaymentRepository extends Mock implements PaymentRepository {}

class _MockPaymentLoggingService extends Mock
    implements PaymentLoggingService {}

class _TestDebtsCubit extends DebtsCubit {
  _TestDebtsCubit() : super(debtRepository: _MockDebtRepository());

  void seed(DebtsState nextState) => emit(nextState);
}

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(makeRepoDebt());
  });

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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<DebtsCubit>.value(
            value: cubit,
            child: const DebtsListPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Active debt'), findsOneWidget);
      expect(find.text('Paid debt'), findsOneWidget);

      await tester.tap(find.text('Paid (1)'));
      await tester.pump();

      expect(find.text('Paid debt'), findsOneWidget);
      expect(find.text('Active debt'), findsNothing);

      await tester.tap(find.text('Archived (1)'));
      await tester.pump();

      expect(find.text('Archived debt'), findsOneWidget);
      expect(find.text('Paid debt'), findsNothing);
    });

    testWidgets('shared debt form validates required fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
        expect(addButtonData.label, contains('Add debt'));

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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
      expect(find.text('1,500.00'), findsOneWidget);
      expect(find.text('1,800.00'), findsOneWidget);
    });

    testWidgets(
      'debt detail keeps the same debt stream across parent rebuilds',
      (tester) async {
        final repository = _MockDebtRepository();
        final debtStream = StreamController<dynamic>.broadcast();
        var watchCalls = 0;

        addTearDown(() async {
          await debtStream.close();
          await getIt.reset();
        });

        await getIt.reset();
        getIt.registerSingleton<DebtRepository>(repository);
        when(() => repository.watchDebtById('stable-detail')).thenAnswer((_) {
          watchCalls += 1;
          return debtStream.stream.cast<Debt?>();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DebtDetailPage(id: 'stable-detail'),
          ),
        );
        debtStream.add(makeRepoDebt(id: 'stable-detail', name: 'Stable debt'));
        await tester.pump();

        expect(find.text('Stable debt'), findsOneWidget);
        expect(watchCalls, 1);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DebtDetailPage(id: 'stable-detail'),
          ),
        );
        await tester.pump();

        expect(find.text('Stable debt'), findsOneWidget);
        expect(watchCalls, 1);
      },
    );

    testWidgets('debt detail undo snackbar auto-dismisses without action', (
      tester,
    ) async {
      final repository = _MockDebtRepository();
      final cubit = DebtsCubit(debtRepository: repository);
      final paidOffDebt = makeRepoDebt(
        id: 'snackbar-timeout',
        name: 'Snackbar timeout',
        currentBalance: 0,
        status: DebtStatus.paidOff,
      );

      addTearDown(() async {
        await cubit.close();
        await getIt.reset();
      });

      await getIt.reset();
      getIt.registerSingleton<DebtRepository>(repository);
      when(
        () => repository.watchDebtById('snackbar-timeout'),
      ).thenAnswer((_) => Stream<Debt?>.value(paidOffDebt));
      when(() => repository.updateDebt(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<DebtsCubit>.value(
            value: cubit,
            child: const DebtDetailPage(id: 'snackbar-timeout'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(AppTestKeys.debtDetailMore));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppTestKeys.debtOptionArchive));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppTestKeys.dialogConfirmPrimary));
      await tester.pumpAndSettle();

      expect(find.byKey(AppTestKeys.snackbarUndo), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets(
      'log payment keeps the same debt stream across local rebuilds',
      (tester) async {
        final repository = _MockDebtRepository();
        final paymentLoggingService = _MockPaymentLoggingService();
        final debtStream = StreamController<dynamic>.broadcast();
        var watchCalls = 0;

        addTearDown(() async {
          await debtStream.close();
          await getIt.reset();
        });

        await getIt.reset();
        getIt
          ..registerSingleton<DebtRepository>(repository)
          ..registerSingleton<PaymentLoggingService>(paymentLoggingService);
        when(() => repository.watchDebtById('log-stable')).thenAnswer((_) {
          watchCalls += 1;
          return debtStream.stream.cast<Debt?>();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LogPaymentPage(id: 'log-stable'),
          ),
        );
        debtStream.add(makeRepoDebt(id: 'log-stable', name: 'Log stable debt'));
        await tester.pump();

        expect(find.text('Log stable debt'), findsOneWidget);
        expect(watchCalls, 1);

        await tester.tap(find.byKey(AppTestKeys.paymentTypeExtra));
        await tester.pump();

        expect(find.text('Log stable debt'), findsOneWidget);
        expect(watchCalls, 1);
      },
    );

    testWidgets(
      'payment history keeps debt and payment streams across month changes',
      (tester) async {
        final debtRepository = _MockDebtRepository();
        final paymentRepository = _MockPaymentRepository();
        final debtStream = StreamController<dynamic>.broadcast();
        final paymentStream = StreamController<dynamic>.broadcast();
        var debtWatchCalls = 0;
        var paymentWatchCalls = 0;

        addTearDown(() async {
          await debtStream.close();
          await paymentStream.close();
          await getIt.reset();
        });

        await getIt.reset();
        getIt
          ..registerSingleton<DebtRepository>(debtRepository)
          ..registerSingleton<PaymentRepository>(paymentRepository);
        when(() => debtRepository.watchDebtById('history-stable')).thenAnswer((
          _,
        ) {
          debtWatchCalls += 1;
          return debtStream.stream.cast<Debt?>();
        });
        when(
          () => paymentRepository.watchPaymentsForDebt('history-stable'),
        ).thenAnswer((_) {
          paymentWatchCalls += 1;
          return paymentStream.stream.cast<List<Payment>>();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PaymentHistoryPage(id: 'history-stable'),
          ),
        );
        debtStream.add(
          makeRepoDebt(id: 'history-stable', name: 'History stable debt'),
        );
        await tester.pump();

        paymentStream.add([
          makeRepoPayment(
            id: 'payment-may',
            debtId: 'history-stable',
            date: DateTime(2026, 5, 10),
          ),
          makeRepoPayment(
            id: 'payment-apr',
            debtId: 'history-stable',
            date: DateTime(2026, 4, 10),
          ),
        ]);
        await tester.pumpAndSettle();

        expect(find.text('History stable debt'), findsOneWidget);
        expect(debtWatchCalls, 1);
        expect(paymentWatchCalls, 1);

        final aprilChip = find.byKey(
          AppTestKeys.paymentHistoryMonthChip('2026-04'),
        );
        await tester.ensureVisible(aprilChip);
        await tester.tap(aprilChip);
        await tester.pump();

        expect(find.text('History stable debt'), findsOneWidget);
        expect(debtWatchCalls, 1);
        expect(paymentWatchCalls, 1);
      },
    );
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
