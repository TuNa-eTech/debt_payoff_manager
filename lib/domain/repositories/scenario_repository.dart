import '../entities/scenario.dart';

/// Abstract interface for scenario data access.
abstract class ScenarioRepository {
  /// Get all non-deleted scenarios, ordered by createdAt.
  Future<List<Scenario>> getAllScenarios();

  /// Watch all non-deleted scenarios as a stream.
  Stream<List<Scenario>> watchAllScenarios();

  /// Add a new scenario.
  Future<Scenario> addScenario(Scenario scenario);

  /// Rename an existing scenario.
  Future<void> renameScenario(String id, String name);

  /// Soft-delete a scenario by id.
  ///
  /// Guard: returns false if [id] == 'main' (main scenario cannot be deleted).
  Future<bool> deleteScenario(String id);

  /// Duplicate an existing scenario's debts and plan into a new scenario.
  ///
  /// Returns the ID of the newly created scenario.
  /// Payments are NOT copied — what-if scenarios start fresh.
  Future<String> duplicateScenario(String sourceId, String newName);

  /// Copy debts from [sourceId] into [targetId] without overwriting
  /// existing debts in the target or copying payment history.
  ///
  /// Returns the number of debts that were copied.
  Future<int> copyDebtsToScenario(String sourceId, String targetId);
}
