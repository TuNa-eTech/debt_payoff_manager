import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/engine/payment_allocator.dart';

void main() {
  group('PaymentAllocator', () {
    test('allocates extra to first priority debt', () {
      final allocations = PaymentAllocator.allocateExtra(
        sortedDebtBalances: [5000, 100000, 200000],
        extraPool: 10000,
      );

      expect(allocations[0], 5000); // pays off first debt
      expect(allocations[1], 5000); // remaining to second
      expect(allocations.containsKey(2), false);
    });

    test('rollover: paid off debt min + extra flows to next', () {
      final rollover = PaymentAllocator.computeRollover(
        minimumPayment: 2500,
        extraAllocated: 2583,
      );
      // Per TV-4: A's $25 min + $25.83 extra = $50.83 should rollover
      expect(rollover, 5083);
    });

    test('handles zero extra pool', () {
      final allocations = PaymentAllocator.allocateExtra(
        sortedDebtBalances: [10000, 20000],
        extraPool: 0,
      );
      expect(allocations.isEmpty, true);
    });

    test('TV-4: Rollover within month', () {
      /// Test Vector 4 from spec §12
      /// Debt A: balance $25.83 after min, Debt B: balance $982.50 after min
      /// Extra: $100

      final allocations = PaymentAllocator.allocateExtra(
        sortedDebtBalances: [2583, 98250], // cents after minimum payments
        extraPool: 10000, // $100 in cents
      );

      // A gets $25.83 (paid off), remaining $74.17 to B
      expect(allocations[0], 2583);
      expect(allocations[1], 7417);
    });
  });
}
