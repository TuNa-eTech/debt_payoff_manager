import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import '../enums/debt_status.dart';
import '../enums/debt_type.dart';
import '../enums/interest_method.dart';
import '../enums/min_payment_type.dart';
import '../enums/payment_cadence.dart';

/// Debt entity — core domain object.
///
/// Reference: financial-engine-spec.md §3.1
///
/// **Money values stored as integer cents.**
/// APR stored as Decimal (0.1899 = 18.99%).
class Debt extends Equatable {
  const Debt({
    required this.id,
    required this.name,
    required this.type,
    required this.originalPrincipal,
    required this.currentBalance,
    required this.apr,
    required this.interestMethod,
    required this.minimumPayment,
    required this.minimumPaymentType,
    this.minimumPaymentPercent,
    this.minimumPaymentFloor,
    required this.paymentCadence,
    required this.dueDayOfMonth,
    required this.firstDueDate,
    required this.status,
    this.pausedUntil,
    this.priority,
    this.excludeFromStrategy = false,
    required this.createdAt,
    required this.updatedAt,
    this.paidOffAt,
  });

  final String id;
  final String name;
  final DebtType type;

  /// Original principal in cents (> 0).
  final int originalPrincipal;

  /// Current balance in cents (>= 0).
  final int currentBalance;

  /// APR as Decimal: 0.1899 = 18.99%. Scale 10.
  final Decimal apr;

  final InterestMethod interestMethod;

  /// Minimum payment in cents (>= 0).
  final int minimumPayment;

  final MinPaymentType minimumPaymentType;

  /// For percentOfBalance or interestPlusPercent types.
  final Decimal? minimumPaymentPercent;

  /// Floor for min payment in cents (e.g., $25 = 2500).
  final int? minimumPaymentFloor;

  final PaymentCadence paymentCadence;

  /// Day of month payment is due (1-31).
  final int dueDayOfMonth;

  final DateTime firstDueDate;
  final DebtStatus status;

  /// For forbearance — resume date.
  final DateTime? pausedUntil;

  /// Manual priority override for custom strategy ordering.
  final int? priority;

  /// If true, excluded from strategy allocation.
  final bool excludeFromStrategy;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidOffAt;

  /// Check if this debt is currently paused.
  bool isPaused(DateTime currentDate) {
    if (status != DebtStatus.paused) return false;
    if (pausedUntil == null) return true;
    return currentDate.isBefore(pausedUntil!);
  }

  /// Create a copy with updated fields.
  Debt copyWith({
    String? id,
    String? name,
    DebtType? type,
    int? originalPrincipal,
    int? currentBalance,
    Decimal? apr,
    InterestMethod? interestMethod,
    int? minimumPayment,
    MinPaymentType? minimumPaymentType,
    Decimal? minimumPaymentPercent,
    int? minimumPaymentFloor,
    PaymentCadence? paymentCadence,
    int? dueDayOfMonth,
    DateTime? firstDueDate,
    DebtStatus? status,
    DateTime? pausedUntil,
    int? priority,
    bool? excludeFromStrategy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidOffAt,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      originalPrincipal: originalPrincipal ?? this.originalPrincipal,
      currentBalance: currentBalance ?? this.currentBalance,
      apr: apr ?? this.apr,
      interestMethod: interestMethod ?? this.interestMethod,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      minimumPaymentType: minimumPaymentType ?? this.minimumPaymentType,
      minimumPaymentPercent:
          minimumPaymentPercent ?? this.minimumPaymentPercent,
      minimumPaymentFloor: minimumPaymentFloor ?? this.minimumPaymentFloor,
      paymentCadence: paymentCadence ?? this.paymentCadence,
      dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
      firstDueDate: firstDueDate ?? this.firstDueDate,
      status: status ?? this.status,
      pausedUntil: pausedUntil ?? this.pausedUntil,
      priority: priority ?? this.priority,
      excludeFromStrategy: excludeFromStrategy ?? this.excludeFromStrategy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidOffAt: paidOffAt ?? this.paidOffAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        originalPrincipal,
        currentBalance,
        apr,
        interestMethod,
        minimumPayment,
        minimumPaymentType,
        minimumPaymentPercent,
        minimumPaymentFloor,
        paymentCadence,
        dueDayOfMonth,
        firstDueDate,
        status,
        pausedUntil,
        priority,
        excludeFromStrategy,
        createdAt,
        updatedAt,
        paidOffAt,
      ];
}
