import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/di/injection.dart';
import '../../services/onboarding_analytics.dart';

class OnboardingStepTracker extends StatefulWidget {
  const OnboardingStepTracker({
    required this.screen,
    required this.child,
    super.key,
  });

  final OnboardingAnalyticsScreen screen;
  final Widget child;

  @override
  State<OnboardingStepTracker> createState() => _OnboardingStepTrackerState();
}

class _OnboardingStepTrackerState extends State<OnboardingStepTracker> {
  bool _hasTracked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasTracked) {
        return;
      }
      if (!getIt.isRegistered<OnboardingAnalytics>()) {
        return;
      }
      _hasTracked = true;
      unawaited(getIt<OnboardingAnalytics>().trackStepViewed(widget.screen));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
