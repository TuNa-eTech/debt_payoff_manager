import 'package:equatable/equatable.dart';

import '../../domain/enums/strategy.dart';

/// Projection summary used by strategy and extra-amount previews.
class StrategyPreview extends Equatable {
  const StrategyPreview({
    required this.strategy,
    required this.projectedDebtFreeDate,
    required this.projectedMonths,
    required this.totalInterestProjected,
    required this.totalInterestSaved,
    required this.totalBalance,
  });

  final Strategy strategy;
  final DateTime? projectedDebtFreeDate;
  final int projectedMonths;
  final int totalInterestProjected;
  final int totalInterestSaved;
  final int totalBalance;

  @override
  List<Object?> get props => [
        strategy,
        projectedDebtFreeDate,
        projectedMonths,
        totalInterestProjected,
        totalInterestSaved,
        totalBalance,
      ];
}
