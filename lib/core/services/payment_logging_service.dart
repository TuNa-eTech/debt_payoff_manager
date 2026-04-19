import 'package:uuid/uuid.dart';

import '../../data/local/database.dart';
import '../../data/local/stores/sync_state_store.dart';
import '../../data/repositories/debt_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/payment_type.dart';
import '../../engine/validators.dart';
import 'plan_recast_service.dart';

/// Logs actual payments against debt balances and triggers a fresh recast.
class PaymentLoggingService {
  PaymentLoggingService({
    required AppDatabase db,
    required DebtRepositoryImpl debtRepository,
    required PaymentRepositoryImpl paymentRepository,
    required SyncStateStore syncStateStore,
    required PlanRecastService planRecastService,
  }) : _db = db,
       _debtRepository = debtRepository,
       _paymentRepository = paymentRepository,
       _syncStateStore = syncStateStore,
       _planRecastService = planRecastService;

  final AppDatabase _db;
  final DebtRepositoryImpl _debtRepository;
  final PaymentRepositoryImpl _paymentRepository;
  final SyncStateStore _syncStateStore;
  final PlanRecastService _planRecastService;
  final Uuid _uuid = const Uuid();

  Future<Payment> logPayment({
    required String debtId,
    required int amountCents,
    required PaymentType type,
    required PaymentSource source,
    DateTime? date,
    String? note,
  }) async {
    if (!_isSupportedType(type)) {
      throw ArgumentError('Only minimum, extra, and lump sum payments are supported in phase 4.');
    }
    if (amountCents <= 0) {
      throw ArgumentError('Payment amount must be greater than 0.');
    }

    final debt = await _debtRepository.getDebtById(debtId);
    if (debt == null) {
      throw ArgumentError('Debt not found.');
    }
    if (debt.status == DebtStatus.archived || debt.status == DebtStatus.paidOff) {
      throw ArgumentError('This debt can no longer accept payments.');
    }
    if (amountCents > debt.currentBalance) {
      throw ArgumentError('Payment exceeds the current balance.');
    }

    final paymentDate = _localDay(date ?? DateTime.now());
    final now = DateTime.now().toUtc();
    final newBalance = debt.currentBalance - amountCents;

    final payment = Payment(
      id: _uuid.v4(),
      scenarioId: debt.scenarioId,
      debtId: debt.id,
      amount: amountCents,
      principalPortion: amountCents,
      interestPortion: 0,
      feePortion: 0,
      date: paymentDate,
      type: type,
      source: source,
      note: note?.trim().isEmpty ?? true ? null : note?.trim(),
      status: PaymentStatus.completed,
      appliedBalanceBefore: debt.currentBalance,
      appliedBalanceAfter: newBalance,
      createdAt: now,
      updatedAt: now,
    );

    final updatedDebt = debt.copyWith(
      currentBalance: newBalance,
      status: newBalance == 0 ? DebtStatus.paidOff : debt.status,
      paidOffAt: newBalance == 0 ? now : null,
      updatedAt: now,
    );

    if (!FinancialValidators.isPaymentSplitValid(
      amount: payment.amount,
      principalPortion: payment.principalPortion,
      interestPortion: payment.interestPortion,
      feePortion: payment.feePortion,
    )) {
      throw ArgumentError('Payment split is invalid.');
    }

    await _db.transaction(() async {
      await _debtRepository.updateDebt(updatedDebt);
      await _paymentRepository.addPayment(payment);
      await _syncStateStore.markDirtyMany(const ['debts', 'payments']);
    });

    await _planRecastService.recast(scenarioId: debt.scenarioId);
    return payment;
  }

  bool _isSupportedType(PaymentType type) {
    return type == PaymentType.minimum ||
        type == PaymentType.extra ||
        type == PaymentType.lumpSum;
  }

  static DateTime _localDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
