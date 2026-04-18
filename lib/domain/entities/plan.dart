import 'package:equatable/equatable.dart';

import '../enums/payment_cadence.dart';
import '../enums/strategy.dart';

/// Plan entity — represents a payoff strategy configuration.
///
/// Reference: data-schema.md §5
///
/// Singleton per scenario. Main scenario has 1 plan;
/// what-if scenarios each have 1 plan.
class Plan extends Equatable {
  const Plan({
    required this.id,
    this.scenarioId = 'main',
    required this.strategy,
    required this.extraMonthlyAmount,
    this.extraPaymentCadence = PaymentCadence.monthly,
    this.customOrder,
    this.lastRecastAt,
    this.projectedDebtFreeDate,
    this.totalInterestProjected,
    this.totalInterestSaved,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String scenarioId;
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
  final int? totalInterestSaved;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Plan copyWith({
    String? id,
    String? scenarioId,
    Strategy? strategy,
    int? extraMonthlyAmount,
    PaymentCadence? extraPaymentCadence,
    List<String>? customOrder,
    DateTime? lastRecastAt,
    DateTime? projectedDebtFreeDate,
    int? totalInterestProjected,
    int? totalInterestSaved,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Plan(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      strategy: strategy ?? this.strategy,
      extraMonthlyAmount: extraMonthlyAmount ?? this.extraMonthlyAmount,
      extraPaymentCadence: extraPaymentCadence ?? this.extraPaymentCadence,
      customOrder: customOrder ?? this.customOrder,
      lastRecastAt: lastRecastAt ?? this.lastRecastAt,
      projectedDebtFreeDate:
          projectedDebtFreeDate ?? this.projectedDebtFreeDate,
      totalInterestProjected:
          totalInterestProjected ?? this.totalInterestProjected,
      totalInterestSaved: totalInterestSaved ?? this.totalInterestSaved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, scenarioId, strategy, extraMonthlyAmount, extraPaymentCadence,
        customOrder, lastRecastAt, projectedDebtFreeDate,
        totalInterestProjected, totalInterestSaved,
        createdAt, updatedAt, deletedAt,
      ];
}
