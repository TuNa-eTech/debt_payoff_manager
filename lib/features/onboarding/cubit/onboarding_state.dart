import 'package:equatable/equatable.dart';

/// State for onboarding flow.
enum OnboardingStep {
  welcome(1),
  addDebt(2),
  selectStrategy(3),
  extraAmount(4),
  complete(5);

  const OnboardingStep(this.storageValue);

  final int storageValue;

  static OnboardingStep fromStorage(int value) {
    switch (value) {
      case 2:
        return OnboardingStep.addDebt;
      case 3:
        return OnboardingStep.selectStrategy;
      case 4:
        return OnboardingStep.extraAmount;
      case 5:
        return OnboardingStep.complete;
      case 0:
      case 1:
      default:
        return OnboardingStep.welcome;
    }
  }
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.isLoading = true,
    this.currentStep = OnboardingStep.welcome,
    this.hasCompletedOnboarding = false,
  });

  final bool isLoading;
  final OnboardingStep currentStep;
  final bool hasCompletedOnboarding;

  OnboardingState copyWith({
    bool? isLoading,
    OnboardingStep? currentStep,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        currentStep,
        hasCompletedOnboarding,
      ];
}
