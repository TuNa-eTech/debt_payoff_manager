import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/enums/strategy.dart';
import 'strategy_state.dart';

/// Cubit managing payoff strategy selection and comparison.
///
/// Feature 1.2: Payoff Strategy Engine
class StrategyCubit extends Cubit<StrategyState> {
  StrategyCubit() : super(const StrategyInitial());

  /// Load and compare strategies using the financial engine.
  Future<void> loadComparison() async {
    // TODO: Use TimelineSimulator to run both snowball and avalanche,
    // then emit StrategyLoaded with comparison data.
  }

  /// Switch to a different strategy.
  void selectStrategy(Strategy strategy) {
    final current = state;
    if (current is StrategyLoaded) {
      emit(StrategyLoaded(
        selectedStrategy: strategy,
        snowballDebtFreeDate: current.snowballDebtFreeDate,
        avalancheDebtFreeDate: current.avalancheDebtFreeDate,
        snowballTotalInterest: current.snowballTotalInterest,
        avalancheTotalInterest: current.avalancheTotalInterest,
      ));
    }
  }
}
