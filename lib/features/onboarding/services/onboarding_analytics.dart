import '../../../core/services/app_analytics.dart';
import '../../../domain/enums/strategy.dart';
import '../cubit/onboarding_state.dart';

enum OnboardingAnalyticsScreen {
  welcome('welcome'),
  debtEntry('debt_entry'),
  addAnother('add_another'),
  strategySelection('strategy_selection'),
  extraAmount('extra_amount'),
  ahaMoment('aha_moment');

  const OnboardingAnalyticsScreen(this.eventValue);

  final String eventValue;
}

class OnboardingAnalytics {
  const OnboardingAnalytics({required AppAnalytics analytics})
    : _analytics = analytics;

  final AppAnalytics _analytics;

  Future<void> trackResumed(OnboardingStep step) {
    return _track('onboarding_resumed', {'step': _persistedStepName(step)});
  }

  Future<void> trackStepViewed(OnboardingAnalyticsScreen screen) {
    return _track('onboarding_step_viewed', {'step': screen.eventValue});
  }

  Future<void> trackStepChanged({
    required OnboardingStep from,
    required OnboardingStep to,
  }) {
    if (from == to) {
      return Future<void>.value();
    }

    return _track('onboarding_step_changed', {
      'from_step': _persistedStepName(from),
      'to_step': _persistedStepName(to),
      'direction': from.storageValue < to.storageValue ? 'forward' : 'back',
    });
  }

  Future<void> trackDebtSaved({required int debtCount}) {
    return _track('onboarding_debt_saved', {'debt_count': debtCount});
  }

  Future<void> trackStrategySelected(Strategy strategy) {
    return _track('onboarding_strategy_selected', {'strategy': strategy.name});
  }

  Future<void> trackExtraConfirmed({required int extraAmountCents}) {
    return _track('onboarding_extra_confirmed', {
      'extra_bucket': _extraAmountBucket(extraAmountCents),
    });
  }

  Future<void> trackCompleted() {
    return _track('onboarding_completed');
  }

  Future<void> _track(
    String name, [
    Map<String, Object?> parameters = const <String, Object?>{},
  ]) {
    return _analytics.logEvent(name, parameters: parameters);
  }

  String _persistedStepName(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return 'welcome';
      case OnboardingStep.addDebt:
        return 'add_debt';
      case OnboardingStep.selectStrategy:
        return 'select_strategy';
      case OnboardingStep.extraAmount:
        return 'extra_amount';
      case OnboardingStep.complete:
        return 'complete';
    }
  }

  String _extraAmountBucket(int extraAmountCents) {
    final dollars = extraAmountCents ~/ 100;
    if (dollars <= 0) return 'zero';
    if (dollars <= 50) return '1_50';
    if (dollars <= 100) return '51_100';
    if (dollars <= 250) return '101_250';
    if (dollars <= 500) return '251_500';
    return '500_plus';
  }
}
