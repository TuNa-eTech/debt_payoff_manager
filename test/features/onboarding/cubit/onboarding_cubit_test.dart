import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:debt_payoff_manager/features/onboarding/cubit/onboarding_state.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repo;
  late OnboardingCubit cubit;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepositoryImpl(db: db);
    cubit = OnboardingCubit(settingsRepository: repo);
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
      expect(settings.onboardingStep, OnboardingStep.selectStrategy.storageValue);
      expect(settings.onboardingCompleted, isFalse);
      expect(cubit.state.currentStep, OnboardingStep.selectStrategy);
    });

    test('completeOnboarding marks settings as completed', () async {
      await cubit.completeOnboarding();
      await Future<void>.delayed(Duration.zero);

      final settings = await repo.getSettings();
      expect(settings.onboardingStep, OnboardingStep.complete.storageValue);
      expect(settings.onboardingCompleted, isTrue);
      expect(settings.onboardingCompletedAt, isNotNull);
      expect(cubit.state.hasCompletedOnboarding, isTrue);
    });
  });
}
