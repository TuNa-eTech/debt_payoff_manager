import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:debt_payoff_manager/core/di/injection.dart';
import 'package:debt_payoff_manager/core/router/app_router.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/database_provider.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/payment_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/payment_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/plan_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_cubit.dart';
import 'package:debt_payoff_manager/features/onboarding/cubit/onboarding_cubit.dart';

class TestAppHarness {
  TestAppHarness._({
    required this.db,
    required this.debtRepository,
    required this.paymentRepository,
    required this.planRepository,
    required this.settingsRepository,
    required this.debtsCubit,
    required this.onboardingCubit,
    required this.router,
  });

  final AppDatabase db;
  final DebtRepositoryImpl debtRepository;
  final PaymentRepositoryImpl paymentRepository;
  final PlanRepositoryImpl planRepository;
  final SettingsRepositoryImpl settingsRepository;
  final DebtsCubit debtsCubit;
  final OnboardingCubit onboardingCubit;
  final GoRouter router;

  static Future<TestAppHarness> create() async {
    await getIt.reset();

    final db = DatabaseProvider.openTestDatabase();
    final debtRepository = DebtRepositoryImpl(db: db);
    final paymentRepository = PaymentRepositoryImpl(db: db);
    final planRepository = PlanRepositoryImpl(db: db);
    final settingsRepository = SettingsRepositoryImpl(db: db);

    getIt.registerSingleton<AppDatabase>(db);
    getIt.registerSingleton<DebtRepository>(debtRepository);
    getIt.registerSingleton<PaymentRepository>(paymentRepository);
    getIt.registerSingleton<PlanRepository>(planRepository);
    getIt.registerSingleton<SettingsRepository>(settingsRepository);

    final debtsCubit = DebtsCubit(debtRepository: debtRepository);
    await debtsCubit.start();
    await Future<void>.delayed(Duration.zero);

    final onboardingCubit = OnboardingCubit(
      settingsRepository: settingsRepository,
    );
    await onboardingCubit.start();
    await Future<void>.delayed(Duration.zero);

    final router = createRouter(
      settingsRepository: settingsRepository,
      debtRepository: debtRepository,
    );

    return TestAppHarness._(
      db: db,
      debtRepository: debtRepository,
      paymentRepository: paymentRepository,
      planRepository: planRepository,
      settingsRepository: settingsRepository,
      debtsCubit: debtsCubit,
      onboardingCubit: onboardingCubit,
      router: router,
    );
  }

  Widget app() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DebtsCubit>.value(value: debtsCubit),
        BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> dispose() async {
    router.dispose();
    await debtsCubit.close();
    await onboardingCubit.close();
    await getIt.reset();
    await db.close();
  }
}
