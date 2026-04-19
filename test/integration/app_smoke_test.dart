import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/router/app_router.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';

import '../data/repositories/repository_test_helpers.dart';
import '../helpers/test_app_harness.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('App smoke suite', () {
    testWidgets(
      'fresh launch completes onboarding through the real app shell',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.welcome);

        await _tapButton(tester, AppTestKeys.welcomeAddFirstDebt);
        await _pumpUntilLocation(tester, harness, AppRoutes.debtEntry);

        await _enterText(tester, AppTestKeys.debtFormName, 'Visa Platinum');
        await _enterText(tester, AppTestKeys.debtFormCurrentBalance, '1200');
        await _enterText(tester, AppTestKeys.debtFormApr, '19.99');
        await _enterText(tester, AppTestKeys.debtFormMinimumPayment, '45');

        await _tapButton(tester, AppTestKeys.debtFormSave);
        await _pumpUntilLocation(tester, harness, AppRoutes.addAnotherDebt);

        await _tapButton(tester, AppTestKeys.onboardingAddAnotherContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.strategySelection);

        await _tapButton(tester, AppTestKeys.onboardingStrategyContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.extraAmount);

        await _tapButton(tester, AppTestKeys.onboardingExtraContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.ahaMoment);

        await _tapButton(tester, AppTestKeys.onboardingComplete);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);

        final debts = await harness.debtRepository.getAllDebts();
        final settings = await harness.settingsRepository.getSettings();
        final plan = await harness.planRepository.getCurrentPlan();

        expect(debts, hasLength(1));
        expect(debts.single.name, 'Visa Platinum');
        expect(settings.onboardingCompleted, isTrue);
        expect(settings.onboardingCompletedAt, isNotNull);
        expect(plan, isNotNull);
        expect(plan!.strategy, Strategy.snowball);
        expect(plan.extraMonthlyAmount, 0);
      },
    );

    testWidgets(
      'relaunch skips onboarding and redirects welcome back to home',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.debtRepository.addDebt(
          makeRepoDebt(id: 'seed-home', name: 'Seed debt'),
        );
        await harness.onboardingCubit.completeOnboarding();

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);

        await harness.relaunch(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);

        harness.router.go(AppRoutes.welcome);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);
      },
    );

    testWidgets(
      'onboarding back navigation returns to the previous logical step',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.welcome);

        await _tapButton(tester, AppTestKeys.welcomeAddFirstDebt);
        await _pumpUntilLocation(tester, harness, AppRoutes.debtEntry);

        await _enterText(tester, AppTestKeys.debtFormName, 'Visa Platinum');
        await _enterText(tester, AppTestKeys.debtFormCurrentBalance, '1200');
        await _enterText(tester, AppTestKeys.debtFormApr, '19.99');
        await _enterText(tester, AppTestKeys.debtFormMinimumPayment, '45');

        await _tapButton(tester, AppTestKeys.debtFormSave);
        await _pumpUntilLocation(tester, harness, AppRoutes.addAnotherDebt);

        await _tapButton(tester, AppTestKeys.onboardingAddAnotherDebt);
        await _pumpUntilLocation(tester, harness, AppRoutes.debtEntry);

        await _tapButton(tester, AppTestKeys.onboardingDebtEntryBack);
        await _pumpUntilLocation(tester, harness, AppRoutes.addAnotherDebt);

        await _tapButton(tester, AppTestKeys.onboardingAddAnotherContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.strategySelection);

        await _tapButton(tester, AppTestKeys.onboardingStrategyBack);
        await _pumpUntilLocation(tester, harness, AppRoutes.addAnotherDebt);

        await _tapButton(tester, AppTestKeys.onboardingAddAnotherContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.strategySelection);

        await _tapButton(tester, AppTestKeys.onboardingStrategyContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.extraAmount);

        await _tapButton(tester, AppTestKeys.onboardingExtraBack);
        await _pumpUntilLocation(tester, harness, AppRoutes.strategySelection);

        await _tapButton(tester, AppTestKeys.onboardingStrategyContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.extraAmount);

        await _tapButton(tester, AppTestKeys.onboardingExtraContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.ahaMoment);

        await _tapButton(tester, AppTestKeys.onboardingAhaBack);
        await _pumpUntilLocation(tester, harness, AppRoutes.extraAmount);
      },
    );

    testWidgets(
      'platform back during onboarding updates persisted resume step',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.welcome);

        await _tapButton(tester, AppTestKeys.welcomeAddFirstDebt);
        await _pumpUntilLocation(tester, harness, AppRoutes.debtEntry);

        await _enterText(tester, AppTestKeys.debtFormName, 'Visa Platinum');
        await _enterText(tester, AppTestKeys.debtFormCurrentBalance, '1200');
        await _enterText(tester, AppTestKeys.debtFormApr, '19.99');
        await _enterText(tester, AppTestKeys.debtFormMinimumPayment, '45');

        await _tapButton(tester, AppTestKeys.debtFormSave);
        await _pumpUntilLocation(tester, harness, AppRoutes.addAnotherDebt);

        await _tapButton(tester, AppTestKeys.onboardingAddAnotherContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.strategySelection);

        await _tapButton(tester, AppTestKeys.onboardingStrategyContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.extraAmount);

        await _tapButton(tester, AppTestKeys.onboardingExtraContinue);
        await _pumpUntilLocation(tester, harness, AppRoutes.ahaMoment);

        await tester.binding.handlePopRoute();
        await _pumpUntilLocation(tester, harness, AppRoutes.extraAmount);

        await harness.relaunch(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.extraAmount);
      },
    );

    testWidgets(
      'debt CRUD works through the real shell and stays in sync with persistence',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.onboardingCubit.completeOnboarding();

        await harness.pumpApp(tester);

        await _tapNavTab(tester, AppTestKeys.navDebtsTab);
        await _pumpUntilLocation(tester, harness, AppRoutes.debts);

        await tester.tap(find.byKey(AppTestKeys.debtsAddFab));
        await _pumpUntilLocation(tester, harness, AppRoutes.addDebt);

        await _enterText(tester, AppTestKeys.debtFormName, 'Travel Card');
        await _enterText(tester, AppTestKeys.debtFormCurrentBalance, '1500');
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.debtFormAdvancedToggle),
        );
        await tester.ensureVisible(
          find.byKey(AppTestKeys.debtFormAdvancedToggle),
        );
        await tester.tap(find.byKey(AppTestKeys.debtFormAdvancedToggle));
        await tester.pumpRouterIdle();
        await _enterText(tester, AppTestKeys.debtFormOriginalPrincipal, '2000');
        await _enterText(tester, AppTestKeys.debtFormApr, '18.50');
        await _enterText(tester, AppTestKeys.debtFormMinimumPayment, '50');
        await _enterText(tester, AppTestKeys.debtFormDueDay, '12');

        await _tapButton(tester, AppTestKeys.debtFormSave);
        await _pumpUntilLocation(tester, harness, AppRoutes.debts);

        final createdDebt = (await harness.debtRepository.getAllDebts())
            .singleWhere((debt) => debt.name == 'Travel Card');

        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.debtCard(createdDebt.id)),
        );
        await tester.tap(find.byKey(AppTestKeys.debtCard(createdDebt.id)));
        await _pumpUntilLocation(
          tester,
          harness,
          AppRoutes.debtDetailPath(createdDebt.id),
        );
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.debtDetail(createdDebt.id)),
        );
        expect(
          find.byKey(AppTestKeys.debtDetail(createdDebt.id)),
          findsOneWidget,
        );

        await _tapButton(
          tester,
          AppTestKeys.debtDetailEdit,
          scope: find.byKey(AppTestKeys.debtDetail(createdDebt.id)),
        );
        await tester.pumpUntilVisible(find.text('Chỉnh sửa khoản nợ'));

        await _enterText(
          tester,
          AppTestKeys.debtFormName,
          'Travel Card Updated',
        );
        await _enterText(tester, AppTestKeys.debtFormMinimumPayment, '65');

        await _tapButton(tester, AppTestKeys.debtFormSave);
        await _pumpUntilLocation(
          tester,
          harness,
          AppRoutes.debtDetailPath(createdDebt.id),
        );

        final updatedDebt = await harness.debtRepository.getDebtById(
          createdDebt.id,
        );
        expect(updatedDebt, isNotNull);
        expect(updatedDebt!.name, 'Travel Card Updated');
        expect(updatedDebt.minimumPayment, 6500);

        await _tapButton(tester, AppTestKeys.debtDetailMore);
        await _tapButton(tester, AppTestKeys.debtOptionDelete);
        await _tapButton(tester, AppTestKeys.dialogConfirmPrimary);

        await _pumpUntilLocation(tester, harness, AppRoutes.debts);
        expect(
          await harness.debtRepository.getDebtById(createdDebt.id),
          isNull,
        );
        expect(find.byKey(AppTestKeys.debtCard(createdDebt.id)), findsNothing);

        await _tapButton(tester, AppTestKeys.snackbarUndo);

        final restoredDebt = await harness.debtRepository.getDebtById(
          createdDebt.id,
        );
        expect(restoredDebt, isNotNull);
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.debtCard(createdDebt.id)),
        );
      },
    );

    testWidgets('settings sync opens outside the primary shell', (
      tester,
    ) async {
      final harness = await TestAppHarness.create();
      addTearDown(() => harness.disposeWidgetTest(tester));

      await harness.onboardingCubit.completeOnboarding();
      await harness.pumpApp(tester);
      await _pumpUntilLocation(tester, harness, AppRoutes.home);

      harness.router.go(AppRoutes.settings);
      await _pumpUntilLocation(tester, harness, AppRoutes.settings);

      final syncTile = find.text('Đồng bộ & Sao lưu');
      await tester.pumpUntilVisible(syncTile);
      await tester.ensureVisible(syncTile);
      await tester.tap(syncTile);
      await tester.pumpRouterIdle();
      await tester.pumpUntilVisible(find.text('Mở khoá Sao lưu'));

      harness.router.pop();
      await tester.pumpRouterIdle();
      await _pumpUntilLocation(tester, harness, AppRoutes.settings);
    });

    testWidgets('archive and unarchive respect paid-off only semantics', (
      tester,
    ) async {
      final harness = await TestAppHarness.create();
      addTearDown(() => harness.disposeWidgetTest(tester));

      final activeDebt = makeRepoDebt(id: 'active-debt', name: 'Active debt');
      final paidOffDebt = makeRepoDebt(
        id: 'paid-off-debt',
        name: 'Paid off debt',
        currentBalance: 0,
        status: DebtStatus.paidOff,
      );

      await harness.debtRepository.addDebt(activeDebt);
      await harness.debtRepository.addDebt(paidOffDebt);
      await harness.onboardingCubit.completeOnboarding();

      await harness.pumpApp(tester);
      await _pumpUntilLocation(tester, harness, AppRoutes.home);

      await _tapNavTab(tester, AppTestKeys.navDebtsTab);
      await _pumpUntilLocation(tester, harness, AppRoutes.debts);

      await tester.tap(find.byKey(AppTestKeys.debtCard(activeDebt.id)));
      await _pumpUntilLocation(
        tester,
        harness,
        AppRoutes.debtDetailPath(activeDebt.id),
      );
      await _tapButton(
        tester,
        AppTestKeys.debtDetailMore,
        scope: find.byKey(AppTestKeys.debtDetail(activeDebt.id)),
      );
      await tester.pumpUntilVisible(find.byKey(AppTestKeys.debtOptionDelete));
      expect(find.byKey(AppTestKeys.debtOptionArchive), findsNothing);
      harness.router.pop();
      await tester.pumpRouterIdle();
      harness.router.go(AppRoutes.debts);
      await _pumpUntilLocation(tester, harness, AppRoutes.debts);
      await tester.pumpUntilVisible(
        find.byKey(AppTestKeys.debtCard(paidOffDebt.id)),
      );

      await tester.tap(find.byKey(AppTestKeys.debtCard(paidOffDebt.id)));
      await _pumpUntilLocation(
        tester,
        harness,
        AppRoutes.debtDetailPath(paidOffDebt.id),
      );
      await _tapButton(
        tester,
        AppTestKeys.debtDetailMore,
        scope: find.byKey(AppTestKeys.debtDetail(paidOffDebt.id)),
      );
      await tester.pumpUntilVisible(find.byKey(AppTestKeys.debtOptionDelete));
      expect(find.byKey(AppTestKeys.debtOptionArchive), findsOneWidget);
      await _tapButton(tester, AppTestKeys.debtOptionArchive);
      await _tapButton(tester, AppTestKeys.dialogConfirmPrimary);

      expect(
        (await harness.debtRepository.getDebtById(paidOffDebt.id))!.status,
        DebtStatus.archived,
      );

      harness.router.go(AppRoutes.debts);
      await _pumpUntilLocation(tester, harness, AppRoutes.debts);
      await _tapChip(tester, AppTestKeys.debtsFilterArchived);
      expect(find.byKey(AppTestKeys.debtCard(paidOffDebt.id)), findsOneWidget);

      await tester.tap(find.byKey(AppTestKeys.debtCard(paidOffDebt.id)));
      await _pumpUntilLocation(
        tester,
        harness,
        AppRoutes.debtDetailPath(paidOffDebt.id),
      );
      await _tapButton(
        tester,
        AppTestKeys.debtDetailMore,
        scope: find.byKey(AppTestKeys.debtDetail(paidOffDebt.id)),
      );
      await tester.pumpUntilVisible(find.byKey(AppTestKeys.debtOptionDelete));
      expect(find.byKey(AppTestKeys.debtOptionUnarchive), findsOneWidget);
      await _tapButton(tester, AppTestKeys.debtOptionUnarchive);

      expect(
        (await harness.debtRepository.getDebtById(paidOffDebt.id))!.status,
        DebtStatus.paidOff,
      );

      harness.router.go(AppRoutes.debts);
      await _pumpUntilLocation(tester, harness, AppRoutes.debts);
      await _tapChip(tester, AppTestKeys.debtsFilterPaidOff);
      expect(find.byKey(AppTestKeys.debtCard(paidOffDebt.id)), findsOneWidget);
    });
  });
}

Future<void> _enterText(WidgetTester tester, Key key, String value) async {
  await tester.pumpUntilVisible(find.byKey(key));
  final finder = find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(finder, value);
  await tester.pump();
}

Future<void> _tapButton(WidgetTester tester, Key key, {Finder? scope}) async {
  final keyed = scope == null
      ? find.byKey(key)
      : find.descendant(of: scope, matching: find.byKey(key));
  await tester.pumpUntilVisible(keyed);
  final direct = keyed.hitTestable();
  final actionFinder = find.descendant(
    of: keyed,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is FilledButton ||
          widget is OutlinedButton ||
          widget is TextButton ||
          widget is IconButton,
    ),
  );
  final nested = actionFinder.hitTestable();

  if (direct.evaluate().isNotEmpty || nested.evaluate().isNotEmpty) {
    final target = direct.evaluate().isNotEmpty ? direct : nested;
    await tester.ensureVisible(target.first);
    await tester.tap(target.first);
    await tester.pumpRouterIdle();
    return;
  }

  final callbackTarget = actionFinder.evaluate().isNotEmpty
      ? actionFinder
      : keyed;
  final widget = callbackTarget.evaluate().first.widget;

  void Function()? onPressed;
  if (widget is IconButton) {
    onPressed = widget.onPressed;
  } else if (widget is FilledButton) {
    onPressed = widget.onPressed;
  } else if (widget is OutlinedButton) {
    onPressed = widget.onPressed;
  } else if (widget is TextButton) {
    onPressed = widget.onPressed;
  }

  if (onPressed == null) {
    throw TestFailure('No tappable callback found for key $key.');
  }

  onPressed();
  await tester.pumpRouterIdle();
}

Future<void> _tapChip(WidgetTester tester, Key key) async {
  await tester.pumpUntilVisible(find.byKey(key));
  final target = find.descendant(
    of: find.byKey(key),
    matching: find.byType(AnimatedContainer),
  );
  await tester.tap(target.first);
  await tester.pumpRouterIdle();
}

Future<void> _tapNavTab(WidgetTester tester, Key key) async {
  await tester.pumpUntilVisible(find.byKey(key));
  await tester.tap(find.byKey(key));
  await tester.pumpRouterIdle();
}

Future<void> _pumpUntilLocation(
  WidgetTester tester,
  TestAppHarness harness,
  String location,
) async {
  if (harness.currentLocation == location) {
    return;
  }

  for (var i = 0; i < 120; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (harness.currentLocation == location) {
      return;
    }
  }

  throw TestFailure(
    'Timed out waiting for route $location. Current route: ${harness.currentLocation}',
  );
}
