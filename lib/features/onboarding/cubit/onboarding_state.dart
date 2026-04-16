import 'package:equatable/equatable.dart';

/// State for onboarding flow.
enum OnboardingStep { welcome, addDebt, selectStrategy, extraAmount, complete }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.hasCompletedOnboarding = false,
  });

  final OnboardingStep currentStep;
  final bool hasCompletedOnboarding;

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  @override
  List<Object?> get props => [currentStep, hasCompletedOnboarding];
}
