import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/core/services/scenario_lab_service.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/data/local/stores/timeline_cache_store.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/interest_rate_history_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/scenario_assumption_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/scenario_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/domain/entities/scenario.dart';
import 'package:debt_payoff_manager/domain/enums/scenario_assumption_type.dart';

import '../../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepository;
  late PlanRepositoryImpl planRepository;
  late ScenarioRepositoryImpl scenarioRepository;
  late ScenarioAssumptionRepositoryImpl assumptionRepository;
  late SettingsRepositoryImpl settingsRepository;
  late ScenarioLabService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    debtRepository = DebtRepositoryImpl(db: db);
    planRepository = PlanRepositoryImpl(db: db);
    scenarioRepository = ScenarioRepositoryImpl(db: db);
    assumptionRepository = ScenarioAssumptionRepositoryImpl(db: db);
    settingsRepository = SettingsRepositoryImpl(db: db);
    final recastService = PlanRecastService(
      debtRepository: debtRepository,
      interestRateHistoryRepository: InterestRateHistoryRepositoryImpl(db: db),
      planRepository: planRepository,
      syncStateStore: SyncStateStore(db: db),
      timelineCacheStore: TimelineCacheStore(db: db),
    );
    service = ScenarioLabService(
      settingsRepository: settingsRepository,
      scenarioRepository: scenarioRepository,
      scenarioAssumptionRepository: assumptionRepository,
      debtRepository: debtRepository,
      planRepository: planRepository,
      planRecastService: recastService,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ScenarioLabService', () {
    test(
      'previews and saves an extra-monthly scenario with assumptions',
      () async {
        await debtRepository.addDebt(
          makeRepoDebt(
            id: 'debt-1',
            currentBalance: 120000,
            minimumPayment: 10000,
          ),
        );

        final preview = await service.previewExtraMonthly(
          deltaExtraMonthlyCents: 5000,
        );

        expect(preview.sourceScenarioId, 'main');
        expect(preview.previewMonthlyCommitment, 15000);
        expect(preview.monthlyCommitmentDelta, 5000);

        final saved = await service.savePreview(preview);
        final debts = await debtRepository.getAllDebts(
          scenarioId: saved.scenario.id,
        );
        final assumptions = await assumptionRepository.getByScenario(
          saved.scenario.id,
        );

        expect(saved.scenario.name, preview.summary);
        expect(debts, hasLength(1));
        expect(debts.single.scenarioId, saved.scenario.id);
        expect(saved.plan.scenarioId, saved.scenario.id);
        expect(assumptions, hasLength(1));
        expect(assumptions.single.type, ScenarioAssumptionType.extraMonthly);
        expect(assumptions.single.params['deltaExtraMonthlyCents'], 5000);
      },
    );

    test(
      'saves from the preview source when active scenario changes before save',
      () async {
        await debtRepository.addDebt(
          makeRepoDebt(
            id: 'main-debt',
            name: 'Main debt',
            currentBalance: 120000,
            minimumPayment: 10000,
          ),
        );

        await scenarioRepository.addScenario(
          Scenario(
            id: 'alternate',
            name: 'Alternate scenario',
            createdAt: DateTime.utc(2026, 5, 3),
          ),
        );
        await debtRepository.addDebt(
          makeRepoDebt(
            id: 'alternate-debt',
            scenarioId: 'alternate',
            name: 'Alternate debt',
            currentBalance: 900000,
            minimumPayment: 20000,
          ),
        );
        await planRepository.savePlan(
          makeRepoPlan(id: 'alternate-plan', scenarioId: 'alternate'),
        );

        final preview = await service.previewExtraMonthly(
          deltaExtraMonthlyCents: 5000,
        );

        final settings = await settingsRepository.getSettings();
        await settingsRepository.updateSettings(
          settings.copyWith(activeScenarioId: 'alternate'),
        );

        final saved = await service.savePreview(preview);
        final debts = await debtRepository.getAllDebts(
          scenarioId: saved.scenario.id,
        );

        expect(preview.sourceScenarioId, 'main');
        expect(debts, hasLength(1));
        expect(debts.single.name, 'Main debt');
        expect(debts.single.currentBalance, 120000);
      },
    );
  });
}
