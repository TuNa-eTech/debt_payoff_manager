import 'package:equatable/equatable.dart';

import '../../../../domain/entities/timeline_projection.dart';

/// State for timeline feature.
sealed class TimelineState extends Equatable {
  const TimelineState();

  @override
  List<Object?> get props => [];
}

class TimelineInitial extends TimelineState {
  const TimelineInitial();
}

class TimelineLoading extends TimelineState {
  const TimelineLoading();
}

class TimelineLoaded extends TimelineState {
  const TimelineLoaded({
    required this.projection,
    required this.debtFreeDate,
    required this.totalInterestProjected,
    required this.totalInterestSaved,
    required this.timeSavedMonths,
    this.previousDebtFreeDate,
  });

  final TimelineProjection projection;
  final DateTime debtFreeDate;

  /// Total projected interest in cents.
  final int totalInterestProjected;

  /// Interest saved vs minimum-only in cents.
  final int totalInterestSaved;

  /// Months saved vs minimum-only.
  final int timeSavedMonths;

  /// Previous debt-free date for showing delta (e.g., "→ May 2028 (↓ 2 months)").
  final DateTime? previousDebtFreeDate;

  @override
  List<Object?> get props => [
        projection, debtFreeDate, totalInterestProjected,
        totalInterestSaved, timeSavedMonths, previousDebtFreeDate,
      ];
}

class TimelineError extends TimelineState {
  const TimelineError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
