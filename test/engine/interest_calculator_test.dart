import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/engine/interest_calculator.dart';
import 'package:debt_payoff_manager/domain/enums/interest_method.dart';

void main() {
  group('InterestCalculator', () {
    test('monthlyRate divides APR by 12', () {
      final apr = Decimal.parse('0.06'); // 6%
      final rate = InterestCalculator.monthlyRate(apr);
      expect(rate, Decimal.parse('0.005'));
    });

    test('dailyRate divides APR by 365', () {
      final apr = Decimal.parse('0.1899');
      final rate = InterestCalculator.dailyRate(apr);
      // 0.1899 / 365 ≈ 0.0005202...
      expect(rate.toDouble(), closeTo(0.0005202, 0.0001));
    });

    test('simpleMonthly interest calculation', () {
      // balance $1,000, APR 6%
      // Expected: 1000 * 0.005 = $5.00 = 500 cents
      final interest = InterestCalculator.computeMonthlyInterest(
        balanceCents: 100000,
        apr: Decimal.parse('0.06'),
        method: InterestMethod.simpleMonthly,
      );
      expect(interest, 500);
    });

    test('zero APR returns zero interest', () {
      final interest = InterestCalculator.computeMonthlyInterest(
        balanceCents: 100000,
        apr: Decimal.zero,
        method: InterestMethod.simpleMonthly,
      );
      expect(interest, 0);
    });

    test('zero balance returns zero interest', () {
      final interest = InterestCalculator.computeMonthlyInterest(
        balanceCents: 0,
        apr: Decimal.parse('0.1899'),
        method: InterestMethod.simpleMonthly,
      );
      expect(interest, 0);
    });
  });
}
