import 'package:go_router/go_router.dart';

import '../../features/debts/presentation/pages/debts_list_page.dart';
import '../../features/debts/presentation/pages/add_debt_page.dart';
import '../../features/debts/presentation/pages/debt_detail_page.dart';
import '../../features/monthly_action/presentation/pages/monthly_action_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/payments/presentation/pages/log_payment_page.dart';
import '../../features/payments/presentation/pages/payment_history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/strategy/presentation/pages/strategy_page.dart';
import '../../features/timeline/presentation/pages/timeline_page.dart';
import '../widgets/scaffold_with_nav.dart';

/// Route paths as constants to avoid typos.
class AppRoutes {
  AppRoutes._();

  // Onboarding
  static const String welcome = '/welcome';

  // Main tabs
  static const String monthlyAction = '/monthly';
  static const String debts = '/debts';
  static const String timeline = '/timeline';
  static const String settings = '/settings';

  // Sub-pages
  static const String addDebt = '/debts/add';
  static const String debtDetail = '/debts/:id';
  static const String strategy = '/strategy';
  static const String logPayment = '/payments/log';
  static const String paymentHistory = '/payments/history';
}

/// GoRouter configuration.
///
/// TODO: Add redirect logic based on onboarding completion state.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    routes: [
      // ── Onboarding ──
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),

      // ── Main shell with bottom nav ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.monthlyAction,
                builder: (context, state) => const MonthlyActionPage(),
              ),
            ],
          ),
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
                      final id = state.pathParameters['id']!;
                      return DebtDetailPage(debtId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.timeline,
                builder: (context, state) => const TimelinePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // ── Standalone pages ──
      GoRoute(
        path: AppRoutes.strategy,
        builder: (context, state) => const StrategyPage(),
      ),
      GoRoute(
        path: AppRoutes.logPayment,
        builder: (context, state) => const LogPaymentPage(),
      ),
      GoRoute(
        path: AppRoutes.paymentHistory,
        builder: (context, state) => const PaymentHistoryPage(),
      ),
    ],
  );
}
