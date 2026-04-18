import '../entities/plan.dart';

/// Abstract interface for plan data access.
///
/// Plans are singleton per scenario (1 plan per scenarioId).
abstract class PlanRepository {
  /// Get the current active plan for a scenario.
  Future<Plan?> getCurrentPlan({String scenarioId = 'main'});

  /// Save or update the plan (upsert pattern).
  Future<Plan> savePlan(Plan plan);

  /// Soft delete the plan.
  Future<void> deletePlan(String id);

  /// Watch the current plan as a stream.
  Stream<Plan?> watchCurrentPlan({String scenarioId = 'main'});
}
