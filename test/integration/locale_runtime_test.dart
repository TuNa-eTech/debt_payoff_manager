import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/i18n/app_locale.dart';
import 'package:debt_payoff_manager/core/router/app_router.dart';

import '../helpers/test_app_harness.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('Locale runtime', () {
    testWidgets('fresh welcome surface renders with Vietnamese locale', (
      tester,
    ) async {
      final harness = await TestAppHarness.create(
        seedLocaleCode: AppLocale.vietnameseLocaleCode,
      );
      addTearDown(() => harness.disposeWidgetTest(tester));

      await harness.pumpApp(tester);
      await _pumpUntilLocation(tester, harness, AppRoutes.welcome);

      expect(find.byKey(AppTestKeys.welcomeChangeLanguage), findsOneWidget);
      expect(find.text('Kiểm soát nợ,\ngiải phóng tương lai.'), findsOneWidget);
      expect(find.text('Thêm khoản nợ đầu tiên'), findsOneWidget);
      expect(find.text('Không sync bank'), findsOneWidget);
    });

    testWidgets(
      'welcome locale action switches onboarding copy before debt entry',
      (tester) async {
        final harness = await TestAppHarness.create(
          seedLocaleCode: AppLocale.englishLocaleCode,
        );
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.welcome);

        expect(_materialApp(tester).locale?.languageCode, 'en');
        expect(find.text('Change language'), findsOneWidget);

        await tester.tap(find.byKey(AppTestKeys.welcomeChangeLanguage));
        await tester.pumpRouterIdle();
        await tester.pumpUntilVisible(
          find.byKey(AppTestKeys.settingsLocaleOptionVietnamese),
        );

        await tester.tap(
          find.byKey(AppTestKeys.settingsLocaleOptionVietnamese),
        );
        await tester.pumpRouterIdle();
        await tester.pumpUntilVisible(find.text('Đổi ngôn ngữ'));

        expect(_materialApp(tester).locale?.languageCode, 'vi');
        expect(
          find.text('Kiểm soát nợ,\ngiải phóng tương lai.'),
          findsOneWidget,
        );
        expect(find.text('Thêm khoản nợ đầu tiên'), findsOneWidget);
        expect(
          (await harness.settingsRepository.getSettings()).localeCode,
          AppLocale.vietnameseLocaleCode,
        );
      },
    );

    testWidgets('settings locale picker updates shell labels immediately', (
      tester,
    ) async {
      final harness = await TestAppHarness.create(
        seedLocaleCode: AppLocale.englishLocaleCode,
      );
      addTearDown(() => harness.disposeWidgetTest(tester));

      await harness.onboardingCubit.completeOnboarding();
      await harness.pumpApp(tester);
      await _pumpUntilLocation(tester, harness, AppRoutes.home);

      expect(_materialApp(tester).locale?.languageCode, 'en');
      expect(find.text('Overview'), findsWidgets);

      harness.router.go(AppRoutes.settings);
      await _pumpUntilLocation(tester, harness, AppRoutes.settings);
      final localeTile = find.byKey(AppTestKeys.settingsLocale);
      await tester.scrollUntilVisible(
        localeTile,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(localeTile);

      await tester.tap(localeTile);
      await tester.pumpRouterIdle();
      await tester.pumpUntilVisible(
        find.byKey(AppTestKeys.settingsLocaleOptionVietnamese),
      );

      await tester.tap(find.byKey(AppTestKeys.settingsLocaleOptionVietnamese));
      await tester.pumpRouterIdle();
      await tester.pumpUntilVisible(find.text('Cài đặt'));

      expect(_materialApp(tester).locale?.languageCode, 'vi');
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Tổng quan'), findsWidgets);
      expect(find.text('Khoản nợ'), findsOneWidget);
      expect(
        (await harness.settingsRepository.getSettings()).localeCode,
        AppLocale.vietnameseLocaleCode,
      );
    });
  });
}

MaterialApp _materialApp(WidgetTester tester) {
  return tester.widget<MaterialApp>(find.byType(MaterialApp));
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
