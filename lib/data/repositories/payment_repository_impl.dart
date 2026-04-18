import 'package:drift/drift.dart';

import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../local/database.dart';
import '../mappers/payment_mapper.dart';

/// Concrete implementation of [PaymentRepository] using Drift (SQLite).
class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<List<Payment>> getPaymentsForDebt(String debtId) async {
    final query = _db.select(_db.paymentsTable)
      ..where((p) => p.debtId.equals(debtId))
      ..where((p) => p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.date)]);

    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<List<Payment>> getAllPayments({
    String scenarioId = 'main',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final query = _db.select(_db.paymentsTable)
      ..where((p) => p.scenarioId.equals(scenarioId))
      ..where((p) => p.deletedAt.isNull());

    // Date filtering uses the LocalDateConverter string format YYYY-MM-DD
    if (fromDate != null) {
      final fromStr = fromDate.toIso8601String().substring(0, 10);
      query.where(
        (p) => p.date.isBiggerOrEqualValue(fromStr),
      );
    }
    if (toDate != null) {
      final toStr = toDate.toIso8601String().substring(0, 10);
      query.where(
        (p) => p.date.isSmallerOrEqualValue(toStr),
      );
    }

    query.orderBy([(p) => OrderingTerm.desc(p.date)]);

    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<List<Payment>> getPaymentsForMonth(
    String yearMonth, {
    String scenarioId = 'main',
  }) async {
    // yearMonth format: "2026-04"
    final startDate = '$yearMonth-01';
    // Use string comparison for the month range
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endDate =
        '${nextYear.toString().padLeft(4, '0')}-${nextMonth.toString().padLeft(2, '0')}-01';

    final query = _db.select(_db.paymentsTable)
      ..where((p) => p.scenarioId.equals(scenarioId))
      ..where((p) => p.deletedAt.isNull())
      ..where(
        (p) => p.date.isBiggerOrEqualValue(startDate),
      )
      ..where((p) => p.date.isSmallerThanValue(endDate))
      ..orderBy([(p) => OrderingTerm.asc(p.date)]);

    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Payment?> getPaymentById(String id) async {
    final query = _db.select(_db.paymentsTable)
      ..where((p) => p.id.equals(id))
      ..where((p) => p.deletedAt.isNull());

    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<Payment> addPayment(Payment payment) async {
    _validatePaymentSplit(payment);
    await _db.into(_db.paymentsTable).insert(payment.toCompanion());
    return payment;
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    _validatePaymentSplit(payment);
    final updated = payment.copyWith(updatedAt: DateTime.now().toUtc());
    await (_db.update(_db.paymentsTable)
          ..where((p) => p.id.equals(payment.id)))
        .write(updated.toCompanion());
  }

  @override
  Future<void> deletePayment(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.paymentsTable)..where((p) => p.id.equals(id)))
        .write(PaymentsTableCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  @override
  Stream<List<Payment>> watchPaymentsForDebt(String debtId) {
    final query = _db.select(_db.paymentsTable)
      ..where((p) => p.debtId.equals(debtId))
      ..where((p) => p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.date)]);

    return query.watch().map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  @override
  Stream<List<Payment>> watchAllPayments({String scenarioId = 'main'}) {
    final query = _db.select(_db.paymentsTable)
      ..where((p) => p.scenarioId.equals(scenarioId))
      ..where((p) => p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.date)]);

    return query.watch().map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  /// Validate payment split invariant:
  /// amount == principalPortion + interestPortion + feePortion
  void _validatePaymentSplit(Payment payment) {
    final sum =
        payment.principalPortion +
        payment.interestPortion +
        payment.feePortion;
    if (payment.amount != sum) {
      throw ArgumentError(
        'Payment split must equal total: '
        '${payment.amount} != $sum '
        '(principal: ${payment.principalPortion}, '
        'interest: ${payment.interestPortion}, '
        'fee: ${payment.feePortion})',
      );
    }
  }
}
