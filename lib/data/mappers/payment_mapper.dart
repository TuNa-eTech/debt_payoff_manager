import 'package:drift/drift.dart';

import '../../domain/entities/payment.dart';
import '../local/database.dart';

/// Maps between Drift [PaymentRow] and domain [Payment] entity.
///
/// Per ADR-018: Repository pattern — Drift types don't leak to domain/UI.
extension PaymentRowMapper on PaymentRow {
  /// Convert a Drift row to a domain [Payment] entity.
  Payment toDomain() {
    return Payment(
      id: id,
      scenarioId: scenarioId,
      debtId: debtId,
      amount: amountCents,
      principalPortion: principalPortionCents,
      interestPortion: interestPortionCents,
      feePortion: feePortionCents,
      date: date,
      type: type,
      source: source,
      note: note,
      status: status,
      appliedBalanceBefore: appliedBalanceBeforeCents,
      appliedBalanceAfter: appliedBalanceAfterCents,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}

/// Maps from domain [Payment] to Drift [PaymentsTableCompanion].
extension PaymentCompanionMapper on Payment {
  PaymentsTableCompanion toCompanion() {
    return PaymentsTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      debtId: Value(debtId),
      amountCents: Value(amount),
      principalPortionCents: Value(principalPortion),
      interestPortionCents: Value(interestPortion),
      feePortionCents: Value(feePortion),
      date: Value(date),
      type: Value(type),
      source: Value(source),
      note: Value(note),
      status: Value(status),
      appliedBalanceBeforeCents: Value(appliedBalanceBefore),
      appliedBalanceAfterCents: Value(appliedBalanceAfter),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
    );
  }
}
