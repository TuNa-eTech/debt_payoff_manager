import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/router/app_router.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';

import '../data/repositories/repository_test_helpers.dart';
import '../helpers/test_app_harness.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('Phase 8 New Charge Flow', () {
    testWidgets('can add a new charge to increase balance', (tester) async {
      final harness = await TestAppHarness.create();
      addTearDown(() => tester.view.resetViewInsets());
      addTearDown(() => harness.disposeWidgetTest(tester));

      // Seed a credit card debt
      await harness.debtRepository.addDebt(
        makeRepoDebt(
          id: 'charge-visa',
          name: 'Charge Visa',
          type: DebtType.creditCard,
          currentBalance: 120000, // $1,200.00
          originalPrincipal: 150000,
          minimumPayment: 4000,
          dueDayOfMonth: 15,
          firstDueDate: DateTime(2026, 1, 15),
        ),
      );
      await harness.onboardingCubit.completeOnboarding();

      await harness.pumpApp(tester);
      await _pumpUntilLocation(tester, harness, AppRoutes.home);

      // Navigate to debt detail
      harness.router.go(AppRoutes.debtDetailPath('charge-visa'));
      await _pumpUntilLocation(
        tester,
        harness,
        AppRoutes.debtDetailPath('charge-visa'),
      );

      // Find the add charge button
      final addChargeButton = find.byKey(AppTestKeys.debtDetailAddCharge);
      await tester.ensureVisible(addChargeButton);
      await tester.tap(addChargeButton);

      // Wait for bottom sheet animation to complete
      await tester.pumpAndSettle();

      // Enter amount and note
      await _enterText(tester, AppTestKeys.addChargeAmount, '50'); // $50.00
      await _enterText(tester, AppTestKeys.addChargeNote, 'Amazon purchase');
      await tester.pumpAndSettle();

      // Submit
      final submitFinder = find.byKey(AppTestKeys.addChargeSubmit);
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);

      // Wait for sheet to close and return to detail page
      await tester.pumpAndSettle();

      await _waitForPaymentCount(
        tester,
        harness,
        debtId: 'charge-visa',
        expectedCount: 1,
      );

      // Verify the payment record was added
      final payments = await harness.paymentRepository.getPaymentsForDebt(
        'charge-visa',
      );
      expect(payments, hasLength(1));
      expect(payments.single.type, PaymentType.charge);
      expect(payments.single.amount, 5000); // $50.00 in cents
      expect(payments.single.note, 'Amazon purchase');

      // Verify debt balance increased
      final updatedDebt = await harness.debtRepository.getDebtById(
        'charge-visa',
      );
      expect(updatedDebt, isNotNull);
      expect(updatedDebt!.currentBalance, 125000); // 120000 + 5000

      // Navigate to payment history to verify it appears
      harness.router.go(AppRoutes.paymentHistoryPath('charge-visa'));
      await _pumpUntilLocation(
        tester,
        harness,
        AppRoutes.paymentHistoryPath('charge-visa'),
      );

      final yearMonth = _yearMonthKey(DateTime.now());
      await tester.pumpUntilVisible(
        find.byKey(AppTestKeys.paymentHistoryMonthChip(yearMonth)),
      );
      
      // Should show 'Charge' and the note
      expect(find.text('Charge'), findsOneWidget);
      expect(find.text('Amazon purchase'), findsOneWidget);
      // The amount is negative in display or shows as a charge. We check for the value.
      expect(find.textContaining('50.00'), findsWidgets);
    });
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
