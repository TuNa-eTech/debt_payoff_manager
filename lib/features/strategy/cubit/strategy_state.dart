import 'package:equatable/equatable.dart';

import '../../../../domain/enums/strategy.dart';

/// State for strategy feature.
sealed class StrategyState extends Equatable {
  const StrategyState();

  @override
  List<Object?> get props => [];
}

class StrategyInitial extends StrategyState {
  const StrategyInitial();
}

class StrategyLoaded extends StrategyState {
  const StrategyLoaded({
    required this.selectedStrategy,
    required this.snowballDebtFreeDate,
    required this.avalancheDebtFreeDate,
    required this.snowballTotalInterest,
    required this.avalancheTotalInterest,
  });

  final Strategy selectedStrategy;
  final DateTime snowballDebtFreeDate;
  final DateTime avalancheDebtFreeDate;

  /// Total interest in cents for comparison.
  final int snowballTotalInterest;
  final int avalancheTotalInterest;

  /// Interest saved by choosing avalanche over snowball.
  int get interestDifference => snowballTotalInterest - avalancheTotalInterest;

  @override
  List<Object?> get props => [
        selectedStrategy, snowballDebtFreeDate, avalancheDebtFreeDate,
        snowballTotalInterest, avalancheTotalInterest,
      ];
}
