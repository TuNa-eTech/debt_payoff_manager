import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

Future<void> navigateToOnboardingStep(
  BuildContext context, {
  required OnboardingStep step,
  required String route,
}) async {
  await context.read<OnboardingCubit>().goToStep(step);
  if (!context.mounted) return;
  context.go(route);
}
