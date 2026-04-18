import 'package:equatable/equatable.dart';

import '../enums/milestone_type.dart';

/// Milestone entity — tracks user achievements and celebrations.
///
/// Reference: data-schema.md §8
///
/// `debtId` is nullable because some milestones are global
/// (e.g., allDebtFree, streaks).
class Milestone extends Equatable {
  const Milestone({
    required this.id,
    this.scenarioId = 'main',
    required this.type,
    this.debtId,
    required this.achievedAt,
    this.seen = false,
    this.metadata,
    required this.createdAt,
    this.deletedAt,
  });

  final String id;
  final String scenarioId;
  final MilestoneType type;

  /// Nullable for global milestones (e.g., allDebtFree).
  final String? debtId;
  final DateTime achievedAt;

  /// Whether user has dismissed the celebration notification.
  final bool seen;

  /// JSON metadata (e.g., {"savedAmount": 1580, "months": 6}).
  final String? metadata;

  final DateTime createdAt;
  final DateTime? deletedAt;

  Milestone copyWith({
    String? id,
    String? scenarioId,
    MilestoneType? type,
    String? debtId,
    DateTime? achievedAt,
    bool? seen,
    String? metadata,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      type: type ?? this.type,
      debtId: debtId ?? this.debtId,
      achievedAt: achievedAt ?? this.achievedAt,
      seen: seen ?? this.seen,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, scenarioId, type, debtId, achievedAt, seen, metadata,
        createdAt, deletedAt,
      ];
}
