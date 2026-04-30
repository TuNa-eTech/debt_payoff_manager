import '../../domain/entities/interest_rate_history.dart';

/// Repository interface for InterestRateHistory.
///
/// Reference: financial-engine-spec.md §3.4
///
/// Used for tracking APR changes over time (promo rates, refinancing).
abstract interface class InterestRateHistoryRepository {
  /// Watch all rate history entries for a debt.
  Stream<List<InterestRateHistory>> watchByDebtId(String debtId);

  /// Get all rate history entries for a debt.
  Future<List<InterestRateHistory>> getByDebtId(String debtId);

  /// Get a single rate history entry by ID.
  Future<InterestRateHistory?> getById(String id);

  /// Add a new rate history entry.
  Future<void> addRateHistory(InterestRateHistory rate);

  /// Update an existing rate history entry.
  Future<void> updateRateHistory(InterestRateHistory rate);

  /// Soft-delete a rate history entry.
  Future<bool> deleteRateHistory(String id);
}
