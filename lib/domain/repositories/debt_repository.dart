import '../entities/debt.dart';

/// Abstract interface for debt data access.
///
/// Implemented by [DebtRepositoryImpl] in the data layer.
/// Per ADR-018: Domain layer defines interface, data layer implements.
abstract class DebtRepository {
  /// Get all debts, optionally filtered by status.
  /// Only returns non-deleted debts by default.
  Future<List<Debt>> getAllDebts({
    String scenarioId = 'main',
    List<String>? statusFilter,
  });

  /// Get a single debt by ID.
  Future<Debt?> getDebtById(String id);

  /// Watch a single debt by ID.
  ///
  /// Emits `null` when the debt is soft-deleted or not found.
  Stream<Debt?> watchDebtById(String id);

  /// Get only active debts for a scenario.
  Future<List<Debt>> getActiveDebts({String scenarioId = 'main'});

  /// Add a new debt. Returns the created debt.
  Future<Debt> addDebt(Debt debt);

  /// Update an existing debt.
  Future<void> updateDebt(Debt debt);

  /// Soft delete a debt (sets deletedAt). Per ADR-006.
  Future<void> deleteDebt(String id);

  /// Restore a soft-deleted debt.
  Future<void> restoreDebt(String id);

  /// Watch all non-deleted debts as a stream (for reactive UI).
  Stream<List<Debt>> watchAllDebts({String scenarioId = 'main'});

  /// Watch active debts as a stream.
  Stream<List<Debt>> watchActiveDebts({String scenarioId = 'main'});
}
