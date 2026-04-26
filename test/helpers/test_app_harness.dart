import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:debt_payoff_manager/core/di/injection.dart';
import 'package:debt_payoff_manager/core/i18n/app_locale.dart';
import 'package:debt_payoff_manager/core/router/app_router.dart';
import 'package:debt_payoff_manager/core/services/app_analytics.dart';
import 'package:debt_payoff_manager/core/services/backup_file_picker.dart';
import 'package:debt_payoff_manager/core/services/data_management_service.dart';
import 'package:debt_payoff_manager/core/services/monthly_action_service.dart';
import 'package:debt_payoff_manager/core/services/notification_permission_prompt_tracker.dart';
import 'package:debt_payoff_manager/core/services/notification_service.dart';
import 'package:debt_payoff_manager/core/services/payment_logging_service.dart';
import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/core/services/share_launcher.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/database_provider.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/data/local/stores/timeline_cache_store.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/payment_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_cubit.dart';
import 'package:debt_payoff_manager/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:debt_payoff_manager/features/onboarding/services/onboarding_analytics.dart';
import 'package:debt_payoff_manager/features/settings/cubit/settings_cubit.dart';
import 'package:debt_payoff_manager/l10n/app_localizations.dart';
import 'package:debt_payoff_manager/sync/cloud_backup_service.dart';

class TestAppHarness {
  TestAppHarness._({
    required this.db,
    required this.debtRepository,
    required this.paymentRepository,
    required this.planRepository,
    required this.settingsRepository,
    required this.syncStateStore,
    required this.timelineCacheStore,
    required this.planRecastService,
    required this.paymentLoggingService,
    required this.monthlyActionService,
    required this.appAnalytics,
    required this.backupFilePicker,
    required this.dataManagementService,
    required this.shareLauncher,
    required this.closeDbOnDispose,
  });

  final AppDatabase db;
  final DebtRepositoryImpl debtRepository;
  final PaymentRepositoryImpl paymentRepository;
  final PlanRepositoryImpl planRepository;
  final SettingsRepositoryImpl settingsRepository;
  final SyncStateStore syncStateStore;
  final TimelineCacheStore timelineCacheStore;
  final PlanRecastService planRecastService;
  final PaymentLoggingService paymentLoggingService;
  final MonthlyActionService monthlyActionService;
  final AppAnalytics appAnalytics;
  final BackupFilePicker backupFilePicker;
  final DataManagementService dataManagementService;
  final ShareLauncher shareLauncher;
  final bool closeDbOnDispose;

  late _TestAppScope _appScope;
  final List<_TestAppScope> _retiredScopes = [];

  DebtsCubit get debtsCubit => _appScope.debtsCubit;

  OnboardingCubit get onboardingCubit => _appScope.onboardingCubit;

  SettingsCubit get settingsCubit => _appScope.settingsCubit;

  GoRouter get router => _appScope.router;

  String get currentLocation {
    final location = router.state.uri.toString();
    return location.isEmpty ? AppRoutes.welcome : location;
  }

  static Future<TestAppHarness> create({
    AppDatabase? db,
    AppAnalytics? appAnalytics,
    BackupFilePicker? backupFilePicker,
    DataManagementService? dataManagementService,
    NotificationPermissionPromptTracker? notificationPermissionPromptTracker,
    NotificationService? notificationService,
    ShareLauncher? shareLauncher,
    CloudBackupService? cloudBackupService,
    String seedLocaleCode = AppLocale.fallbackLocaleCode,
    bool closeDbOnDispose = true,
  }) async {
    await getIt.reset();

    final resolvedDb =
        db ??
        DatabaseProvider.openTestDatabase(initialLocaleCode: seedLocaleCode);
    configureDependencies(
      database: resolvedDb,
      appAnalytics: appAnalytics,
      backupFilePicker: backupFilePicker,
      dataManagementService: dataManagementService,
      notificationPermissionPromptTracker:
          notificationPermissionPromptTracker ??
          _InMemoryNotificationPermissionPromptTracker(),
      notificationService: notificationService,
      shareLauncher: shareLauncher,
      cloudBackupService: cloudBackupService ?? _NoopCloudBackupService(),
      seedLocaleCode: seedLocaleCode,
    );

    final harness = TestAppHarness._(
      db: resolvedDb,
      debtRepository: getIt<DebtRepositoryImpl>(),
      paymentRepository: getIt<PaymentRepositoryImpl>(),
      planRepository: getIt<PlanRepositoryImpl>(),
      settingsRepository: getIt<SettingsRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
      timelineCacheStore: getIt<TimelineCacheStore>(),
      planRecastService: getIt<PlanRecastService>(),
      paymentLoggingService: getIt<PaymentLoggingService>(),
      monthlyActionService: getIt<MonthlyActionService>(),
      appAnalytics: getIt<AppAnalytics>(),
      backupFilePicker: getIt<BackupFilePicker>(),
      dataManagementService: getIt<DataManagementService>(),
      shareLauncher: getIt<ShareLauncher>(),
      closeDbOnDispose: closeDbOnDispose,
    );
    await harness._createAppScope();
    return harness;
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());
  }

  Future<void> relaunch(WidgetTester tester) async {
    final retiredScope = _appScope;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.idle();
    await tester.pump(const Duration(milliseconds: 16));
    _retiredScopes.add(retiredScope);
    await _createAppScope();
    await pumpApp(tester);
  }

  Future<void> disposeWidgetTest(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.idle();
    await tester.pump(const Duration(milliseconds: 16));
    await dispose();
    await tester.idle();
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 16));
  }

  Future<void> dispose() async {
    await _disposeAppScope(_appScope);
    for (final retiredScope in _retiredScopes.reversed) {
      await _disposeAppScope(retiredScope);
    }
    _retiredScopes.clear();
    await getIt.reset();
    if (closeDbOnDispose) {
      await db.close();
    }
  }

  Future<void> _createAppScope() async {
    final debtsCubit = DebtsCubit(debtRepository: getIt<DebtRepository>());
    await debtsCubit.start();

    final onboardingCubit = OnboardingCubit(
      settingsRepository: settingsRepository,
      onboardingAnalytics: getIt<OnboardingAnalytics>(),
    );
    await onboardingCubit.start();

    final settingsCubit = SettingsCubit(
      settingsRepository: settingsRepository,
    );

    final router = createRouter(
      settingsRepository: getIt<SettingsRepository>(),
      debtRepository: getIt<DebtRepository>(),
    );

    _appScope = _TestAppScope(
      debtsCubit: debtsCubit,
      onboardingCubit: onboardingCubit,
      settingsCubit: settingsCubit,
      router: router,
    );
  }

  Future<void> _disposeAppScope(_TestAppScope scope) async {
    scope.router.dispose();
    await scope.debtsCubit.close();
    await scope.onboardingCubit.close();
    await scope.settingsCubit.close();
  }

  Widget _buildApp() {
    return StreamBuilder<UserSettings>(
      stream: settingsRepository.watchSettings(),
      builder: (context, snapshot) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<DebtsCubit>.value(value: debtsCubit),
            BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: MaterialApp.router(
            locale: AppLocale.flutterLocaleForCode(snapshot.data?.localeCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appName ?? 'Debt Payoff X',
            title: 'Debt Payoff X',
            routerConfig: router,
          ),
        );
      },
    );
  }
}

class _NoopCloudBackupService implements CloudBackupService {
  final _controller = StreamController<CloudBackupRuntimeState>.broadcast();

  @override
  CloudBackupRuntimeState get currentState => const CloudBackupRuntimeState();

  @override
  Future<void> disableAndDeleteCloudBackup() async {}

  @override
  Future<void> enableWithApple() async {}

  @override
  Future<void> enableWithGoogle() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> refresh() async {}

  @override
  Stream<CloudBackupRuntimeState> watchRuntimeState() => _controller.stream;
}

class _TestAppScope {
  const _TestAppScope({
    required this.debtsCubit,
    required this.onboardingCubit,
    required this.settingsCubit,
    required this.router,
  });

  final DebtsCubit debtsCubit;
  final OnboardingCubit onboardingCubit;
  final SettingsCubit settingsCubit;
  final GoRouter router;
}

class _InMemoryNotificationPermissionPromptTracker
    implements NotificationPermissionPromptTracker {
  bool _hasPrompted = false;

  @override
  Future<bool> hasPrompted() async => _hasPrompted;

  @override
  Future<void> markPrompted() async {
    _hasPrompted = true;
  }
}
