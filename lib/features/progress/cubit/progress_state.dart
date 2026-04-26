import 'package:equatable/equatable.dart';

import '../../../domain/entities/milestone.dart';

class ProgressState extends Equatable {
  const ProgressState({
    this.isLoading = true,
    this.totalPaidCents = 0,
    this.totalOriginalCents = 0,
    this.totalRemainingCents = 0,
    this.interestSavedCents = 0,
    this.streak = 0,
    this.unseenMilestones = const [],
  });

  final bool isLoading;
  final int totalPaidCents;
  final int totalOriginalCents;
  final int totalRemainingCents;
  final int interestSavedCents;
  final int streak;
  final List<Milestone> unseenMilestones;

  double get overallProgress => totalOriginalCents == 0
      ? 0.0
      : (totalPaidCents / totalOriginalCents).clamp(0.0, 1.0);

  ProgressState copyWith({
    bool? isLoading,
    int? totalPaidCents,
    int? totalOriginalCents,
    int? totalRemainingCents,
    int? interestSavedCents,
    int? streak,
    List<Milestone>? unseenMilestones,
  }) {
    return ProgressState(
      isLoading: isLoading ?? this.isLoading,
      totalPaidCents: totalPaidCents ?? this.totalPaidCents,
      totalOriginalCents: totalOriginalCents ?? this.totalOriginalCents,
      totalRemainingCents: totalRemainingCents ?? this.totalRemainingCents,
      interestSavedCents: interestSavedCents ?? this.interestSavedCents,
      streak: streak ?? this.streak,
      unseenMilestones: unseenMilestones ?? this.unseenMilestones,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    totalPaidCents,
    totalOriginalCents,
    totalRemainingCents,
    interestSavedCents,
    streak,
    unseenMilestones,
  ];
}
