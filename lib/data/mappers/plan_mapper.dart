import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/plan.dart';
import '../local/database.dart';

/// Maps between Drift [PlanRow] and domain [Plan] entity.
///
/// Per ADR-018: Repository pattern — Drift types don't leak to domain/UI.
extension PlanRowMapper on PlanRow {
  /// Convert a Drift row to a domain [Plan] entity.
  Plan toDomain() {
    return Plan(
      id: id,
      scenarioId: scenarioId,
      strategy: strategy,
      extraMonthlyAmount: extraMonthlyAmountCents,
      extraPaymentCadence: extraPaymentCadence,
      customOrder: customOrderJson != null
          ? List<String>.from(jsonDecode(customOrderJson!))
          : null,
      lastRecastAt: lastRecastAt,
      projectedDebtFreeDate: projectedDebtFreeDate,
      totalInterestProjected: totalInterestProjectedCents,
      totalInterestSaved: totalInterestSavedCents,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}

/// Maps from domain [Plan] to Drift [PlansTableCompanion].
extension PlanCompanionMapper on Plan {
  PlansTableCompanion toCompanion() {
    return PlansTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      strategy: Value(strategy),
      extraMonthlyAmountCents: Value(extraMonthlyAmount),
      extraPaymentCadence: Value(extraPaymentCadence),
      customOrderJson: Value(
        customOrder != null ? jsonEncode(customOrder) : null,
      ),
      lastRecastAt: Value(lastRecastAt ?? DateTime.now().toUtc()),
      projectedDebtFreeDate: Value(projectedDebtFreeDate),
      totalInterestProjectedCents: Value(totalInterestProjected),
      totalInterestSavedCents: Value(totalInterestSaved),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
    );
  }
}
