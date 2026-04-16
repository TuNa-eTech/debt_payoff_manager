import '../../domain/entities/payment.dart';
import '../../domain/enums/payment_type.dart';

/// Maps between Drift table data and domain [Payment] entity.
class PaymentMapper {
  PaymentMapper._();

  static Payment fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      debtId: map['debtId'] as String,
      amount: map['amount'] as int,
      principalPortion: map['principalPortion'] as int,
      interestPortion: map['interestPortion'] as int,
      feePortion: (map['feePortion'] as int?) ?? 0,
      date: DateTime.parse(map['date'] as String),
      type: PaymentType.values.byName(map['type'] as String),
      source: PaymentSource.values.byName(map['source'] as String),
      note: map['note'] as String?,
      status: PaymentStatus.values.byName(map['status'] as String),
      appliedBalanceBefore: map['appliedBalanceBefore'] as int,
      appliedBalanceAfter: map['appliedBalanceAfter'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  static Map<String, dynamic> toMap(Payment payment) {
    return {
      'id': payment.id,
      'debtId': payment.debtId,
      'amount': payment.amount,
      'principalPortion': payment.principalPortion,
      'interestPortion': payment.interestPortion,
      'feePortion': payment.feePortion,
      'date': payment.date.toIso8601String(),
      'type': payment.type.name,
      'source': payment.source.name,
      'note': payment.note,
      'status': payment.status.name,
      'appliedBalanceBefore': payment.appliedBalanceBefore,
      'appliedBalanceAfter': payment.appliedBalanceAfter,
      'createdAt': payment.createdAt.toIso8601String(),
      'updatedAt': payment.updatedAt.toIso8601String(),
    };
  }
}
