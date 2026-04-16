import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/payment.dart';
import '../../../domain/repositories/payment_repository.dart';
import 'payments_state.dart';

/// Cubit managing payment logging and history.
///
/// Feature 1.4: Payment Logging
class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit({required PaymentRepository paymentRepository})
      : _paymentRepository = paymentRepository,
        super(const PaymentsInitial());

  final PaymentRepository _paymentRepository;

  /// Load payment history for a specific debt.
  Future<void> loadPayments(String debtId) async {
    emit(const PaymentsLoading());
    try {
      final payments = await _paymentRepository.getPaymentsForDebt(debtId);
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  /// Log a new payment.
  ///
  /// Per feature spec: "Sau khi log → số dư tự cập nhật → timeline tự recast"
  Future<void> logPayment(Payment payment) async {
    emit(const PaymentSubmitting());
    try {
      await _paymentRepository.addPayment(payment);
      emit(const PaymentSubmitted());
      // TODO: Trigger debt balance update + timeline recast
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }
}
