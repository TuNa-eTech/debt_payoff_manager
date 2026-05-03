import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/stores/sync_state_store.dart';
import '../../data/local/stores/timeline_cache_store.dart';
import '../../data/repositories/debt_repository_impl.dart';
import '../../data/repositories/milestone_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/plan_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/tracked_debt_repository.dart';
import '../../data/repositories/tracked_milestone_repository.dart';
import '../../data/repositories/tracked_payment_repository.dart';
import '../../data/repositories/tracked_plan_repository.dart';
import '../../data/repositories/tracked_scenario_repository.dart';
import '../../data/repositories/tracked_settings_repository.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../features/debts/cubit/debts_cubit.dart';
import '../../features/monthly_action/cubit/monthly_action_cubit.dart';
import '../../features/onboarding/services/onboarding_analytics.dart';
import '../../features/plan/cubit/plan_timeline_cubit.dart';
import '../../sync/cloud_backup_remote_store.dart';
import '../../sync/cloud_backup_service.dart';
import '../../sync/firebase_sync_config.dart';
import '../../sync/firebase_sync_runtime.dart';
import '../../sync/pull_listener.dart';
import '../../sync/push_queue.dart';
import '../../sync/sync_auth_service.dart';
import '../../sync/sync_engine.dart';
import '../services/app_analytics.dart';
import '../services/backup_file_picker.dart';
import '../services/data_management_service.dart';
import '../services/milestone_notification_service.dart';
import '../services/milestone_service.dart';
import '../services/monthly_action_service.dart';
import '../services/monthly_summary_service.dart';
import '../services/device_id_service.dart';
import '../services/notification_permission_prompt_tracker.dart';
import '../services/notification_service.dart';
import '../services/payment_logging_service.dart';
import '../services/plan_recast_service.dart';
import '../services/reminder_scheduler_service.dart';
import '../services/report_generator_service.dart';
import '../services/share_launcher.dart';
import '../services/streak_service.dart';
import '../../data/repositories/scenario_repository_impl.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../../data/repositories/interest_rate_history_repository_impl.dart';
import '../../data/repositories/tracked_interest_rate_history_repository.dart';
import '../../domain/repositories/interest_rate_history_repository.dart';
import '../../features/progress/cubit/progress_cubit.dart';
import '../../features/pricing/cubit/pricing_cubit.dart';
import '../../features/pricing/data/firebase_entitlement_service.dart';
import '../../features/pricing/data/in_app_purchase_service.dart';
import '../../features/pricing/domain/entitlement_service.dart';
import '../../features/pricing/domain/purchase_service.dart';
import '../../features/scenarios/cubit/scenarios_cubit.dart';
import '../../features/settings/cubit/settings_cubit.dart';
import '../../features/sharing/cubit/sharing_cubit.dart';
import '../../features/sharing/data/invite_link_service.dart';
import '../../features/sharing/data/sharing_service.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initialize dependency injection.
///
/// Call this in `main()` before `runApp()`.
void configureDependencies({
  AppDatabase? database,
  AppAnalytics? appAnalytics,
  BackupFilePicker? backupFilePicker,
  DataManagementService? dataManagementService,
  NotificationPermissionPromptTracker? notificationPermissionPromptTracker,
  NotificationService? notificationService,
  ShareLauncher? shareLauncher,
  CloudBackupService? cloudBackupService,
  PurchaseService? purchaseService,
  EntitlementService? entitlementService,
  String? seedLocaleCode,
}) {
  // Database — singleton, opened once
  getIt.registerLazySingleton<AppDatabase>(
    () => database ?? DatabaseProvider.openDatabase(),
  );

  // Base repositories — singleton, injected with DB
  getIt.registerLazySingleton<DebtRepositoryImpl>(
    () => DebtRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<PaymentRepositoryImpl>(
    () => PaymentRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<PlanRepositoryImpl>(
    () => PlanRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<SettingsRepositoryImpl>(
    () => SettingsRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<MilestoneRepositoryImpl>(
    () => MilestoneRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<InterestRateHistoryRepositoryImpl>(
    () => InterestRateHistoryRepositoryImpl(db: getIt<AppDatabase>()),
  );

  // Local stores
  getIt.registerLazySingleton<SyncStateStore>(
    () => SyncStateStore(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TimelineCacheStore>(
    () => TimelineCacheStore(db: getIt<AppDatabase>()),
  );

  // Shared services
  getIt.registerLazySingleton<PlanRecastService>(
    () => PlanRecastService(
      debtRepository: getIt<DebtRepositoryImpl>(),
      interestRateHistoryRepository: getIt<InterestRateHistoryRepositoryImpl>(),
      planRepository: getIt<PlanRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
      timelineCacheStore: getIt<TimelineCacheStore>(),
    ),
  );
  getIt.registerLazySingleton<PaymentLoggingService>(
    () => PaymentLoggingService(
      db: getIt<AppDatabase>(),
      debtRepository: getIt<DebtRepositoryImpl>(),
      paymentRepository: getIt<PaymentRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
      planRecastService: getIt<PlanRecastService>(),
      settingsRepository: getIt<SettingsRepositoryImpl>(),
      milestoneService: getIt<MilestoneService>(),
    ),
  );
  getIt.registerLazySingleton<MonthlyActionService>(
    () => MonthlyActionService(
      debtRepository: getIt<DebtRepository>(),
      paymentRepository: getIt<PaymentRepository>(),
      planRepository: getIt<PlanRepository>(),
      planRecastService: getIt<PlanRecastService>(),
    ),
  );
  getIt.registerLazySingleton<MonthlySummaryService>(
    () => MonthlySummaryService(
      debtRepository: getIt<DebtRepository>(),
      paymentRepository: getIt<PaymentRepository>(),
      planRepository: getIt<PlanRepository>(),
    ),
  );
  getIt.registerLazySingleton<DataManagementService>(
    () =>
        dataManagementService ??
        DataManagementService(
          db: getIt<AppDatabase>(),
          syncStateStore: getIt<SyncStateStore>(),
        ),
  );
  getIt.registerLazySingleton<BackupFilePicker>(
    () => backupFilePicker ?? FilePickerBackupFilePicker(),
  );
  getIt.registerLazySingleton<AppAnalytics>(
    () => appAnalytics ?? const NoopAppAnalytics(),
  );
  getIt.registerLazySingleton<OnboardingAnalytics>(
    () => OnboardingAnalytics(analytics: getIt<AppAnalytics>()),
  );
  getIt.registerLazySingleton<ShareLauncher>(
    () => shareLauncher ?? SharePlusLauncher(),
  );

  // Cloud sync runtime is registered lazily and only used after user opt-in.
  getIt.registerLazySingleton<FirebaseSyncConfig>(
    FirebaseSyncConfig.fromEnvironment,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instance,
  );
  getIt.registerLazySingleton<FirebaseSyncInitializer>(
    () => DefaultFirebaseSyncInitializer(
      config: getIt<FirebaseSyncConfig>(),
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<SyncAuthService>(
    () => FirebaseSyncAuthService(
      auth: getIt<FirebaseAuth>(),
      initializer: getIt<FirebaseSyncInitializer>(),
    ),
  );
  getIt.registerLazySingleton<SyncRemoteWriter>(
    () => CloudFirestoreSyncRemoteWriter(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<DeviceIdService>(
    () => SharedPrefsDeviceIdService(),
  );
  getIt.registerLazySingleton<SyncPushQueue>(
    () => DriftSyncPushQueue(
      db: getIt<AppDatabase>(),
      syncStateStore: getIt<SyncStateStore>(),
      deviceIdService: getIt<DeviceIdService>(),
    ),
  );
  getIt.registerLazySingleton<SyncPullListener>(
    () => CloudFirestoreSyncPullListener(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<SyncPullApplier>(
    () => DriftSyncPullApplier(
      db: getIt<AppDatabase>(),
      syncStateStore: getIt<SyncStateStore>(),
    ),
  );
  getIt.registerLazySingleton<SyncEngine>(
    () => SyncEngine(
      pushQueue: getIt<SyncPushQueue>(),
      pullListener: getIt<SyncPullListener>(),
      remoteWriter: getIt<SyncRemoteWriter>(),
      pullApplier: getIt<SyncPullApplier>(),
    ),
  );
  getIt.registerLazySingleton<CloudBackupRemoteStore>(
    () => FirestoreCloudBackupRemoteStore(
      firestore: getIt<FirebaseFirestore>(),
      initializer: getIt<FirebaseSyncInitializer>(),
    ),
  );
  getIt.registerLazySingleton<CloudBackupService>(
    () =>
        cloudBackupService ??
        CloudBackupCoordinator(
          settingsRepository: getIt<SettingsRepository>(),
          authService: getIt<SyncAuthService>(),
          syncEngine: getIt<SyncEngine>(),
          remoteStore: getIt<CloudBackupRemoteStore>(),
        ),
  );
  getIt.registerLazySingleton<SharingService>(
    () => FirebaseSharingService(
      firestore: getIt<FirebaseFirestore>(),
      functions: getIt<FirebaseFunctions>(),
      initializer: getIt<FirebaseSyncInitializer>(),
      config: getIt<FirebaseSyncConfig>(),
    ),
  );
  getIt.registerLazySingleton<InviteLinkService>(
    () => AppLinksInviteLinkService(),
  );
  getIt.registerLazySingleton<PurchaseService>(
    () => purchaseService ?? InAppPurchaseService(),
  );
  getIt.registerLazySingleton<EntitlementService>(
    () =>
        entitlementService ??
        FirebaseEntitlementService(
          purchaseService: getIt<PurchaseService>(),
          functions: getIt<FirebaseFunctions>(),
          auth: getIt<FirebaseAuth>(),
          initializer: getIt<FirebaseSyncInitializer>(),
          settingsRepository: getIt<SettingsRepositoryImpl>(),
        ),
  );

  // Public repository contracts
  getIt.registerLazySingleton<DebtRepository>(
    () => TrackedDebtRepository(
      base: getIt<DebtRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
      planRecastService: getIt<PlanRecastService>(),
    ),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => TrackedPaymentRepository(
      base: getIt<PaymentRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
      planRecastService: getIt<PlanRecastService>(),
    ),
  );
  getIt.registerLazySingleton<PlanRepository>(
    () => TrackedPlanRepository(
      base: getIt<PlanRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
      planRecastService: getIt<PlanRecastService>(),
    ),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => TrackedSettingsRepository(
      base: getIt<SettingsRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
    ),
  );
  getIt.registerLazySingleton<MilestoneRepository>(
    () => TrackedMilestoneRepository(
      base: getIt<MilestoneRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
    ),
  );
  getIt.registerLazySingleton<MilestoneService>(
    () => MilestoneService(
      milestoneRepository: getIt<MilestoneRepository>(),
      debtRepository: getIt<DebtRepository>(),
    ),
  );

  // Notifications & Reminders
  getIt.registerLazySingleton<NotificationService>(
    () => notificationService ?? NotificationService(),
  );
  getIt.registerLazySingleton<NotificationPermissionPromptTracker>(
    () =>
        notificationPermissionPromptTracker ??
        SharedPrefsNotificationPermissionPromptTracker(),
  );
  getIt.registerLazySingleton<ReminderSchedulerService>(
    () => ReminderSchedulerService(
      notificationService: getIt<NotificationService>(),
      debtRepository: getIt<DebtRepository>(),
      paymentRepository: getIt<PaymentRepository>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );
  getIt.registerLazySingleton<MilestoneNotificationService>(
    () => MilestoneNotificationService(
      notificationService: getIt<NotificationService>(),
      milestoneRepository: getIt<MilestoneRepository>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );

  // Reports
  getIt.registerLazySingleton<ReportGeneratorService>(
    () => ReportGeneratorService(),
  );

  // Scenarios
  getIt.registerLazySingleton<ScenarioRepository>(
    () => TrackedScenarioRepository(
      base: ScenarioRepositoryImpl(db: getIt<AppDatabase>()),
      syncStateStore: getIt<SyncStateStore>(),
    ),
  );
  getIt.registerFactory<ScenariosCubit>(
    () => ScenariosCubit(
      scenarioRepository: getIt<ScenarioRepository>(),
      settingsRepository: getIt<SettingsRepository>(),
      entitlementService: getIt<EntitlementService>(),
    ),
  );

  // Interest Rate History
  getIt.registerLazySingleton<InterestRateHistoryRepository>(
    () => TrackedInterestRateHistoryRepository(
      base: getIt<InterestRateHistoryRepositoryImpl>(),
      debtRepository: getIt<DebtRepositoryImpl>(),
      syncStateStore: getIt<SyncStateStore>(),
      planRecastService: getIt<PlanRecastService>(),
    ),
  );

  // Progress
  getIt.registerLazySingleton<StreakService>(() => const StreakService());
  getIt.registerFactory<ProgressCubit>(
    () => ProgressCubit(
      debtRepository: getIt<DebtRepository>(),
      planRepository: getIt<PlanRepository>(),
      paymentRepository: getIt<PaymentRepository>(),
      milestoneRepository: getIt<MilestoneRepository>(),
      streakService: getIt<StreakService>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );

  // Settings state
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(settingsRepository: getIt<SettingsRepository>()),
  );
  getIt.registerFactory<PricingCubit>(
    () => PricingCubit(
      purchaseService: getIt<PurchaseService>(),
      entitlementService: getIt<EntitlementService>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );
  getIt.registerFactory<SharingCubit>(
    () => SharingCubit(
      sharingService: getIt<SharingService>(),
      settingsRepository: getIt<SettingsRepository>(),
      authService: getIt<SyncAuthService>(),
      entitlementService: getIt<EntitlementService>(),
    ),
  );

  // Feature state
  getIt.registerFactory<DebtsCubit>(
    () => DebtsCubit(
      debtRepository: getIt<DebtRepository>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );
  getIt.registerFactory<MonthlyActionCubit>(
    () => MonthlyActionCubit(
      monthlyActionService: getIt<MonthlyActionService>(),
      paymentLoggingService: getIt<PaymentLoggingService>(),
      debtRepository: getIt<DebtRepository>(),
      paymentRepository: getIt<PaymentRepository>(),
      planRepository: getIt<PlanRepository>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );
  getIt.registerFactory<PlanTimelineCubit>(
    () => PlanTimelineCubit(
      debtRepository: getIt<DebtRepository>(),
      planRepository: getIt<PlanRepository>(),
      timelineCacheStore: getIt<TimelineCacheStore>(),
      planRecastService: getIt<PlanRecastService>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );
}
