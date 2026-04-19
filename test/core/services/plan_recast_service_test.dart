import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/data/local/stores/timeline_cache_store.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';

import '../../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepository;
  late PlanRepositoryImpl planRepository;
  late SyncStateStore syncStateStore;
  late TimelineCacheStore timelineCacheStore;
  late PlanRecastService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    debtRepository = DebtRepositoryImpl(db: db);
    planRepository = PlanRepositoryImpl(db: db);
    syncStateStore = SyncStateStore(db: db);
    timelineCacheStore = TimelineCacheStore(db: db);
    service = PlanRecastService(
      debtRepository: debtRepository,
      planRepository: planRepository,
      syncStateStore: syncStateStore,
      timelineCacheStore: timelineCacheStore,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'recast persists plan summary, warms cache, and computes delta from the previous plan summary',
    () async {
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'card-small',
          name: 'Card Small',
          currentBalance: 400000,
          originalPrincipal: 400000,
          minimumPayment: 8000,
        ),
      );
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'loan-big',
          name: 'Loan Big',
          currentBalance: 1600000,
          originalPrincipal: 1600000,
          minimumPayment: 18000,
        ),
      );

      final first = (await service.recast(
        referenceDate: DateTime(2026, 1, 1),
      ))!;
      final cachedAfterFirst = await timelineCacheStore.getProjection(
        first.plan.id,
      );
      final storedAfterFirst = await planRepository.getCurrentPlan();
      final plansSyncAfterFirst = await syncStateStore.getState('plans');

      expect(first.delta.isFirstRun, isTrue);
      expect(first.plan.projectedDebtFreeDate, isNotNull);
      expect(first.plan.totalInterestProjected, isNotNull);
      expect(first.plan.totalInterestSaved, isNotNull);
      expect(cachedAfterFirst, isNotNull);
      expect(cachedAfterFirst!.months, isNotEmpty);
      expect(cachedAfterFirst.months.length, first.projection.months.length);
      expect(
        storedAfterFirst!.projectedDebtFreeDate,
        first.plan.projectedDebtFreeDate,
      );
      expect(plansSyncAfterFirst?.pendingWrites, 1);

      await planRepository.savePlan(
        storedAfterFirst.copyWith(extraMonthlyAmount: 100000),
      );

      final second = (await service.recast(
        referenceDate: DateTime(2026, 1, 1),
      ))!;
      final cachedAfterSecond = await timelineCacheStore.getProjection(
        second.plan.id,
      );
      final plansSyncAfterSecond = await syncStateStore.getState('plans');

      expect(second.delta.isFirstRun, isFalse);
      expect(
        second.delta.previousDebtFreeDate,
        first.plan.projectedDebtFreeDate,
      );
      expect(
        second.plan.projectedDebtFreeDate!.isBefore(
          first.plan.projectedDebtFreeDate!,
        ),
        isTrue,
      );
      expect(second.plan.totalInterestSaved, greaterThanOrEqualTo(0));
      expect(cachedAfterSecond, isNotNull);
      expect(
        cachedAfterSecond!.months.length,
        second.projection.months.length,
      );
      expect(plansSyncAfterSecond?.pendingWrites, 2);
    },
  );
}
