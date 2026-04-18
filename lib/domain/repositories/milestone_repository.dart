import '../entities/milestone.dart';
import '../enums/milestone_type.dart';

/// Abstract interface for milestone data access.
abstract class MilestoneRepository {
  /// Get all milestones that haven't been seen yet.
  Future<List<Milestone>> getUnseenMilestones({
    String scenarioId = 'main',
  });

  /// Get all milestones for a specific debt.
  Future<List<Milestone>> getMilestonesForDebt(String debtId);

  /// Add a new milestone (with uniqueness check).
  Future<Milestone> addMilestone(Milestone milestone);

  /// Mark a milestone as seen.
  Future<void> markSeen(String id);

  /// Check if a milestone type already exists for a debt.
  Future<bool> milestoneExists(MilestoneType type, {String? debtId});

  /// Watch unseen milestones as a stream.
  Stream<List<Milestone>> watchUnseenMilestones({
    String scenarioId = 'main',
  });
}
