import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

/// Concrete implementation of [PaymentRepository] using Drift (SQLite).
class PaymentRepositoryImpl implements PaymentRepository {
  @override
  Future<List<Payment>> getPaymentsForDebt(String debtId) async {
    // TODO: Implement via PaymentDao
    return [];
  }

  @override
  Future<List<Payment>> getAllPayments({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // TODO: Implement
    return [];
  }

  @override
  Future<Payment?> getPaymentById(String id) async {
    // TODO: Implement
    return null;
  }

  @override
  Future<Payment> addPayment(Payment payment) async {
    // TODO: Implement
    return payment;
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    // TODO: Implement
  }

  @override
  Future<void> deletePayment(String id) async {
    // TODO: Implement
  }

  @override
  Stream<List<Payment>> watchPaymentsForDebt(String debtId) {
    // TODO: Implement
    return const Stream.empty();
  }
}
