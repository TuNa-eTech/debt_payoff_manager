import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/engine/amortization.dart';

void main() {
  group('Amortization', () {
    group('computeFixedPayment', () {
      test('TV-1: Standard amortization - 10k, 6%, 60 months', () {
        /// Test Vector 1 from financial-engine-spec.md §12
        ///
        /// Input:
        ///   Principal = $10,000 (1000000 cents)
        ///   APR = 6%
        ///   Term = 60 months
        ///
        /// Expected: Monthly payment = $193.33 = 19333 cents
        final payment = Amortization.computeFixedPayment(
          principalCents: 1000000,
          apr: Decimal.parse('0.06'),
          termMonths: 60,
        );
        expect(payment, closeTo(19333, 1));
      });

      test('zero interest divides evenly', () {
        final payment = Amortization.computeFixedPayment(
          principalCents: 12000, // $120.00
          apr: Decimal.zero,
          termMonths: 12,
        );
        expect(payment, 1000); // $10 per month
      });
    });

    group('computeRemainingMonths', () {
      test('returns 0 for zero balance', () {
        final months = Amortization.computeRemainingMonths(
          balanceCents: 0,
          apr: Decimal.parse('0.06'),
          paymentCents: 19333,
        );
        expect(months, 0);
      });

      test('returns null when payment <= interest (infinite)', () {
        // $10,000 at 20%, minimum $50/month
        // Monthly interest = 10000 * 0.20/12 = $166.67
        // Payment $50 < interest → never pays off
        final months = Amortization.computeRemainingMonths(
          balanceCents: 1000000,
          apr: Decimal.parse('0.20'),
          paymentCents: 5000,
        );
        expect(months, isNull);
      });
    });

    group('computePaymentSplit', () {
      test('splits payment into principal and interest', () {
        // $10,000 at 6%, payment $193.33
        final split = Amortization.computePaymentSplit(
          balanceCents: 1000000,
          apr: Decimal.parse('0.06'),
          paymentCents: 19333,
        );
        // Interest = 10000 * 0.005 = $50 = 5000 cents
        expect(split.interest, 5000);
        // Principal = 19333 - 5000 = 14333 cents
        expect(split.principal, 14333);
      });
    });
  });
}
