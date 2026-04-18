import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../features/debts/presentation/pages/add_debt_page.dart';
import '../../features/debts/presentation/pages/debt_detail_page.dart';
import '../../features/debts/presentation/pages/debts_list_page.dart';
import '../../features/debts/presentation/pages/edit_debt_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/add_another_debt_page.dart';
import '../../features/onboarding/presentation/pages/aha_moment_page.dart';
import '../../features/onboarding/presentation/pages/debt_entry_page.dart';
import '../../features/onboarding/presentation/pages/extra_amount_page.dart';
import '../../features/onboarding/presentation/pages/strategy_selection_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/debts/presentation/pages/log_payment_page.dart';
import '../../features/debts/presentation/pages/payment_history_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/sync_backup_page.dart';
import '../../features/plan/presentation/pages/timeline_page.dart';
import '../widgets/scaffold_with_nav.dart';

/// Route paths as constants to avoid typos.
class AppRoutes {
  AppRoutes._();

  // Onboarding
  static const String welcome = '/welcome';
  static const String debtEntry = '/welcome/debt_entry';
  static const String addAnotherDebt = '/welcome/add_another';
  static const String strategySelection = '/welcome/strategy';
  static const String extraAmount = '/welcome/extra_amount';
  static const String ahaMoment = '/welcome/aha';

  // Main tabs (matches ScaffoldWithNav 5 items)
  static const String home = '/home';
  static const String debts = '/debts';
  static const String plan = '/plan';
  static const String progress = '/progress';
  static const String settings = '/settings';

  // Sub-pages
  static const String addDebt = '/debts/add';
  static const String debtDetail = '/debts/:id';
  static const String editDebt = '/debts/:id/edit';
  static const String logPayment = '/debts/:id/log_payment';
  static const String paymentHistory = '/debts/:id/history';
  static const String syncBackup = '/settings/sync';

  static String debtDetailPath(String id) => '/debts/$id';
  static String editDebtPath(String id) => '/debts/$id/edit';
  static String logPaymentPath(String id) => '/debts/$id/log_payment';
  static String paymentHistoryPath(String id) => '/debts/$id/history';
}

/// GoRouter configuration.
GoRouter createRouter({
  required SettingsRepository settingsRepository,
  required DebtRepository debtRepository,
}) {
  final refreshNotifier = _StreamRefreshNotifier(
    settingsRepository.watchSettings(),
  );

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      debugPrint('🧭 [Router] → ${state.matchedLocation}');
      final settings = await settingsRepository.getSettings();
      final isOnboardingRoute =
          state.matchedLocation == AppRoutes.welcome ||
          state.matchedLocation.startsWith('${AppRoutes.welcome}/');

      if (settings.onboardingCompleted) {
        if (isOnboardingRoute) {
          return AppRoutes.home;
        }
        return null;
      }

      final target = await _resolvePendingOnboardingRoute(
        settingsRepository: settingsRepository,
        debtRepository: debtRepository,
      );

      if (!isOnboardingRoute) {
        return target;
      }

      if (state.matchedLocation == AppRoutes.welcome) {
        return target;
      }

      return null;
    },
    routes: [
      // ── Onboarding ──
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
        routes: [
          GoRoute(
            path: 'debt_entry',
            builder: (context, state) => const DebtEntryPage(),
          ),
          GoRoute(
            path: 'add_another',
            builder: (context, state) => const AddAnotherDebtPage(),
          ),
          GoRoute(
            path: 'strategy',
            builder: (context, state) => const StrategySelectionPage(),
          ),
          GoRoute(
            path: 'extra_amount',
            builder: (context, state) => const ExtraAmountPage(),
          ),
          GoRoute(
            path: 'aha',
            builder: (context, state) => const AhaMomentPage(),
          ),
        ],
      ),

      // ── Main shell with bottom nav ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        branches: [
          // 1. Tổng quan (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // 2. Khoản nợ (Debts)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.debts,
                builder: (context, state) => const DebtsListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddDebtPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      return DebtDetailPage(
                        id: state.pathParameters['id']!,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => EditDebtPage(
                          id: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'log_payment',
                        builder: (context, state) =>
                            LogPaymentPage(id: state.pathParameters['id']!),
                      ),
                      GoRoute(
                        path: 'history',
                        builder: (context, state) => PaymentHistoryPage(
                          id: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 3. Kế hoạch (Plan / Timeline)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.plan,
                builder: (context, state) => const TimelinePage(),
              ),
            ],
          ),
          // 4. Tiến độ (Progress)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressPage(),
              ),
            ],
          ),
          // 5. Cài đặt (Settings)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'sync',
                    builder: (context, state) => const SyncBackupPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future<String> _resolvePendingOnboardingRoute({
  required SettingsRepository settingsRepository,
  required DebtRepository debtRepository,
}) async {
  final settings = await settingsRepository.getSettings();
  switch (settings.onboardingStep) {
    case 2:
      final debts = await debtRepository.getAllDebts();
      return debts.isEmpty ? AppRoutes.debtEntry : AppRoutes.addAnotherDebt;
    case 3:
      return AppRoutes.strategySelection;
    case 4:
      return AppRoutes.extraAmount;
    case 5:
      return settings.onboardingCompleted
          ? AppRoutes.home
          : AppRoutes.ahaMoment;
    case 0:
    case 1:
    default:
      return AppRoutes.welcome;
  }
}

class _StreamRefreshNotifier extends ChangeNotifier {
  _StreamRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
