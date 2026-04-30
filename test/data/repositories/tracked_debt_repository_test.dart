import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/data/local/stores/timeline_cache_store.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/interest_rate_history_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/tracked_debt_repository.dart';

import 'repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepository;
  late PlanRepositoryImpl planRepository;
  late TrackedDebtRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    debtRepository = DebtRepositoryImpl(db: db);
    planRepository = PlanRepositoryImpl(db: db);
    final syncStateStore = SyncStateStore(db: db);
    repository = TrackedDebtRepository(
      base: debtRepository,
      syncStateStore: syncStateStore,
      planRecastService: PlanRecastService(
        debtRepository: debtRepository,
        interestRateHistoryRepository: InterestRateHistoryRepositoryImpl(
          db: db,
        ),
        planRepository: planRepository,
        syncStateStore: syncStateStore,
        timelineCacheStore: TimelineCacheStore(db: db),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('deleteDebt recasts the deleted debt scenario', () async {
    await debtRepository.addDebt(
      makeRepoDebt(
        id: 'what-if-card',
        scenarioId: 'what-if',
        currentBalance: 120000,
        originalPrincipal: 120000,
        apr: Decimal.zero,
        minimumPayment: 12000,
      ),
    );
    await planRepository.savePlan(
      makeRepoPlan(id: 'what-if-plan', scenarioId: 'what-if'),
    );

    await repository.deleteDebt('what-if-card');

    final whatIfPlan = await planRepository.getCurrentPlan(
      scenarioId: 'what-if',
    );
    final mainPlan = await planRepository.getCurrentPlan();

    expect(whatIfPlan!.projectedDebtFreeDate, isNotNull);
    expect(mainPlan!.projectedDebtFreeDate, isNull);
  });

  test('restoreDebt recasts the restored debt scenario', () async {
    await debtRepository.addDebt(
      makeRepoDebt(
        id: 'restored-card',
        scenarioId: 'what-if',
        currentBalance: 120000,
        originalPrincipal: 120000,
        apr: Decimal.zero,
        minimumPayment: 12000,
      ),
    );
    await planRepository.savePlan(
      makeRepoPlan(id: 'what-if-plan', scenarioId: 'what-if'),
    );
    await debtRepository.deleteDebt('restored-card');

    await repository.restoreDebt('restored-card');

    final whatIfPlan = await planRepository.getCurrentPlan(
      scenarioId: 'what-if',
    );
    final mainPlan = await planRepository.getCurrentPlan();

    expect(whatIfPlan!.projectedDebtFreeDate, isNotNull);
    expect(mainPlan!.projectedDebtFreeDate, isNull);
  });
}
