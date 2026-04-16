import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/engine/min_payment_calculator.dart';
import 'package:debt_payoff_manager/domain/enums/min_payment_type.dart';

void main() {
  group('MinPaymentCalculator', () {
    test('fixed: returns fixed amount', () {
      final result = MinPaymentCalculator.compute(
        balanceCents: 500000,
        interestCents: 8329,
        type: MinPaymentType.fixed,
        fixedAmountCents: 5000, // $50
      );
      expect(result, 5000);
    });

    test('percentOfBalance: returns max(balance * pct, floor)', () {
      // $5000 * 2% = $100, floor $25
      final result = MinPaymentCalculator.compute(
        balanceCents: 500000,
        interestCents: 8329,
        type: MinPaymentType.percentOfBalance,
        fixedAmountCents: 0,
        percent: Decimal.parse('0.02'),
        floorCents: 2500,
      );
      expect(result, 10000); // $100
    });

    test('percentOfBalance: uses floor when pct is smaller', () {
      // $100 * 2% = $2, floor $25
      final result = MinPaymentCalculator.compute(
        balanceCents: 10000,
        interestCents: 166,
        type: MinPaymentType.percentOfBalance,
        fixedAmountCents: 0,
        percent: Decimal.parse('0.02'),
        floorCents: 2500,
      );
      expect(result, 2500); // $25 floor
    });

    test('interestPlusPercent: returns max(interest + balance * pct, floor)', () {
      // interest $83.29 + $5000 * 1% = $83.29 + $50 = $133.29, floor $25
      final result = MinPaymentCalculator.compute(
        balanceCents: 500000,
        interestCents: 8329,
        type: MinPaymentType.interestPlusPercent,
        fixedAmountCents: 0,
        percent: Decimal.parse('0.01'),
        floorCents: 2500,
      );
      expect(result, 13329); // $133.29
    });

    test('never exceeds balance + interest', () {
      // Balance $10, fixed min $50 → should cap at $10
      final result = MinPaymentCalculator.compute(
        balanceCents: 1000,
        interestCents: 10,
        type: MinPaymentType.fixed,
        fixedAmountCents: 5000,
      );
      expect(result, 1010); // balance + interest
    });

    test('returns 0 for zero balance', () {
      final result = MinPaymentCalculator.compute(
        balanceCents: 0,
        interestCents: 0,
        type: MinPaymentType.fixed,
        fixedAmountCents: 5000,
      );
      expect(result, 0);
    });
  });
}
