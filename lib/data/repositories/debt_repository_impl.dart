import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/entities/debt.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/min_payment_type.dart';
import '../../domain/repositories/debt_repository.dart';
import '../local/database.dart';
import '../mappers/debt_mapper.dart';

/// Concrete implementation of [DebtRepository] using Drift (SQLite).
///
/// Per ADR-018: Converts between Drift row classes and domain entities.
/// Per ADR-006: All queries filter deletedAt IS NULL by default.
class DebtRepositoryImpl implements DebtRepository {
  DebtRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<List<Debt>> getAllDebts({
    String scenarioId = 'main',
    List<String>? statusFilter,
  }) async {
    final query = _db.select(_db.debtsTable)
      ..where((d) => d.scenarioId.equals(scenarioId))
      ..where((d) => d.deletedAt.isNull());

    if (statusFilter != null && statusFilter.isNotEmpty) {
      query.where((d) => d.status.isIn(statusFilter));
    }

    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Debt?> getDebtById(String id) async {
    final query = _db.select(_db.debtsTable)
      ..where((d) => d.id.equals(id))
      ..where((d) => d.deletedAt.isNull());

    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Stream<Debt?> watchDebtById(String id) {
    final query = _db.select(_db.debtsTable)
      ..where((d) => d.id.equals(id))
      ..where((d) => d.deletedAt.isNull());

    return query.watchSingleOrNull().map((row) => row?.toDomain());
  }

  @override
  Future<List<Debt>> getActiveDebts({String scenarioId = 'main'}) {
    return getAllDebts(
      scenarioId: scenarioId,
      statusFilter: [DebtStatus.active.name],
    );
  }

  @override
  Future<Debt> addDebt(Debt debt) async {
    _validateInvariants(debt);
    await _db.into(_db.debtsTable).insert(debt.toCompanion());
    return debt;
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    _validateInvariants(debt);
    final updated = debt.copyWith(updatedAt: DateTime.now().toUtc());
    await (_db.update(_db.debtsTable)
          ..where((d) => d.id.equals(debt.id)))
        .write(updated.toCompanion());
  }

  @override
  Future<void> deleteDebt(String id) async {
    // Soft delete: set deletedAt, per ADR-006
    final now = DateTime.now().toUtc();
    await (_db.update(_db.debtsTable)..where((d) => d.id.equals(id)))
        .write(DebtsTableCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  @override
  Future<void> restoreDebt(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.debtsTable)..where((d) => d.id.equals(id)))
        .write(DebtsTableCompanion(
      deletedAt: const Value(null),
      updatedAt: Value(now),
    ));
  }

  @override
  Stream<List<Debt>> watchAllDebts({String scenarioId = 'main'}) {
    final query = _db.select(_db.debtsTable)
      ..where((d) => d.scenarioId.equals(scenarioId))
      ..where((d) => d.deletedAt.isNull());

    return query.watch().map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  @override
  Stream<List<Debt>> watchActiveDebts({String scenarioId = 'main'}) {
    final query = _db.select(_db.debtsTable)
      ..where((d) => d.scenarioId.equals(scenarioId))
      ..where((d) => d.status.equals(DebtStatus.active.name))
      ..where((d) => d.deletedAt.isNull());

    return query.watch().map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  /// Validate repository-level invariants before write.
  ///
  /// Per data-schema.md §12 — Repository-level constraints.
  void _validateInvariants(Debt debt) {
    if (debt.apr < Decimal.zero || debt.apr > Decimal.one) {
      throw ArgumentError('APR must be between 0 and 1 (0%–100%)');
    }

    if (debt.minimumPaymentType == MinPaymentType.percentOfBalance &&
        debt.minimumPaymentPercent == null) {
      throw ArgumentError(
        'minimumPaymentPercent required for percentOfBalance type',
      );
    }

    if (debt.minimumPaymentType == MinPaymentType.interestPlusPercent &&
        debt.minimumPaymentPercent == null) {
      throw ArgumentError(
        'minimumPaymentPercent required for interestPlusPercent type',
      );
    }

    if (debt.status == DebtStatus.paused && debt.pausedUntil == null) {
      throw ArgumentError('pausedUntil required when status is paused');
    }
  }
}
