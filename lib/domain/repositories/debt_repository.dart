import '../entities/debt.dart';

/// Abstract interface for debt data access.
///
/// Implemented by [DebtRepositoryImpl] in the data layer.
abstract class DebtRepository {
  /// Get all debts, optionally filtered by status.
  Future<List<Debt>> getAllDebts({List<String>? statusFilter});

  /// Get a single debt by ID.
  Future<Debt?> getDebtById(String id);

  /// Get only active debts.
  Future<List<Debt>> getActiveDebts();

  /// Add a new debt. Returns the created debt.
  Future<Debt> addDebt(Debt debt);

  /// Update an existing debt.
  Future<void> updateDebt(Debt debt);

  /// Delete a debt by ID.
  Future<void> deleteDebt(String id);

  /// Watch all debts as a stream (for reactive UI).
  Stream<List<Debt>> watchAllDebts();

  /// Watch active debts as a stream.
  Stream<List<Debt>> watchActiveDebts();
}
