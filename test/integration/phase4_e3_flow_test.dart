import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/router/app_router.dart';
import 'package:debt_payoff_manager/core/widgets/app_button.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';

import '../data/repositories/repository_test_helpers.dart';
import '../helpers/test_app_harness.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('Phase 4 E3 integration', () {
    testWidgets('monthly action empty state opens add debt', (tester) async {
      final harness = await TestAppHarness.create();
      addTearDown(() => harness.disposeWidgetTest(tester));

      await harness.onboardingCubit.completeOnboarding();

      await harness.pumpApp(tester);
      await _pumpUntilLocation(tester, harness, AppRoutes.home);
      await tester.pumpUntilVisible(
        find.byKey(AppTestKeys.monthlyActionEmptyAddDebt),
      );

      final addDebtButton = tester.widget<FilledButton>(
        find.descendant(
          of: find.byKey(AppTestKeys.monthlyActionEmptyAddDebt),
          matching: find.widgetWithText(FilledButton, 'Add debt'),
        ),
      );
      expect(addDebtButton.onPressed, isNotNull);
      addDebtButton.onPressed!.call();

      await _pumpUntilLocation(tester, harness, AppRoutes.addDebt);
    });

    testWidgets(
      'monthly action check-off, manual payment logging, history, and timeline stay in sync',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.debtRepository.addDebt(
          makeRepoDebt(
            id: 'phase4-visa',
            name: 'Phase 4 Visa',
            currentBalance: 120000,
            originalPrincipal: 120000,
            minimumPayment: 4000,
            dueDayOfMonth: 15,
            firstDueDate: DateTime(2026, 1, 15),
          ),
        );
        final seededPlan = await harness.planRepository.getCurrentPlan();
        await harness.planRepository.savePlan(
          seededPlan!.copyWith(
            strategy: seededPlan.strategy,
            extraMonthlyAmount: 10000,
          ),
        );
        final recast = await harness.planRecastService.recast(
          referenceDate: DateTime(2026, 4, 18),
        );
        await harness.onboardingCubit.completeOnboarding();

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);

        final yearMonth = _yearMonthKey(DateTime.now());
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.monthlyActionSection('phase4-visa')),
        );
        expect(find.text('Phase 4 Visa'), findsWidgets);

        final baseCheckOffFinder = find.ancestor(
          of: find.descendant(
            of: find.byKey(AppTestKeys.monthlyActionSection('phase4-visa')),
            matching: find.byIcon(LucideIcons.check),
          ),
          matching: find.byType(InkWell),
        );
        await tester.pumpUntilVisible(baseCheckOffFinder);
        final checkOffFinder = baseCheckOffFinder.first;
        final inkWell = tester.widget<InkWell>(checkOffFinder);
        expect(inkWell.onTap, isNotNull);
        inkWell.onTap!.call();
        await tester.pumpRouterIdle();
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.monthlyActionConfirmPrimary),
        );
        final confirmButton = tester.widget<FilledButton>(
          find.descendant(
            of: find.byKey(AppTestKeys.monthlyActionConfirmPrimary),
            matching: find.byType(FilledButton),
          ),
        );
        expect(confirmButton.onPressed, isNotNull);
        confirmButton.onPressed!.call();
        await tester.pumpRouterIdle();
        await _waitForPaymentCount(
          tester,
          harness,
          debtId: 'phase4-visa',
          expectedCount: 1,
        );

        final paymentsAfterCheckOff = await harness.paymentRepository
            .getPaymentsForDebt('phase4-visa');
        expect(paymentsAfterCheckOff, hasLength(1));
        expect(paymentsAfterCheckOff.single.source, PaymentSource.checkOff);
        expect(paymentsAfterCheckOff.single.type, PaymentType.minimum);

        harness.router.go(AppRoutes.debtDetailPath('phase4-visa'));
        await _pumpUntilLocation(
          tester,
          harness,
          AppRoutes.debtDetailPath('phase4-visa'),
        );

        final logPaymentButton = tester.widget<AppButton>(
          find.byKey(AppTestKeys.debtDetailLogPayment),
        );
        expect(logPaymentButton.onPressed, isNotNull);
        logPaymentButton.onPressed!.call();
        await tester.pumpUntilVisible(find.byKey(AppTestKeys.paymentLogAmount));

        await _enterText(tester, AppTestKeys.paymentLogAmount, '50');
        await tester.tap(find.byKey(AppTestKeys.paymentTypeExtra));
        await tester.pumpRouterIdle();
        final submitFinder = find.descendant(
          of: find.byKey(AppTestKeys.paymentLogSubmit),
          matching: find.byType(FilledButton),
        );
        await tester.pumpUntilVisible(submitFinder);
        final submitButton = tester.widget<FilledButton>(submitFinder);
        expect(submitButton.onPressed, isNotNull);
        submitButton.onPressed!.call();
        await _pumpUntilLocation(
          tester,
          harness,
          AppRoutes.debtDetailPath('phase4-visa'),
        );
        await _waitForPaymentCount(
          tester,
          harness,
          debtId: 'phase4-visa',
          expectedCount: 2,
        );

        final paymentsAfterManualLog = await harness.paymentRepository
            .getPaymentsForDebt('phase4-visa');
        final storedDebt = await harness.debtRepository.getDebtById(
          'phase4-visa',
        );
        final storedPlan = await harness.planRepository.getCurrentPlan();
        final cachedProjection = await harness.timelineCacheStore.getProjection(
          recast!.plan.id,
        );

        expect(paymentsAfterManualLog, hasLength(2));
        expect(
          paymentsAfterManualLog.any(
            (payment) =>
                payment.type == PaymentType.extra &&
                payment.source == PaymentSource.manual,
          ),
          isTrue,
        );
        expect(storedDebt!.currentBalance, 111000);
        expect(storedPlan!.projectedDebtFreeDate, isNotNull);
        expect(cachedProjection, isNotNull);
        expect(cachedProjection!.months, isNotEmpty);

        harness.router.go(AppRoutes.paymentHistoryPath('phase4-visa'));
        await _pumpUntilLocation(
          tester,
          harness,
          AppRoutes.paymentHistoryPath('phase4-visa'),
        );

        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.paymentHistoryMonthChip(yearMonth)),
        );
        expect(find.text('Minimum'), findsOneWidget);
        expect(find.text('Extra'), findsOneWidget);
        expect(find.text('Check Off'), findsOneWidget);
        expect(find.text('Manual'), findsOneWidget);

        harness.router.go(AppRoutes.plan);
        await _pumpUntilLocation(tester, harness, AppRoutes.plan);
        await tester.pumpRouterIdle();
        expect(find.text('Plan'), findsWidgets);
      },
    );

    testWidgets(
      'single-debt completed month shows proof dashboard and collapsed checklist',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.debtRepository.addDebt(
          makeRepoDebt(
            id: 'done-visa',
            name: 'Done Visa',
            currentBalance: 120000,
            originalPrincipal: 120000,
            minimumPayment: 4000,
            dueDayOfMonth: 15,
            firstDueDate: DateTime(2026, 1, 15),
          ),
        );
        final seededPlan = await harness.planRepository.getCurrentPlan();
        await harness.planRepository.savePlan(
          seededPlan!.copyWith(extraMonthlyAmount: 0),
        );
        await harness.onboardingCubit.completeOnboarding();

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.monthlyActionSection('done-visa')),
        );

        final baseCheckOffFinder = find.ancestor(
          of: find.descendant(
            of: find.byKey(AppTestKeys.monthlyActionSection('done-visa')),
            matching: find.byIcon(LucideIcons.check),
          ),
          matching: find.byType(InkWell),
        );
        await tester.pumpUntilVisible(baseCheckOffFinder);
        final checkOffFinder = baseCheckOffFinder.first;
        final inkWell = tester.widget<InkWell>(checkOffFinder);
        expect(inkWell.onTap, isNotNull);
        inkWell.onTap!.call();
        await tester.pumpRouterIdle();
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.monthlyActionConfirmPrimary),
        );
        final confirmButton = tester.widget<FilledButton>(
          find.descendant(
            of: find.byKey(AppTestKeys.monthlyActionConfirmPrimary),
            matching: find.byType(FilledButton),
          ),
        );
        confirmButton.onPressed!.call();
        await tester.pumpRouterIdle();
        await _waitForPaymentCount(
          tester,
          harness,
          debtId: 'done-visa',
          expectedCount: 1,
        );

        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.monthlyActionDoneDashboard),
        );
        expect(find.text('This month is done'), findsOneWidget);
        expect(find.text('View history'), findsOneWidget);
        expect(find.text('Log another'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpRouterIdle();
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.monthlyActionCompletedChecklistToggle),
        );
        expect(
          find.byKey(AppTestKeys.monthlyActionCompletedChecklistToggle),
          findsOneWidget,
        );
        expect(
          find.byKey(AppTestKeys.monthlyActionSection('done-visa')),
          findsNothing,
        );

        await tester.tap(
          find.byKey(AppTestKeys.monthlyActionCompletedChecklistToggle),
        );
        await tester.pumpRouterIdle();

        expect(
          find.byKey(AppTestKeys.monthlyActionSection('done-visa')),
          findsOneWidget,
        );
        expect(find.textContaining('Logged'), findsWidgets);
      },
    );

    testWidgets(
      'single paid-off debt shows payoff-specific copy and progress CTA',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.debtRepository.addDebt(
          makeRepoDebt(
            id: 'paid-off-visa',
            name: 'Paid Off Visa',
            currentBalance: 0,
            originalPrincipal: 120000,
            minimumPayment: 4000,
            dueDayOfMonth: 15,
            firstDueDate: DateTime(2026, 1, 15),
            status: DebtStatus.paidOff,
          ),
        );
        await harness.onboardingCubit.completeOnboarding();

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.monthlyActionSingleDebtCard),
        );

        expect(find.text('This debt is paid off'), findsOneWidget);
        expect(find.text('View progress'), findsOneWidget);
        expect(find.text('Add another debt'), findsOneWidget);
      },
    );

    testWidgets(
      'log payment hides bottom submit action while keyboard is visible',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => tester.view.resetViewInsets());
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.debtRepository.addDebt(
          makeRepoDebt(
            id: 'keyboard-visa',
            name: 'Keyboard Visa',
            currentBalance: 120000,
            originalPrincipal: 120000,
            minimumPayment: 4000,
            dueDayOfMonth: 15,
            firstDueDate: DateTime(2026, 1, 15),
          ),
        );
        await harness.onboardingCubit.completeOnboarding();

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);

        harness.router.go(AppRoutes.logPaymentPath('keyboard-visa'));
        await _pumpUntilLocation(
          tester,
          harness,
          AppRoutes.logPaymentPath('keyboard-visa'),
        );
        await tester.pumpUntilVisible(find.byKey(AppTestKeys.paymentLogAmount));
        expect(find.byKey(AppTestKeys.paymentLogSubmit), findsOneWidget);

        await tester.tap(find.byKey(AppTestKeys.paymentLogAmount));
        await tester.pumpRouterIdle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byKey(AppTestKeys.paymentLogSubmit), findsNothing);

        tester.view.resetViewInsets();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byKey(AppTestKeys.paymentLogSubmit), findsOneWidget);
      },
    );
  });
}

Future<void> _pumpUntilLocation(
  WidgetTester tester,
  TestAppHarness harness,
  String expectedLocation,
) async {
  for (var i = 0; i < 180; i++) {
    await tester.pumpRouterIdle();
    if (harness.currentLocation == expectedLocation) {
      return;
    }
  }

  throw TestFailure(
    'Timed out waiting for router location $expectedLocation. Current: ${harness.currentLocation}',
  );
}

Future<void> _enterText(WidgetTester tester, Key key, String text) async {
  final finder = find.byKey(key);
  await tester.pumpUntilVisible(finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.enterText(finder, text);
  await tester.pumpRouterIdle();
}

String _yearMonthKey(DateTime value) {
  final local = DateTime(value.year, value.month, value.day);
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}';
}

Future<void> _waitForPaymentCount(
  WidgetTester tester,
  TestAppHarness harness, {
  required String debtId,
  required int expectedCount,
}) async {
  for (var i = 0; i < 60; i++) {
    await tester.pumpRouterIdle();
    final payments = await harness.paymentRepository.getPaymentsForDebt(debtId);
    if (payments.length == expectedCount) {
      return;
    }
  }

  throw TestFailure(
    'Timed out waiting for $expectedCount payments for $debtId.',
  );
}
