import '../entities/scenario_assumption.dart';

abstract class ScenarioAssumptionRepository {
  Future<List<ScenarioAssumption>> getByScenario(String scenarioId);

  Stream<List<ScenarioAssumption>> watchByScenario(String scenarioId);

  Future<ScenarioAssumption> addAssumption(ScenarioAssumption assumption);

  Future<void> updateAssumption(ScenarioAssumption assumption);

  Future<void> deleteAssumption(String id);
}
