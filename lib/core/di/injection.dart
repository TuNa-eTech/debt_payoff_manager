import 'package:get_it/get_it.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/debt_repository_impl.dart';
import '../../data/repositories/milestone_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/plan_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/settings_repository.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initialize dependency injection.
///
/// Call this in `main()` before `runApp()`.
void configureDependencies() {
  // Database — singleton, opened once
  getIt.registerLazySingleton<AppDatabase>(
    () => DatabaseProvider.openDatabase(),
  );

  // Repositories — singleton, injected with DB
  getIt.registerLazySingleton<DebtRepository>(
    () => DebtRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<PlanRepository>(
    () => PlanRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<MilestoneRepository>(
    () => MilestoneRepositoryImpl(db: getIt<AppDatabase>()),
  );
}
