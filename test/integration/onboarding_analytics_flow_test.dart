import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/router/app_router.dart';
import 'package:debt_payoff_manager/core/services/app_analytics.dart';

import '../helpers/test_app_harness.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('records onboarding funnel analytics through the real flow', (
    tester,
  ) async {
    final analytics = _RecordingAppAnalytics();
    final harness = await TestAppHarness.create(appAnalytics: analytics);
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

    await _tapButton(tester, AppTestKeys.onboardingExtraPreset100);
    await tester.pumpRouterIdle();
    await _tapButton(tester, AppTestKeys.onboardingExtraContinue);
    await _pumpUntilLocation(tester, harness, AppRoutes.ahaMoment);

    await _tapButton(tester, AppTestKeys.onboardingComplete);
    await _pumpUntilLocation(tester, harness, AppRoutes.home);

    final stepViews = analytics.events
        .where((event) => event.name == 'onboarding_step_viewed')
        .map((event) => event.parameters['step'])
        .toList();
    expect(
      stepViews,
      containsAllInOrder(<Object?>[
        'welcome',
        'debt_entry',
        'add_another',
        'strategy_selection',
        'extra_amount',
        'aha_moment',
      ]),
    );

    expect(
      analytics.events.any(
        (event) =>
            event.name == 'onboarding_debt_saved' &&
            (event.parameters['debt_count'] as int?) != null,
      ),
      isTrue,
    );
    expect(
      analytics.events.any(
        (event) =>
            event.name == 'onboarding_strategy_selected' &&
            event.parameters['strategy'] == 'snowball',
      ),
      isTrue,
    );
    expect(
      analytics.events.any(
        (event) =>
            event.name == 'onboarding_extra_confirmed' &&
            event.parameters['extra_bucket'] == '51_100',
      ),
      isTrue,
    );
    expect(
      analytics.events.any((event) => event.name == 'onboarding_completed'),
      isTrue,
    );
  });
}

class _RecordingAppAnalytics implements AppAnalytics {
  final List<_LoggedEvent> events = <_LoggedEvent>[];

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    events.add(_LoggedEvent(name: name, parameters: Map.of(parameters)));
  }
}

class _LoggedEvent {
  const _LoggedEvent({required this.name, required this.parameters});

  final String name;
  final Map<String, Object?> parameters;
}

Future<void> _pumpUntilLocation(
  WidgetTester tester,
  TestAppHarness harness,
  String expectedLocation,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pumpRouterIdle();
    if (harness.currentLocation == expectedLocation) {
      return;
    }
  }

  throw TestFailure(
    'Timed out waiting for location $expectedLocation. '
    'Current: ${harness.currentLocation}',
  );
}

Future<void> _tapButton(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await tester.pumpUntilVisible(finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpRouterIdle();
}

Future<void> _enterText(WidgetTester tester, Key key, String value) async {
  final finder = find.byKey(key);
  await tester.pumpUntilVisible(finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
  await tester.enterText(finder, value);
  await tester.pumpRouterIdle();
}
