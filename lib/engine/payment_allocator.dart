import 'dart:math';

/// Extra payment allocation and rollover logic.
///
/// Reference: financial-engine-spec.md §8
///
/// Key insight from §8.1: "khi 1 debt trả xong giữa tháng, minimum + extra
/// của nó rollover sang debt tiếp theo **cùng tháng đó**"
///
/// This is the feature "5/6 competitor làm sai hoặc làm thiếu."
class PaymentAllocator {
  PaymentAllocator._();

  /// Allocate extra payment across sorted debts with rollover.
  ///
  /// Per §8.1 algorithm:
  /// 1. Pay minimum on all active debts
  /// 2. Apply extra to priority debt
  /// 3. If debt paid off and remaining extra > 0, rollover to next
  ///
  /// [sortedDebtBalances] - balances after minimum payments, in priority order.
  /// [extraPool] - total extra amount available in cents.
  ///
  /// Returns a map of debt index → extra payment applied (cents).
  static Map<int, int> allocateExtra({
    required List<int> sortedDebtBalances,
    required int extraPool,
  }) {
    final allocations = <int, int>{};
    var remaining = extraPool;

    for (var i = 0; i < sortedDebtBalances.length; i++) {
      if (remaining <= 0) break;

      final balance = sortedDebtBalances[i];
      if (balance <= 0) continue;

      final applied = min(remaining, balance);
      allocations[i] = applied;
      remaining -= applied;
    }

    return allocations;
  }

  /// Calculate rollover amount when a debt is paid off.
  ///
  /// Per §8.2: When debt A paid off at month k:
  /// available_from_A = A.minimumPayment + (extra already allocated to A)
  ///
  /// This amount adds to the pool for the next priority debt.
  static int computeRollover({
    required int minimumPayment,
    required int extraAllocated,
  }) {
    return minimumPayment + extraAllocated;
  }
}
