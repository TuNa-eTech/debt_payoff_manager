import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/i18n/app_locale.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/milestone.dart';
import 'domain/entities/user_settings.dart';
import 'domain/repositories/debt_repository.dart';
import 'domain/repositories/milestone_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'features/debts/cubit/debts_cubit.dart';
import 'features/onboarding/cubit/onboarding_cubit.dart';
import 'features/onboarding/services/onboarding_analytics.dart';
import 'features/progress/presentation/widgets/milestone_celebration_overlay.dart';
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
  late final MilestoneRepository _milestoneRepository =
      getIt<MilestoneRepository>();
  late final DebtsCubit _debtsCubit = getIt<DebtsCubit>()..start();
  late final OnboardingCubit _onboardingCubit = OnboardingCubit(
    settingsRepository: _settingsRepository,
    onboardingAnalytics: getIt<OnboardingAnalytics>(),
  )..start();
  late final router = createRouter(
    settingsRepository: _settingsRepository,
    debtRepository: _debtRepository,
  );

  StreamSubscription<List<Milestone>>? _milestoneSub;
  OverlayEntry? _celebrationEntry;
  final Set<String> _shownMilestoneIds = {};

  @override
  void initState() {
    super.initState();
    _milestoneSub = _milestoneRepository.watchUnseenMilestones().listen(
      _onUnseenMilestones,
    );
  }

  void _onUnseenMilestones(List<Milestone> milestones) {
    if (!mounted || _celebrationEntry != null) return;
    final next = milestones
        .where((m) => !_shownMilestoneIds.contains(m.id))
        .firstOrNull;
    if (next == null) return;
    _shownMilestoneIds.add(next.id);
    _showCelebration(next);
  }

  void _showCelebration(Milestone milestone) {
    final overlayState = router.routerDelegate.navigatorKey.currentState
        ?.overlay;
    if (overlayState == null) return;
    _celebrationEntry = OverlayEntry(
      builder: (_) => MilestoneCelebrationOverlay(
        milestone: milestone,
        onDismiss: () => _dismissCelebration(milestone.id),
      ),
    );
    overlayState.insert(_celebrationEntry!);
  }

  Future<void> _dismissCelebration(String milestoneId) async {
    _celebrationEntry?.remove();
    _celebrationEntry = null;
    await _milestoneRepository.markSeen(milestoneId);
  }

  @override
  void dispose() {
    _milestoneSub?.cancel();
    _celebrationEntry?.remove();
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
