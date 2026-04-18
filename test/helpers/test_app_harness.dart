import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
    required this.closeDbOnDispose,
  });

  final AppDatabase db;
  final DebtRepositoryImpl debtRepository;
  final PaymentRepositoryImpl paymentRepository;
  final PlanRepositoryImpl planRepository;
  final SettingsRepositoryImpl settingsRepository;
  final bool closeDbOnDispose;

  late _TestAppScope _appScope;
  final List<_TestAppScope> _retiredScopes = [];

  DebtsCubit get debtsCubit => _appScope.debtsCubit;

  OnboardingCubit get onboardingCubit => _appScope.onboardingCubit;

  GoRouter get router => _appScope.router;

  String get currentLocation {
    final location = router.routeInformationProvider.value.uri.toString();
    return location.isEmpty ? AppRoutes.welcome : location;
  }

  static Future<TestAppHarness> create({
    AppDatabase? db,
    bool closeDbOnDispose = true,
  }) async {
    await getIt.reset();

    final resolvedDb = db ?? DatabaseProvider.openTestDatabase();
    final debtRepository = DebtRepositoryImpl(db: resolvedDb);
    final paymentRepository = PaymentRepositoryImpl(db: resolvedDb);
    final planRepository = PlanRepositoryImpl(db: resolvedDb);
    final settingsRepository = SettingsRepositoryImpl(db: resolvedDb);

    getIt.registerSingleton<AppDatabase>(resolvedDb);
    getIt.registerSingleton<DebtRepository>(debtRepository);
    getIt.registerSingleton<PaymentRepository>(paymentRepository);
    getIt.registerSingleton<PlanRepository>(planRepository);
    getIt.registerSingleton<SettingsRepository>(settingsRepository);

    final harness = TestAppHarness._(
      db: resolvedDb,
      debtRepository: debtRepository,
      paymentRepository: paymentRepository,
      planRepository: planRepository,
      settingsRepository: settingsRepository,
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
    final debtsCubit = DebtsCubit(debtRepository: debtRepository);
    await debtsCubit.start();

    final onboardingCubit = OnboardingCubit(
      settingsRepository: settingsRepository,
    );
    await onboardingCubit.start();

    final router = createRouter(
      settingsRepository: settingsRepository,
      debtRepository: debtRepository,
    );

    _appScope = _TestAppScope(
      debtsCubit: debtsCubit,
      onboardingCubit: onboardingCubit,
      router: router,
    );
  }

  Future<void> _disposeAppScope(_TestAppScope scope) async {
    scope.router.dispose();
    await scope.debtsCubit.close();
    await scope.onboardingCubit.close();
  }

  Widget _buildApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DebtsCubit>.value(value: debtsCubit),
        BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }
}

class _TestAppScope {
  const _TestAppScope({
    required this.debtsCubit,
    required this.onboardingCubit,
    required this.router,
  });

  final DebtsCubit debtsCubit;
  final OnboardingCubit onboardingCubit;
  final GoRouter router;
}
