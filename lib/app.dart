import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/cubit/onboarding_cubit.dart';

/// Root application widget.
///
/// Provides global BLoC/Cubit instances and configures
/// theme, routing, and top-level state.
class DebtPayoffApp extends StatelessWidget {
  const DebtPayoffApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OnboardingCubit()),
        // TODO: Add more global cubits as needed:
        // BlocProvider(create: (_) => getIt<DebtsCubit>()..loadDebts()),
        // BlocProvider(create: (_) => getIt<TimelineCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Debt Payoff Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}
