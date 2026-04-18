import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/debt_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'features/debts/cubit/debts_cubit.dart';
import 'features/onboarding/cubit/onboarding_cubit.dart';

/// Root application widget.
///
/// Provides global BLoC/Cubit instances and configures
/// theme, routing, and top-level state.
class DebtPayoffApp extends StatefulWidget {
  const DebtPayoffApp({super.key});

  @override
  State<DebtPayoffApp> createState() => _DebtPayoffAppState();
}

class _DebtPayoffAppState extends State<DebtPayoffApp> {
  late final SettingsRepository _settingsRepository =
      getIt<SettingsRepository>();
  late final DebtRepository _debtRepository = getIt<DebtRepository>();
  late final DebtsCubit _debtsCubit = getIt<DebtsCubit>()..start();
  late final OnboardingCubit _onboardingCubit = OnboardingCubit(
    settingsRepository: _settingsRepository,
  )..start();
  late final router = createRouter(
    settingsRepository: _settingsRepository,
    debtRepository: _debtRepository,
  );

  @override
  void dispose() {
    _debtsCubit.close();
    _onboardingCubit.close();
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingCubit>.value(value: _onboardingCubit),
        BlocProvider<DebtsCubit>.value(value: _debtsCubit),
      ],
      child: MaterialApp.router(
        title: 'Debt Payoff Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    );
  }
}
