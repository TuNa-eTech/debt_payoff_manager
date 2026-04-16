import 'package:equatable/equatable.dart';

import '../enums/payment_type.dart';

/// Payment entity — records actual or planned payments.
///
/// Reference: financial-engine-spec.md §3.2
///
/// **Invariant:** `amount == principalPortion + interestPortion + feePortion`
class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.principalPortion,
    required this.interestPortion,
    this.feePortion = 0,
    required this.date,
    required this.type,
    required this.source,
    this.note,
    required this.status,
    required this.appliedBalanceBefore,
    required this.appliedBalanceAfter,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(amount == principalPortion + interestPortion + feePortion,
            'Payment split must equal total amount');

  final String id;
  final String debtId;

  /// Total payment in cents (> 0).
  final int amount;

  /// Principal portion in cents.
  final int principalPortion;

  /// Interest portion in cents.
  final int interestPortion;

  /// Fee portion in cents (late fee, etc.).
  final int feePortion;

  /// Date payment was applied.
  final DateTime date;

  final PaymentType type;
  final PaymentSource source;

  /// User note (max 200 chars).
  final String? note;

  final PaymentStatus status;

  /// Balance snapshot before payment — for audit trail.
  final int appliedBalanceBefore;

  /// Balance snapshot after payment.
  final int appliedBalanceAfter;

  final DateTime createdAt;
  final DateTime updatedAt;

  Payment copyWith({
    String? id,
    String? debtId,
    int? amount,
    int? principalPortion,
    int? interestPortion,
    int? feePortion,
    DateTime? date,
    PaymentType? type,
    PaymentSource? source,
    String? note,
    PaymentStatus? status,
    int? appliedBalanceBefore,
    int? appliedBalanceAfter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      principalPortion: principalPortion ?? this.principalPortion,
      interestPortion: interestPortion ?? this.interestPortion,
      feePortion: feePortion ?? this.feePortion,
      date: date ?? this.date,
      type: type ?? this.type,
      source: source ?? this.source,
      note: note ?? this.note,
      status: status ?? this.status,
      appliedBalanceBefore: appliedBalanceBefore ?? this.appliedBalanceBefore,
      appliedBalanceAfter: appliedBalanceAfter ?? this.appliedBalanceAfter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, debtId, amount, principalPortion, interestPortion, feePortion,
        date, type, source, note, status,
        appliedBalanceBefore, appliedBalanceAfter, createdAt, updatedAt,
      ];
}
