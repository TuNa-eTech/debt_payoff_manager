import 'package:drift/drift.dart';

import '../../domain/entities/milestone.dart';
import '../local/database.dart';

/// Maps between Drift [MilestoneRow] and domain [Milestone] entity.
extension MilestoneRowMapper on MilestoneRow {
  Milestone toDomain() {
    return Milestone(
      id: id,
      scenarioId: scenarioId,
      type: type,
      debtId: debtId,
      achievedAt: achievedAt,
      seen: seen,
      metadata: metadata,
      createdAt: createdAt,
      deletedAt: deletedAt,
    );
  }
}

/// Maps from domain [Milestone] to Drift [MilestonesTableCompanion].
extension MilestoneCompanionMapper on Milestone {
  MilestonesTableCompanion toCompanion() {
    return MilestonesTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      type: Value(type),
      debtId: Value(debtId),
      achievedAt: Value(achievedAt),
      seen: Value(seen),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
      deletedAt: Value(deletedAt),
    );
  }
}
