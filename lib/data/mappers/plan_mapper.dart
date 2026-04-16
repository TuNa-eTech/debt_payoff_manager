import 'dart:convert';

import '../../domain/entities/plan.dart';
import '../../domain/enums/payment_cadence.dart';
import '../../domain/enums/strategy.dart';

/// Maps between Drift table data and domain [Plan] entity.
class PlanMapper {
  PlanMapper._();

  static Plan fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'] as String,
      strategy: Strategy.values.byName(map['strategy'] as String),
      extraMonthlyAmount: map['extraMonthlyAmount'] as int,
      extraPaymentCadence: PaymentCadence.values
          .byName(map['extraPaymentCadence'] as String),
      customOrder: map['customOrder'] != null
          ? List<String>.from(jsonDecode(map['customOrder'] as String))
          : null,
      lastRecastAt: map['lastRecastAt'] != null
          ? DateTime.parse(map['lastRecastAt'] as String)
          : null,
      projectedDebtFreeDate: map['projectedDebtFreeDate'] != null
          ? DateTime.parse(map['projectedDebtFreeDate'] as String)
          : null,
      totalInterestProjected: map['totalInterestProjected'] as int?,
      totalInterestSavedVsMinimumOnly:
          map['totalInterestSavedVsMinimumOnly'] as int?,
    );
  }

  static Map<String, dynamic> toMap(Plan plan) {
    return {
      'id': plan.id,
      'strategy': plan.strategy.name,
      'extraMonthlyAmount': plan.extraMonthlyAmount,
      'extraPaymentCadence': plan.extraPaymentCadence.name,
      'customOrder':
          plan.customOrder != null ? jsonEncode(plan.customOrder) : null,
      'lastRecastAt': plan.lastRecastAt?.toIso8601String(),
      'projectedDebtFreeDate':
          plan.projectedDebtFreeDate?.toIso8601String(),
      'totalInterestProjected': plan.totalInterestProjected,
      'totalInterestSavedVsMinimumOnly':
          plan.totalInterestSavedVsMinimumOnly,
    };
  }
}
