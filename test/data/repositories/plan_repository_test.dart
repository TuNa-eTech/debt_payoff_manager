import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';

import 'repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late PlanRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PlanRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PlanRepositoryImpl', () {
    test('fresh database seeds the main scenario plan', () async {
      final plan = await repo.getCurrentPlan();

      expect(plan, isNotNull);
      expect(plan!.scenarioId, 'main');
      expect(plan.strategy, Strategy.snowball);
      expect(plan.extraMonthlyAmount, 0);
      expect(plan.lastRecastAt, isNotNull);
    });

    test(
      'savePlan upserts by scenarioId and preserves existing row id',
      () async {
        final seeded = await repo.getCurrentPlan();
        final updated = makeRepoPlan(
          id: 'new-id-that-should-not-win',
          strategy: Strategy.avalanche,
          extraMonthlyAmount: 15000,
        );

        final saved = await repo.savePlan(updated);

        expect(saved.id, seeded!.id);
        expect(saved.strategy, Strategy.avalanche);
        expect(saved.extraMonthlyAmount, 15000);
        expect(saved.createdAt, seeded.createdAt);

        final persisted = await repo.getCurrentPlan();
        expect(persisted!.id, seeded.id);
        expect(persisted.strategy, Strategy.avalanche);
      },
    );

    test('savePlan creates a new active plan for a new scenario', () async {
      final saved = await repo.savePlan(
        makeRepoPlan(
          id: 'what-if-plan',
          scenarioId: 'what-if',
          strategy: Strategy.custom,
          customOrder: const ['debt-2', 'debt-1'],
          extraMonthlyAmount: 9000,
        ),
      );

      expect(saved.id, 'what-if-plan');

      final persisted = await repo.getCurrentPlan(scenarioId: 'what-if');
      expect(persisted, isNotNull);
      expect(persisted!.scenarioId, 'what-if');
      expect(persisted.strategy, Strategy.custom);
      expect(persisted.customOrder, ['debt-2', 'debt-1']);
    });

    test('deletePlan performs soft delete', () async {
      final plan = await repo.getCurrentPlan();

      await repo.deletePlan(plan!.id);

      expect(await repo.getCurrentPlan(), isNull);
      final raw = await (db.select(
        db.plansTable,
      )..where((row) => row.id.equals(plan.id))).getSingleOrNull();
      expect(raw!.deletedAt, isNotNull);
    });

    test('watchCurrentPlan emits on updates', () async {
      final stream = repo.watchCurrentPlan();

      await expectLater(
        stream,
        emits(predicate<dynamic>((plan) => plan?.scenarioId == 'main')),
      );

      await repo.savePlan(
        makeRepoPlan(strategy: Strategy.avalanche, extraMonthlyAmount: 7000),
      );

      await expectLater(
        stream,
        emits(
          predicate<dynamic>(
            (plan) =>
                plan?.strategy == Strategy.avalanche &&
                plan?.extraMonthlyAmount == 7000,
          ),
        ),
      );
    });

    test('validates negative extra and invalid custom order', () async {
      expect(
        () => repo.savePlan(makeRepoPlan(extraMonthlyAmount: -1)),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repo.savePlan(
          makeRepoPlan(strategy: Strategy.custom, customOrder: null),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repo.savePlan(
          makeRepoPlan(
            strategy: Strategy.custom,
            customOrder: const ['debt-1', 'debt-1'],
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('round-trip preserves projections and custom order fields', () async {
      final projectedDate = DateTime(2027, 6, 1);
      await repo.savePlan(
        makeRepoPlan(
          scenarioId: 'projection',
          strategy: Strategy.custom,
          customOrder: const ['A', 'B', 'C'],
          extraMonthlyAmount: 12000,
          projectedDebtFreeDate: projectedDate,
          totalInterestProjected: 45000,
          totalInterestSaved: 12000,
        ),
      );

      final persisted = await repo.getCurrentPlan(scenarioId: 'projection');
      expect(persisted!.customOrder, ['A', 'B', 'C']);
      expect(persisted.projectedDebtFreeDate, projectedDate);
      expect(persisted.totalInterestProjected, 45000);
      expect(persisted.totalInterestSaved, 12000);
    });
  });
}
