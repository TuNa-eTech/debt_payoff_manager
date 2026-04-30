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
import 'package:debt_payoff_manager/data/repositories/tracked_interest_rate_history_repository.dart';
import 'package:debt_payoff_manager/domain/entities/interest_rate_history.dart';

import 'repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepository;
  late PlanRepositoryImpl planRepository;
  late SyncStateStore syncStateStore;
  late TrackedInterestRateHistoryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    debtRepository = DebtRepositoryImpl(db: db);
    final interestRateHistoryRepository = InterestRateHistoryRepositoryImpl(
      db: db,
    );
    planRepository = PlanRepositoryImpl(db: db);
    syncStateStore = SyncStateStore(db: db);
    repository = TrackedInterestRateHistoryRepository(
      base: interestRateHistoryRepository,
      debtRepository: debtRepository,
      syncStateStore: syncStateStore,
      planRecastService: PlanRecastService(
        debtRepository: debtRepository,
        interestRateHistoryRepository: interestRateHistoryRepository,
        planRepository: planRepository,
        syncStateStore: syncStateStore,
        timelineCacheStore: TimelineCacheStore(db: db),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'writes mark interest rate history dirty and recast the debt scenario',
    () async {
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'scenario-card',
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

      await repository.addRateHistory(
        InterestRateHistory(
          id: 'rate-1',
          debtId: 'scenario-card',
          apr: Decimal.parse('0.12'),
          effectiveFrom: DateTime.utc(2026, 1, 1),
        ),
      );

      final rateState = await syncStateStore.getState('interestRateHistory');
      final planState = await syncStateStore.getState('plans');

      expect(rateState?.pendingWrites, 1);
      expect(planState?.pendingWrites, 1);
    },
  );
}
