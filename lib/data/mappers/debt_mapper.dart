import 'package:drift/drift.dart';

import '../../domain/entities/debt.dart';
import '../local/database.dart';

/// Maps between Drift [DebtRow] and domain [Debt] entity.
///
/// Per ADR-018: Repository pattern — Drift types don't leak to domain/UI.
extension DebtRowMapper on DebtRow {
  /// Convert a Drift row to a domain [Debt] entity.
  Debt toDomain() {
    return Debt(
      id: id,
      scenarioId: scenarioId,
      name: name,
      type: type,
      originalPrincipal: originalPrincipalCents,
      currentBalance: currentBalanceCents,
      apr: apr,
      interestMethod: interestMethod,
      minimumPayment: minimumPaymentCents,
      minimumPaymentType: minimumPaymentType,
      minimumPaymentPercent: minimumPaymentPercent,
      minimumPaymentFloor: minimumPaymentFloorCents,
      paymentCadence: paymentCadence,
      dueDayOfMonth: dueDayOfMonth ?? 1,
      firstDueDate: firstDueDate,
      status: status,
      pausedUntil: pausedUntil,
      priority: priority,
      excludeFromStrategy: excludeFromStrategy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      paidOffAt: paidOffAt,
      deletedAt: deletedAt,
    );
  }
}

/// Maps from domain [Debt] to Drift [DebtsTableCompanion] for inserts/updates.
extension DebtCompanionMapper on Debt {
  /// Convert a domain [Debt] to a Drift companion for database operations.
  DebtsTableCompanion toCompanion() {
    return DebtsTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      name: Value(name),
      type: Value(type),
      originalPrincipalCents: Value(originalPrincipal),
      currentBalanceCents: Value(currentBalance),
      apr: Value(apr),
      interestMethod: Value(interestMethod),
      minimumPaymentCents: Value(minimumPayment),
      minimumPaymentType: Value(minimumPaymentType),
      minimumPaymentPercent: Value(minimumPaymentPercent),
      minimumPaymentFloorCents: Value(minimumPaymentFloor),
      paymentCadence: Value(paymentCadence),
      dueDayOfMonth: Value(dueDayOfMonth),
      firstDueDate: Value(firstDueDate),
      status: Value(status),
      pausedUntil: Value(pausedUntil),
      priority: Value(priority),
      excludeFromStrategy: Value(excludeFromStrategy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      paidOffAt: Value(paidOffAt),
      deletedAt: Value(deletedAt),
    );
  }
}
