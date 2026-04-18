import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/engine/validators.dart';

void main() {
  group('FinancialValidators', () {
    test('detects overgrown balance above 1.5x original principal', () {
      expect(
        FinancialValidators.isBalanceOverGrown(
          currentBalanceCents: 151000,
          originalPrincipalCents: 100000,
        ),
        isTrue,
      );
      expect(
        FinancialValidators.isBalanceOverGrown(
          currentBalanceCents: 150000,
          originalPrincipalCents: 100000,
        ),
        isFalse,
      );
    });

    test('detects usury warning above threshold', () {
      expect(FinancialValidators.isUsuryWarning(Decimal.parse('0.37')), isTrue);
      expect(
        FinancialValidators.isUsuryWarning(Decimal.parse('0.36')),
        isFalse,
      );
    });

    test(
      'detects negative amortization when minimum does not cover interest',
      () {
        expect(
          FinancialValidators.isNegativeAmortization(
            minimumPaymentCents: 5000,
            monthlyInterestCents: 6000,
          ),
          isTrue,
        );
        expect(
          FinancialValidators.isNegativeAmortization(
            minimumPaymentCents: 6000,
            monthlyInterestCents: 6000,
          ),
          isFalse,
        );
      },
    );

    test('detects payoff timelines longer than 30 years', () {
      expect(FinancialValidators.isPayoffTooLong(361), isTrue);
      expect(FinancialValidators.isPayoffTooLong(360), isFalse);
    });

    test('verifies payment split totals', () {
      expect(
        FinancialValidators.isPaymentSplitValid(
          amount: 10000,
          principalPortion: 8000,
          interestPortion: 1500,
          feePortion: 500,
        ),
        isTrue,
      );
      expect(
        FinancialValidators.isPaymentSplitValid(
          amount: 10000,
          principalPortion: 8000,
          interestPortion: 1000,
          feePortion: 500,
        ),
        isFalse,
      );
    });

    test('generateWarnings aggregates all relevant warnings', () {
      final warnings = FinancialValidators.generateWarnings(
        currentBalanceCents: 170000,
        originalPrincipalCents: 100000,
        apr: Decimal.parse('0.42'),
        minimumPaymentCents: 4000,
        monthlyInterestCents: 5000,
        projectedMonths: 400,
      );

      expect(warnings, hasLength(4));
      expect(
        warnings.join(' '),
        contains('Balance exceeds original principal'),
      );
      expect(warnings.join(' '), contains('Unusually high interest rate'));
      expect(warnings.join(' '), contains('doesn\'t cover interest'));
      expect(warnings.join(' '), contains('over 30 years'));
    });

    test('generateWarnings returns empty list when debt is healthy', () {
      final warnings = FinancialValidators.generateWarnings(
        currentBalanceCents: 90000,
        originalPrincipalCents: 100000,
        apr: Decimal.parse('0.12'),
        minimumPaymentCents: 6000,
        monthlyInterestCents: 900,
        projectedMonths: 48,
      );

      expect(warnings, isEmpty);
    });
  });
}
