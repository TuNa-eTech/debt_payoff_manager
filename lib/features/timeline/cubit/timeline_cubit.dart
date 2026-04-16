import 'package:flutter_bloc/flutter_bloc.dart';

import 'timeline_state.dart';

/// Cubit managing the living payoff timeline.
///
/// Feature 1.3: Living Payoff Timeline
///
/// Wraps the TimelineSimulator engine and triggers recast
/// when debts/plan change.
class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit() : super(const TimelineInitial());

  /// Generate timeline projection using the simulation engine.
  ///
  /// Per spec §9.6: "Không incremental partial update —
  /// full resimulate là đơn giản, đúng, và đủ nhanh."
  Future<void> generateTimeline() async {
    emit(const TimelineLoading());
    try {
      // TODO: Get debts + plan from repositories,
      // run TimelineSimulator.simulate() and simulateMinimumOnly(),
      // compute savings, emit TimelineLoaded.
    } catch (e) {
      emit(TimelineError(message: e.toString()));
    }
  }

  /// Recast timeline after any input change.
  ///
  /// Per spec §9.6: "surface delta trong UI:
  /// Debt-free date: July 2028 → May 2028 (↓ 2 months)"
  Future<void> recastTimeline() async {
    final previousDate =
        state is TimelineLoaded ? (state as TimelineLoaded).debtFreeDate : null;

    await generateTimeline();

    // If we have a previous date, update the state with delta info
    if (previousDate != null && state is TimelineLoaded) {
      final loaded = state as TimelineLoaded;
      emit(TimelineLoaded(
        projection: loaded.projection,
        debtFreeDate: loaded.debtFreeDate,
        totalInterestProjected: loaded.totalInterestProjected,
        totalInterestSaved: loaded.totalInterestSaved,
        timeSavedMonths: loaded.timeSavedMonths,
        previousDebtFreeDate: previousDate,
      ));
    }
  }
}
