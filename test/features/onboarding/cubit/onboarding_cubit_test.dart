import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/services/app_analytics.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:debt_payoff_manager/features/onboarding/cubit/onboarding_state.dart';
import 'package:debt_payoff_manager/features/onboarding/services/onboarding_analytics.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repo;
  late OnboardingCubit cubit;
  late _RecordingAppAnalytics analytics;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepositoryImpl(db: db);
    analytics = _RecordingAppAnalytics();
    cubit = OnboardingCubit(
      settingsRepository: repo,
      onboardingAnalytics: OnboardingAnalytics(analytics: analytics),
    );
    await cubit.start();
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  group('OnboardingCubit', () {
    test('hydrates persisted onboarding step from settings', () async {
      final settings = await repo.getSettings();
      await repo.updateSettings(
        settings.copyWith(
          onboardingStep: OnboardingStep.extraAmount.storageValue,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.currentStep, OnboardingStep.extraAmount);
      expect(cubit.state.hasCompletedOnboarding, isFalse);
    });

    test('goToStep persists current step and clears completion', () async {
      await cubit.goToStep(OnboardingStep.selectStrategy);
      await Future<void>.delayed(Duration.zero);

      final settings = await repo.getSettings();
      expect(
        settings.onboardingStep,
        OnboardingStep.selectStrategy.storageValue,
      );
      expect(settings.onboardingCompleted, isFalse);
      expect(cubit.state.currentStep, OnboardingStep.selectStrategy);
      expect(
        analytics.events,
        contains(
          isA<_LoggedEvent>()
              .having((event) => event.name, 'name', 'onboarding_step_changed')
              .having(
                (event) => event.parameters['from_step'],
                'from_step',
                'welcome',
              )
              .having(
                (event) => event.parameters['to_step'],
                'to_step',
                'select_strategy',
              ),
        ),
      );
    });

    test('completeOnboarding marks settings as completed', () async {
      await cubit.completeOnboarding();
      await Future<void>.delayed(Duration.zero);

      final settings = await repo.getSettings();
      expect(settings.onboardingStep, OnboardingStep.complete.storageValue);
      expect(settings.onboardingCompleted, isTrue);
      expect(settings.onboardingCompletedAt, isNotNull);
      expect(cubit.state.hasCompletedOnboarding, isTrue);
      expect(
        analytics.events.any((event) => event.name == 'onboarding_completed'),
        isTrue,
      );
    });

    test(
      'start logs onboarding_resumed when persisted step is mid-flow',
      () async {
        final settings = await repo.getSettings();
        await repo.updateSettings(
          settings.copyWith(
            onboardingStep: OnboardingStep.extraAmount.storageValue,
          ),
        );

        await cubit.close();
        analytics = _RecordingAppAnalytics();
        cubit = OnboardingCubit(
          settingsRepository: repo,
          onboardingAnalytics: OnboardingAnalytics(analytics: analytics),
        );
        await cubit.start();
        await Future<void>.delayed(Duration.zero);

        expect(
          analytics.events,
          contains(
            isA<_LoggedEvent>()
                .having((event) => event.name, 'name', 'onboarding_resumed')
                .having(
                  (event) => event.parameters['step'],
                  'step',
                  'extra_amount',
                ),
          ),
        );
      },
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
