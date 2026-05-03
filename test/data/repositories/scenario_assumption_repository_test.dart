import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/scenario_assumption_repository_impl.dart';
import 'package:debt_payoff_manager/domain/entities/scenario_assumption.dart';
import 'package:debt_payoff_manager/domain/enums/scenario_assumption_type.dart';

void main() {
  late AppDatabase db;
  late ScenarioAssumptionRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ScenarioAssumptionRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ScenarioAssumptionRepositoryImpl', () {
    test('adds and reads assumptions by scenario', () async {
      final now = DateTime.utc(2026, 5, 3);
      await repo.addAssumption(
        ScenarioAssumption(
          id: 'assumption-1',
          scenarioId: 'scenario-a',
          type: ScenarioAssumptionType.extraMonthly,
          summary: 'Extra \$50.00/month',
          params: const {'deltaExtraMonthlyCents': 5000},
          createdAt: now,
          updatedAt: now,
        ),
      );

      final result = await repo.getByScenario('scenario-a');

      expect(result, hasLength(1));
      expect(result.single.id, 'assumption-1');
      expect(result.single.type, ScenarioAssumptionType.extraMonthly);
      expect(result.single.params['deltaExtraMonthlyCents'], 5000);
    });

    test('deleteAssumption soft-deletes the row', () async {
      final now = DateTime.utc(2026, 5, 3);
      await repo.addAssumption(
        ScenarioAssumption(
          id: 'assumption-1',
          scenarioId: 'scenario-a',
          type: ScenarioAssumptionType.strategyChange,
          summary: 'Switch to Avalanche',
          params: const {'newStrategy': 'avalanche'},
          createdAt: now,
          updatedAt: now,
        ),
      );

      await repo.deleteAssumption('assumption-1');

      expect(await repo.getByScenario('scenario-a'), isEmpty);
      final raw = await (db.select(
        db.scenarioAssumptionsTable,
      )..where((row) => row.id.equals('assumption-1'))).getSingle();
      expect(raw.deletedAt, isNotNull);
    });
  });
}
