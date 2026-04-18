import '../entities/payment.dart';

/// Abstract interface for payment data access.
abstract class PaymentRepository {
  /// Get all payments for a specific debt (non-deleted).
  Future<List<Payment>> getPaymentsForDebt(String debtId);

  /// Get all payments, optionally filtered by date range.
  Future<List<Payment>> getAllPayments({
    String scenarioId = 'main',
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get payments for a specific month (YYYY-MM).
  Future<List<Payment>> getPaymentsForMonth(
    String yearMonth, {
    String scenarioId = 'main',
  });

  /// Get a single payment by ID.
  Future<Payment?> getPaymentById(String id);

  /// Add a new payment.
  Future<Payment> addPayment(Payment payment);

  /// Update an existing payment.
  Future<void> updatePayment(Payment payment);

  /// Soft delete a payment by ID.
  Future<void> deletePayment(String id);

  /// Watch payments for a debt as a stream.
  Stream<List<Payment>> watchPaymentsForDebt(String debtId);

  /// Watch all payments for a scenario as a stream.
  Stream<List<Payment>> watchAllPayments({String scenarioId = 'main'});
}
