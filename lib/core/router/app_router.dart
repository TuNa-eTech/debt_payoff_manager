import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
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
import '../../features/debts/presentation/pages/rate_history_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/progress/presentation/pages/monthly_summary_page.dart';
import '../../features/pricing/presentation/pages/pricing_page.dart';
import '../../features/pricing/domain/entitlement_service.dart';
import '../../features/reports/presentation/pages/reports_preview_page.dart';
import '../../features/scenarios/cubit/scenario_lab_cubit.dart';
import '../../features/scenarios/presentation/pages/compare_scenarios_page.dart';
import '../../features/scenarios/presentation/pages/create_what_if_page.dart';
import '../../features/scenarios/presentation/pages/scenarios_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/sync_backup_page.dart';
import '../../features/sharing/cubit/sharing_cubit.dart';
import '../../features/sharing/presentation/pages/invite_accept_page.dart';
import '../../features/sharing/presentation/pages/partner_sharing_page.dart';
import '../../features/sharing/presentation/pages/shared_plan_page.dart';
import '../../features/plan/cubit/plan_timeline_cubit.dart';
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
  static const String rateHistory = '/debts/:id/rate_history';
  static const String syncBackup = '/settings/sync';
  static const String reportsPreview = '/settings/reports';
  static const String pricing = '/settings/pricing';
  static const String scenarios = '/settings/scenarios';
  static const String createWhatIf = '/settings/scenarios/new';
  static const String compareScenarios = '/settings/scenarios/compare';
  static const String partnerSharing = '/settings/sharing';
  static const String inviteAccept = '/invite';
  static const String sharedPlan = '/shared/:shareId';
  static const String monthlySummary = '/progress/summary';

  static String debtDetailPath(String id) => '/debts/$id';
  static String editDebtPath(String id) => '/debts/$id/edit';
  static String logPaymentPath(String id) => '/debts/$id/log_payment';
  static String paymentHistoryPath(String id) => '/debts/$id/history';
  static String rateHistoryPath(String id) => '/debts/$id/rate_history';
  static String sharedPlanPath(String shareId) => '/shared/$shareId';
}

/// GoRouter configuration.
GoRouter createRouter({
  required SettingsRepository settingsRepository,
  required DebtRepository debtRepository,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final debtsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'debts');
  final planNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'plan');
  final progressNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'progress',
  );
  final settingsNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'settings',
  );
  final refreshNotifier = _StreamRefreshNotifier(
    settingsRepository.watchSettings(),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
        if (_isPremiumRoute(state.matchedLocation) &&
            !getIt<EntitlementService>().isPremiumActive(settings)) {
          return AppRoutes.pricing;
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
            navigatorKey: homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // 2. Khoản nợ (Debts)
          StatefulShellBranch(
            navigatorKey: debtsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.debts,
                builder: (context, state) => const DebtsListPage(),
              ),
            ],
          ),
          // 3. Kế hoạch (Plan / Timeline)
          StatefulShellBranch(
            navigatorKey: planNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.plan,
                builder: (context, state) => const TimelinePage(),
              ),
            ],
          ),
          // 4. Tiến độ (Progress)
          StatefulShellBranch(
            navigatorKey: progressNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressPage(),
                routes: [
                  GoRoute(
                    path: 'summary',
                    builder: (context, state) => const MonthlySummaryPage(),
                  ),
                ],
              ),
            ],
          ),
          // 5. Cài đặt (Settings)
          StatefulShellBranch(
            navigatorKey: settingsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'reports',
                    builder: (context, state) => BlocProvider(
                      create: (_) => getIt<PlanTimelineCubit>()..start(),
                      child: const ReportsPreviewPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addDebt,
        builder: (context, state) => const AddDebtPage(),
      ),
      GoRoute(
        path: AppRoutes.debtDetail,
        builder: (context, state) {
          return DebtDetailPage(id: state.pathParameters['id']!);
        },
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) =>
                EditDebtPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'log_payment',
            builder: (context, state) =>
                LogPaymentPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) =>
                PaymentHistoryPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'rate_history',
            builder: (context, state) =>
                RateHistoryPage(debtId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.syncBackup,
        builder: (context, state) => const SyncBackupPage(),
      ),
      GoRoute(
        path: AppRoutes.partnerSharing,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SharingCubit>(),
          child: const PartnerSharingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.inviteAccept,
        builder: (context, state) =>
            InviteAcceptPage(token: state.uri.queryParameters['token']),
      ),
      GoRoute(
        path: AppRoutes.sharedPlan,
        builder: (context, state) =>
            SharedPlanPage(shareId: state.pathParameters['shareId']!),
      ),
      GoRoute(
        path: AppRoutes.pricing,
        builder: (context, state) => const PricingPage(),
      ),
      GoRoute(
        path: AppRoutes.scenarios,
        builder: (context, state) => const ScenariosPage(),
      ),
      GoRoute(
        path: AppRoutes.createWhatIf,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ScenarioLabCubit>(),
          child: const CreateWhatIfPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.compareScenarios,
        builder: (context, state) => const CompareScenariosPage(),
      ),
    ],
  );
}

bool _isPremiumRoute(String location) {
  return location == AppRoutes.scenarios ||
      location == AppRoutes.createWhatIf ||
      location == AppRoutes.compareScenarios ||
      location == AppRoutes.reportsPreview ||
      location == AppRoutes.partnerSharing;
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
