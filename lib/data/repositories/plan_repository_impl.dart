import '../../domain/entities/plan.dart';
import '../../domain/repositories/plan_repository.dart';

/// Concrete implementation of [PlanRepository] using Drift (SQLite).
class PlanRepositoryImpl implements PlanRepository {
  @override
  Future<Plan?> getCurrentPlan() async {
    // TODO: Implement via PlanDao
    return null;
  }

  @override
  Future<Plan> savePlan(Plan plan) async {
    // TODO: Implement
    return plan;
  }

  @override
  Future<void> deletePlan(String id) async {
    // TODO: Implement
  }

  @override
  Stream<Plan?> watchCurrentPlan() {
    // TODO: Implement
    return const Stream.empty();
  }
}
