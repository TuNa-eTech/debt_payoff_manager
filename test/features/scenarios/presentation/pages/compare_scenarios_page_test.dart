import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/core/di/injection.dart';
import 'package:debt_payoff_manager/core/models/recast_delta.dart';
import 'package:debt_payoff_manager/core/models/strategy_preview.dart';
import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/domain/entities/plan.dart';
import 'package:debt_payoff_manager/domain/entities/scenario.dart';
import 'package:debt_payoff_manager/domain/entities/scenario_assumption.dart';
import 'package:debt_payoff_manager/domain/entities/timeline_projection.dart';
import 'package:debt_payoff_manager/domain/enums/scenario_assumption_type.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/plan_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/scenario_assumption_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/scenario_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/scenarios/presentation/pages/compare_scenarios_page.dart';
import 'package:debt_payoff_manager/features/settings/cubit/settings_cubit.dart';
import 'package:debt_payoff_manager/l10n/app_localizations.dart';

import '../../../../data/repositories/repository_test_helpers.dart';

class _MockScenarioRepository extends Mock implements ScenarioRepository {}

class _MockDebtRepository extends Mock implements DebtRepository {}

class _MockPlanRepository extends Mock implements PlanRepository {}

class _MockScenarioAssumptionRepository extends Mock
    implements ScenarioAssumptionRepository {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockPlanRecastService extends Mock implements PlanRecastService {}

void main() {
  late _MockScenarioRepository mockScenarioRepo;
  late _MockDebtRepository mockDebtRepo;
  late _MockPlanRepository mockPlanRepo;
  late _MockScenarioAssumptionRepository mockAssumptionRepo;
  late _MockSettingsRepository mockSettingsRepo;
  late SettingsCubit settingsCubit;

  setUp(() async {
    await getIt.reset();
    mockScenarioRepo = _MockScenarioRepository();
    mockDebtRepo = _MockDebtRepository();
    mockPlanRepo = _MockPlanRepository();
    mockAssumptionRepo = _MockScenarioAssumptionRepository();
    mockSettingsRepo = _MockSettingsRepository();

    getIt.registerSingleton<ScenarioRepository>(mockScenarioRepo);
    getIt.registerSingleton<DebtRepository>(mockDebtRepo);
    getIt.registerSingleton<PlanRepository>(mockPlanRepo);
    getIt.registerSingleton<ScenarioAssumptionRepository>(mockAssumptionRepo);
    getIt.registerSingleton<SettingsRepository>(mockSettingsRepo);

    when(() => mockSettingsRepo.watchSettings()).thenAnswer(
      (_) =>
          Stream.value(makeRepoSettings(currencyCode: 'USD', localeCode: 'en')),
    );
    when(() => mockSettingsRepo.getSettings()).thenAnswer(
      (_) async => makeRepoSettings(currencyCode: 'USD', localeCode: 'en'),
    );
    when(
      () => mockAssumptionRepo.getByScenario(any()),
    ).thenAnswer((_) async => const []);
    settingsCubit = SettingsCubit(settingsRepository: mockSettingsRepo);
  });

  tearDown(() async {
    await settingsCubit.close();
    await getIt.reset();
  });

  testWidgets('renders compare scenarios page with initial data', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 1, 1);
    final scenarioA = Scenario(id: 'a', name: 'Scenario A', createdAt: now);
    final scenarioB = Scenario(id: 'b', name: 'Scenario B', createdAt: now);

    when(
      () => mockScenarioRepo.getAllScenarios(),
    ).thenAnswer((_) async => [scenarioA, scenarioB]);

    // Scenario A: 2 debts, total 1000000 ($10,000), plan finishes Jan 2027
    when(() => mockDebtRepo.getAllDebts(scenarioId: 'a')).thenAnswer(
      (_) async => [
        makeRepoDebt(id: 'd1', currentBalance: 500000),
        makeRepoDebt(id: 'd2', currentBalance: 500000),
      ],
    );
    when(() => mockPlanRepo.getCurrentPlan(scenarioId: 'a')).thenAnswer(
      (_) async => makeRepoPlan(
        id: 'pa',
        projectedDebtFreeDate: DateTime.utc(2027, 1, 1),
        totalInterestProjected: 150000,
      ),
    );

    // Scenario B: 1 debt, total 1000000 ($10,000), plan finishes Jun 2026 (7 months earlier)
    when(() => mockDebtRepo.getAllDebts(scenarioId: 'b')).thenAnswer(
      (_) async => [makeRepoDebt(id: 'd3', currentBalance: 1000000)],
    );
    when(() => mockPlanRepo.getCurrentPlan(scenarioId: 'b')).thenAnswer(
      (_) async => makeRepoPlan(
        id: 'pb',
        projectedDebtFreeDate: DateTime.utc(2026, 6, 1),
        totalInterestProjected: 50000,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: settingsCubit,
          child: const CompareScenariosPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Titles
    expect(find.text('Compare Scenarios'), findsWidgets);
    expect(find.text('Scenario A'), findsWidgets);
    expect(find.text('Scenario B'), findsWidgets);

    // Scenario A: 2 debts, Scenario B: 1 debt
    expect(find.text('2'), findsWidgets);
    expect(find.text('1'), findsWidgets);

    // B is faster than A by 7 months
    expect(find.text('7 mo faster'), findsWidgets);

    // B is cheaper than A by $1,000 (150000 - 50000 = 100000 cents = $1,000)
    expect(find.text('\$1,000.00 less interest'), findsWidgets);
  });

  testWidgets(
    'preselects active plan against latest scenario with assumption',
    (tester) async {
      final now = DateTime.utc(2026, 1, 1);
      final main = Scenario(id: 'main', name: 'Main', createdAt: now);
      final blank = Scenario(
        id: 'blank',
        name: 'Blank duplicate',
        createdAt: now.add(const Duration(minutes: 1)),
      );
      final whatIf = Scenario(
        id: 'what-if',
        name: 'Extra \$50/month',
        createdAt: now.add(const Duration(minutes: 2)),
      );

      when(
        () => mockScenarioRepo.getAllScenarios(),
      ).thenAnswer((_) async => [main, blank, whatIf]);
      when(() => mockAssumptionRepo.getByScenario('what-if')).thenAnswer(
        (_) async => [
          ScenarioAssumption(
            id: 'assumption-1',
            scenarioId: 'what-if',
            type: ScenarioAssumptionType.extraMonthly,
            summary: 'Extra \$50/month',
            params: const {'deltaExtraMonthlyCents': 5000},
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      when(
        () => mockAssumptionRepo.getByScenario('main'),
      ).thenAnswer((_) async => const []);
      when(
        () => mockAssumptionRepo.getByScenario('blank'),
      ).thenAnswer((_) async => const []);
      when(() => mockDebtRepo.getAllDebts(scenarioId: 'main')).thenAnswer(
        (_) async => [makeRepoDebt(id: 'main-debt', currentBalance: 100000)],
      );
      when(() => mockDebtRepo.getAllDebts(scenarioId: 'what-if')).thenAnswer(
        (_) async => [makeRepoDebt(id: 'what-if-debt', currentBalance: 100000)],
      );
      when(() => mockPlanRepo.getCurrentPlan(scenarioId: 'main')).thenAnswer(
        (_) async => makeRepoPlan(
          id: 'main-plan',
          scenarioId: 'main',
          projectedDebtFreeDate: DateTime.utc(2027, 1, 1),
          totalInterestProjected: 10000,
          totalInterestSaved: 2000,
        ),
      );
      when(() => mockPlanRepo.getCurrentPlan(scenarioId: 'what-if')).thenAnswer(
        (_) async => makeRepoPlan(
          id: 'what-if-plan',
          scenarioId: 'what-if',
          extraMonthlyAmount: 5000,
          projectedDebtFreeDate: DateTime.utc(2026, 11, 1),
          totalInterestProjected: 8000,
          totalInterestSaved: 4000,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: settingsCubit,
            child: const CompareScenariosPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      verify(() => mockDebtRepo.getAllDebts(scenarioId: 'main')).called(1);
      verify(() => mockDebtRepo.getAllDebts(scenarioId: 'what-if')).called(1);
      verifyNever(() => mockDebtRepo.getAllDebts(scenarioId: 'blank'));
      expect(find.text('Extra \$50/month'), findsWidgets);
    },
  );

  testWidgets('recasts a stale selected scenario before comparison', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 1, 1);
    final scenarioA = Scenario(id: 'a', name: 'Scenario A', createdAt: now);
    final scenarioB = Scenario(id: 'b', name: 'Scenario B', createdAt: now);
    final recastService = _MockPlanRecastService();
    final stalePlan = makeRepoPlan(id: 'pa', scenarioId: 'a');
    final freshPlan = makeRepoPlan(
      id: 'pa',
      scenarioId: 'a',
      projectedDebtFreeDate: DateTime.utc(2026, 8, 1),
      totalInterestProjected: 25000,
      totalInterestSaved: 4000,
    );

    getIt.registerSingleton<PlanRecastService>(recastService);
    when(
      () => mockScenarioRepo.getAllScenarios(),
    ).thenAnswer((_) async => [scenarioA, scenarioB]);
    when(
      () => mockDebtRepo.getAllDebts(scenarioId: 'a'),
    ).thenAnswer((_) async => [makeRepoDebt(id: 'd1')]);
    when(
      () => mockDebtRepo.getAllDebts(scenarioId: 'b'),
    ).thenAnswer((_) async => [makeRepoDebt(id: 'd2')]);
    when(
      () => mockPlanRepo.getCurrentPlan(scenarioId: 'a'),
    ).thenAnswer((_) async => stalePlan);
    when(() => mockPlanRepo.getCurrentPlan(scenarioId: 'b')).thenAnswer(
      (_) async => makeRepoPlan(
        id: 'pb',
        scenarioId: 'b',
        projectedDebtFreeDate: DateTime.utc(2026, 12, 1),
        totalInterestProjected: 50000,
        totalInterestSaved: 1000,
      ),
    );
    when(
      () => recastService.recast(scenarioId: 'a'),
    ).thenAnswer((_) async => _recastResult(freshPlan));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: settingsCubit,
          child: const CompareScenariosPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    verify(() => recastService.recast(scenarioId: 'a')).called(1);
    expect(find.text('\$250.00'), findsWidgets);
  });
}

PlanRecastResult _recastResult(Plan plan) {
  return PlanRecastResult(
    plan: plan,
    projection: TimelineProjection(
      planId: plan.id,
      generatedAt: DateTime.utc(2026, 1, 1),
      months: const [],
    ),
    preview: StrategyPreview(
      strategy: Strategy.snowball,
      projectedDebtFreeDate: plan.projectedDebtFreeDate,
      projectedMonths: 0,
      totalInterestProjected: plan.totalInterestProjected ?? 0,
      totalInterestSaved: plan.totalInterestSaved ?? 0,
      totalBalance: 0,
    ),
    delta: RecastDelta(
      previousDebtFreeDate: null,
      newDebtFreeDate: plan.projectedDebtFreeDate,
      previousTotalInterestProjected: null,
      newTotalInterestProjected: plan.totalInterestProjected,
      previousTotalInterestSaved: null,
      newTotalInterestSaved: plan.totalInterestSaved,
    ),
  );
}
