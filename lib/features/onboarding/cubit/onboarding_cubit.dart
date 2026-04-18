import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/settings_repository.dart';
import 'onboarding_state.dart';

/// Cubit managing onboarding flow state.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const OnboardingState());

  final SettingsRepository _settingsRepository;
  StreamSubscription? _settingsSubscription;

  Future<void> start() async {
    await _settingsSubscription?.cancel();
    _settingsSubscription = _settingsRepository.watchSettings().listen(
      (settings) {
        emit(
          state.copyWith(
            isLoading: false,
            currentStep: OnboardingStep.fromStorage(settings.onboardingStep),
            hasCompletedOnboarding: settings.onboardingCompleted,
          ),
        );
      },
    );
  }

  Future<void> goToStep(OnboardingStep step) async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.updateSettings(
      settings.copyWith(
        onboardingStep: step.storageValue,
        onboardingCompleted: false,
        onboardingCompletedAt: null,
      ),
    );
  }

  Future<void> nextStep() async {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(state.currentStep);
    if (currentIndex < steps.length - 1) {
      await goToStep(steps[currentIndex + 1]);
    }
  }

  Future<void> previousStep() async {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(state.currentStep);
    if (currentIndex > 0) {
      await goToStep(steps[currentIndex - 1]);
    }
  }

  Future<void> completeOnboarding() async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.updateSettings(
      settings.copyWith(
        onboardingStep: OnboardingStep.complete.storageValue,
        onboardingCompleted: true,
        onboardingCompletedAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _settingsSubscription?.cancel();
    return super.close();
  }
}
