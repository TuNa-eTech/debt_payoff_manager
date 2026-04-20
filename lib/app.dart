import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/i18n/app_locale.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/user_settings.dart';
import 'domain/repositories/debt_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'features/debts/cubit/debts_cubit.dart';
import 'features/onboarding/cubit/onboarding_cubit.dart';
import 'features/onboarding/services/onboarding_analytics.dart';
import 'l10n/app_localizations.dart';

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
    onboardingAnalytics: getIt<OnboardingAnalytics>(),
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
    return StreamBuilder<UserSettings>(
      stream: _settingsRepository.watchSettings(),
      builder: (context, settingsSnapshot) {
        final locale = AppLocale.flutterLocaleForCode(
          settingsSnapshot.data?.localeCode,
        );

        return MultiBlocProvider(
          providers: [
            BlocProvider<OnboardingCubit>.value(value: _onboardingCubit),
            BlocProvider<DebtsCubit>.value(value: _debtsCubit),
          ],
          child: MaterialApp.router(
            locale: locale,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appName ?? 'Debt Payoff X',
            title: 'Debt Payoff X',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        );
      },
    );
  }
}
