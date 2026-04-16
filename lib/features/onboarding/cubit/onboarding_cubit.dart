import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_state.dart';

/// Cubit managing onboarding flow state.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void goToStep(OnboardingStep step) {
    emit(state.copyWith(currentStep: step));
  }

  void nextStep() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(state.currentStep);
    if (currentIndex < steps.length - 1) {
      emit(state.copyWith(currentStep: steps[currentIndex + 1]));
    }
  }

  void previousStep() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(state.currentStep);
    if (currentIndex > 0) {
      emit(state.copyWith(currentStep: steps[currentIndex - 1]));
    }
  }

  void completeOnboarding() {
    emit(state.copyWith(hasCompletedOnboarding: true));
  }
}
