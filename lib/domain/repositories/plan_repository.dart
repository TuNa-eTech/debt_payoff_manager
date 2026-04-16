import '../entities/plan.dart';

/// Abstract interface for plan data access.
abstract class PlanRepository {
  /// Get the current active plan (singleton per user in MVP).
  Future<Plan?> getCurrentPlan();

  /// Save or update the plan.
  Future<Plan> savePlan(Plan plan);

  /// Delete the plan.
  Future<void> deletePlan(String id);

  /// Watch the current plan as a stream.
  Stream<Plan?> watchCurrentPlan();
}
