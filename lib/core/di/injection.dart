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
import '../../data/repositories/tracked_payment_repository.dart';
import '../../data/repositories/tracked_plan_repository.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../features/debts/cubit/debts_cubit.dart';
import '../../features/monthly_action/cubit/monthly_action_cubit.dart';
import '../../features/plan/cubit/plan_timeline_cubit.dart';
import '../services/monthly_action_service.dart';
import '../services/payment_logging_service.dart';
import '../services/plan_recast_service.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initialize dependency injection.
///
/// Call this in `main()` before `runApp()`.
void configureDependencies({AppDatabase? database}) {
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
    () => getIt<SettingsRepositoryImpl>(),
  );
  getIt.registerLazySingleton<MilestoneRepository>(
    () => getIt<MilestoneRepositoryImpl>(),
  );

  // Feature state
  getIt.registerFactory<DebtsCubit>(
    () => DebtsCubit(debtRepository: getIt<DebtRepository>()),
  );
  getIt.registerFactory<MonthlyActionCubit>(
    () => MonthlyActionCubit(
      monthlyActionService: getIt<MonthlyActionService>(),
      paymentLoggingService: getIt<PaymentLoggingService>(),
      debtRepository: getIt<DebtRepository>(),
      paymentRepository: getIt<PaymentRepository>(),
      planRepository: getIt<PlanRepository>(),
    ),
  );
  getIt.registerFactory<PlanTimelineCubit>(
    () => PlanTimelineCubit(
      debtRepository: getIt<DebtRepository>(),
      planRepository: getIt<PlanRepository>(),
      timelineCacheStore: getIt<TimelineCacheStore>(),
      planRecastService: getIt<PlanRecastService>(),
    ),
  );
}
