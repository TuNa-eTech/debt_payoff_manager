import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Tracks APR changes over time for a debt.
///
/// Reference: financial-engine-spec.md §3.4
///
/// Used for promo rates, refinancing, and variable rate scenarios.
/// When computing timeline, use the APR where
/// `effectiveFrom <= month <= effectiveTo`.
class InterestRateHistory extends Equatable {
  const InterestRateHistory({
    required this.id,
    required this.debtId,
    required this.apr,
    required this.effectiveFrom,
    this.effectiveTo,
    this.reason,
  });

  final String id;
  final String debtId;

  /// APR as Decimal (0.2499 = 24.99%).
  final Decimal apr;

  final DateTime effectiveFrom;

  /// Null means currently active.
  final DateTime? effectiveTo;

  /// Reason for change (e.g., "promo expired", "refinance").
  final String? reason;

  /// Check if this rate is active for a given date.
  bool isActiveAt(DateTime date) {
    if (date.isBefore(effectiveFrom)) return false;
    if (effectiveTo == null) return true;
    return !date.isAfter(effectiveTo!);
  }

  @override
  List<Object?> get props =>
      [id, debtId, apr, effectiveFrom, effectiveTo, reason];
}
