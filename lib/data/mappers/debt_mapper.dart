import 'package:decimal/decimal.dart';

import '../../domain/entities/debt.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/debt_type.dart';
import '../../domain/enums/interest_method.dart';
import '../../domain/enums/min_payment_type.dart';
import '../../domain/enums/payment_cadence.dart';

/// Maps between Drift table data and domain [Debt] entity.
///
/// Isolates DB schema from domain model.
class DebtMapper {
  DebtMapper._();

  /// Convert a database row map to a [Debt] entity.
  static Debt fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as String,
      name: map['name'] as String,
      type: DebtType.values.byName(map['type'] as String),
      originalPrincipal: map['originalPrincipal'] as int,
      currentBalance: map['currentBalance'] as int,
      apr: Decimal.parse(map['apr'] as String),
      interestMethod:
          InterestMethod.values.byName(map['interestMethod'] as String),
      minimumPayment: map['minimumPayment'] as int,
      minimumPaymentType:
          MinPaymentType.values.byName(map['minimumPaymentType'] as String),
      minimumPaymentPercent: map['minimumPaymentPercent'] != null
          ? Decimal.parse(map['minimumPaymentPercent'] as String)
          : null,
      minimumPaymentFloor: map['minimumPaymentFloor'] as int?,
      paymentCadence:
          PaymentCadence.values.byName(map['paymentCadence'] as String),
      dueDayOfMonth: map['dueDayOfMonth'] as int,
      firstDueDate: DateTime.parse(map['firstDueDate'] as String),
      status: DebtStatus.values.byName(map['status'] as String),
      pausedUntil: map['pausedUntil'] != null
          ? DateTime.parse(map['pausedUntil'] as String)
          : null,
      priority: map['priority'] as int?,
      excludeFromStrategy: (map['excludeFromStrategy'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      paidOffAt: map['paidOffAt'] != null
          ? DateTime.parse(map['paidOffAt'] as String)
          : null,
    );
  }

  /// Convert a [Debt] entity to a database row map.
  static Map<String, dynamic> toMap(Debt debt) {
    return {
      'id': debt.id,
      'name': debt.name,
      'type': debt.type.name,
      'originalPrincipal': debt.originalPrincipal,
      'currentBalance': debt.currentBalance,
      'apr': debt.apr.toString(),
      'interestMethod': debt.interestMethod.name,
      'minimumPayment': debt.minimumPayment,
      'minimumPaymentType': debt.minimumPaymentType.name,
      'minimumPaymentPercent': debt.minimumPaymentPercent?.toString(),
      'minimumPaymentFloor': debt.minimumPaymentFloor,
      'paymentCadence': debt.paymentCadence.name,
      'dueDayOfMonth': debt.dueDayOfMonth,
      'firstDueDate': debt.firstDueDate.toIso8601String(),
      'status': debt.status.name,
      'pausedUntil': debt.pausedUntil?.toIso8601String(),
      'priority': debt.priority,
      'excludeFromStrategy': debt.excludeFromStrategy ? 1 : 0,
      'createdAt': debt.createdAt.toIso8601String(),
      'updatedAt': debt.updatedAt.toIso8601String(),
      'paidOffAt': debt.paidOffAt?.toIso8601String(),
    };
  }
}
