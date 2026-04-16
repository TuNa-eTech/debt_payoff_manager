import 'package:equatable/equatable.dart';

import '../enums/payment_cadence.dart';
import '../enums/strategy.dart';

/// Plan entity — represents a payoff strategy configuration.
///
/// Reference: financial-engine-spec.md §3.3
class Plan extends Equatable {
  const Plan({
    required this.id,
    required this.strategy,
    required this.extraMonthlyAmount,
    this.extraPaymentCadence = PaymentCadence.monthly,
    this.customOrder,
    this.lastRecastAt,
    this.projectedDebtFreeDate,
    this.totalInterestProjected,
    this.totalInterestSavedVsMinimumOnly,
  });

  final String id;
  final Strategy strategy;

  /// Extra monthly amount in cents (>= 0).
  final int extraMonthlyAmount;

  final PaymentCadence extraPaymentCadence;

  /// Only used when strategy == Strategy.custom.
  final List<String>? customOrder;

  // ── Computed & cached ──
  final DateTime? lastRecastAt;
  final DateTime? projectedDebtFreeDate;

  /// Total projected interest in cents.
  final int? totalInterestProjected;

  /// Interest saved vs minimum-only approach in cents.
  final int? totalInterestSavedVsMinimumOnly;

  Plan copyWith({
    String? id,
    Strategy? strategy,
    int? extraMonthlyAmount,
    PaymentCadence? extraPaymentCadence,
    List<String>? customOrder,
    DateTime? lastRecastAt,
    DateTime? projectedDebtFreeDate,
    int? totalInterestProjected,
    int? totalInterestSavedVsMinimumOnly,
  }) {
    return Plan(
      id: id ?? this.id,
      strategy: strategy ?? this.strategy,
      extraMonthlyAmount: extraMonthlyAmount ?? this.extraMonthlyAmount,
      extraPaymentCadence: extraPaymentCadence ?? this.extraPaymentCadence,
      customOrder: customOrder ?? this.customOrder,
      lastRecastAt: lastRecastAt ?? this.lastRecastAt,
      projectedDebtFreeDate:
          projectedDebtFreeDate ?? this.projectedDebtFreeDate,
      totalInterestProjected:
          totalInterestProjected ?? this.totalInterestProjected,
      totalInterestSavedVsMinimumOnly:
          totalInterestSavedVsMinimumOnly ??
              this.totalInterestSavedVsMinimumOnly,
    );
  }

  @override
  List<Object?> get props => [
        id, strategy, extraMonthlyAmount, extraPaymentCadence,
        customOrder, lastRecastAt, projectedDebtFreeDate,
        totalInterestProjected, totalInterestSavedVsMinimumOnly,
      ];
}
