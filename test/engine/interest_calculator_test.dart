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

    test('compoundDaily uses effective monthly rate', () {
      final interest = InterestCalculator.computeMonthlyInterest(
        balanceCents: 100000,
        apr: Decimal.parse('0.12'),
        method: InterestMethod.compoundDaily,
        daysInMonth: 31,
      );

      expect(interest, closeTo(1020, 10));
    });

    test('compoundMonthly matches simple monthly per-month calculation', () {
      final compoundMonthly = InterestCalculator.computeMonthlyInterest(
        balanceCents: 250000,
        apr: Decimal.parse('0.18'),
        method: InterestMethod.compoundMonthly,
      );
      final simpleMonthly = InterestCalculator.computeMonthlyInterest(
        balanceCents: 250000,
        apr: Decimal.parse('0.18'),
        method: InterestMethod.simpleMonthly,
      );

      expect(compoundMonthly, simpleMonthly);
    });

    test('dailyRate respects custom daysInYear', () {
      final apr = Decimal.parse('0.18');
      final rate = InterestCalculator.dailyRate(apr, daysInYear: 360);

      expect(rate.toDouble(), closeTo(0.0005, 0.00001));
    });

    test('computeApy derives annual yield from APR', () {
      final apy = InterestCalculator.computeApy(Decimal.parse('0.12'));

      expect(apy.toDouble(), closeTo(0.1268, 0.0001));
    });
  });
}
