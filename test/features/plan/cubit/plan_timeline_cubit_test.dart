import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/data/local/stores/timeline_cache_store.dart';
import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/plan_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/plan/cubit/plan_timeline_cubit.dart';

import '../../../data/repositories/repository_test_helpers.dart';

class _MockDebtRepository extends Mock implements DebtRepository {}

class _MockPlanRepository extends Mock implements PlanRepository {}

class _MockTimelineCacheStore extends Mock implements TimelineCacheStore {}

class _MockPlanRecastService extends Mock implements PlanRecastService {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockDebtRepository debtRepository;
  late _MockPlanRepository planRepository;
  late _MockTimelineCacheStore timelineCacheStore;
  late _MockPlanRecastService planRecastService;
  late _MockSettingsRepository settingsRepository;
  late PlanTimelineCubit cubit;

  setUp(() {
    debtRepository = _MockDebtRepository();
    planRepository = _MockPlanRepository();
    timelineCacheStore = _MockTimelineCacheStore();
    planRecastService = _MockPlanRecastService();
    settingsRepository = _MockSettingsRepository();

    final settings = makeRepoSettings().copyWith(activeScenarioId: 'what-if');
    final plan = makeRepoPlan(id: 'what-if-plan', scenarioId: 'what-if');

    when(
      () => settingsRepository.getSettings(),
    ).thenAnswer((_) async => settings);
    when(
      () => settingsRepository.watchSettings(),
    ).thenAnswer((_) => Stream<UserSettings>.value(settings));
    when(
      () => debtRepository.watchAllDebts(scenarioId: 'what-if'),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      () => planRepository.watchCurrentPlan(scenarioId: 'what-if'),
    ).thenAnswer((_) => Stream.value(plan));
    when(
      () => debtRepository.getAllDebts(scenarioId: 'what-if'),
    ).thenAnswer((_) async => const []);
    when(
      () => planRepository.getCurrentPlan(scenarioId: 'what-if'),
    ).thenAnswer((_) async => plan);
    when(
      () => timelineCacheStore.getProjection('what-if-plan'),
    ).thenAnswer((_) async => null);

    cubit = PlanTimelineCubit(
      debtRepository: debtRepository,
      planRepository: planRepository,
      timelineCacheStore: timelineCacheStore,
      planRecastService: planRecastService,
      settingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('manual load uses the active scenario from settings', () async {
    await cubit.start();
    await pumpEventQueue();
    clearInteractions(debtRepository);
    clearInteractions(planRepository);

    await cubit.load();

    verify(() => debtRepository.getAllDebts(scenarioId: 'what-if')).called(1);
    verify(
      () => planRepository.getCurrentPlan(scenarioId: 'what-if'),
    ).called(1);
    verifyNever(() => debtRepository.getAllDebts(scenarioId: 'main'));
    verifyNever(() => planRepository.getCurrentPlan(scenarioId: 'main'));
  });

  test(
    'explicit main load is not confused with active scenario fallback',
    () async {
      final plan = makeRepoPlan(id: 'main-plan');
      when(
        () => debtRepository.getAllDebts(scenarioId: 'main'),
      ).thenAnswer((_) async => const []);
      when(
        () => planRepository.getCurrentPlan(scenarioId: 'main'),
      ).thenAnswer((_) async => plan);
      when(
        () => timelineCacheStore.getProjection('main-plan'),
      ).thenAnswer((_) async => null);

      await cubit.start();
      await pumpEventQueue();
      clearInteractions(debtRepository);
      clearInteractions(planRepository);

      await cubit.load(scenarioId: 'main');

      verify(() => debtRepository.getAllDebts(scenarioId: 'main')).called(1);
      verify(() => planRepository.getCurrentPlan(scenarioId: 'main')).called(1);
    },
  );
}
