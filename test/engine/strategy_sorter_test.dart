import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/domain/entities/debt.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/domain/enums/interest_method.dart';
import 'package:debt_payoff_manager/domain/enums/min_payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/payment_cadence.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/engine/strategy_sorter.dart';

/// Helper to create test debts.
Debt _debt({
  String id = '1',
  int balance = 100000,
  String apr = '0.10',
}) {
  return Debt(
    id: id,
    name: 'Test $id',
    type: DebtType.creditCard,
    originalPrincipal: balance,
    currentBalance: balance,
    apr: Decimal.parse(apr),
    interestMethod: InterestMethod.simpleMonthly,
    minimumPayment: 2500,
    minimumPaymentType: MinPaymentType.fixed,
    paymentCadence: PaymentCadence.monthly,
    dueDayOfMonth: 15,
    firstDueDate: DateTime(2026, 1, 15),
    status: DebtStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('StrategySorter', () {
    test('snowball sorts by balance ASC', () {
      final debts = [
        _debt(id: 'A', balance: 150000, apr: '0.10'),
        _debt(id: 'B', balance: 20000, apr: '0.08'),
        _debt(id: 'C', balance: 50000, apr: '0.20'),
      ];

      final sorted = StrategySorter.sort(debts, Strategy.snowball);

      expect(sorted.map((d) => d.id).toList(), ['B', 'C', 'A']);
    });

    test('snowball tiebreak by higher APR', () {
      final debts = [
        _debt(id: 'A', balance: 50000, apr: '0.10'),
        _debt(id: 'B', balance: 50000, apr: '0.20'),
      ];

      final sorted = StrategySorter.sort(debts, Strategy.snowball);
      expect(sorted.first.id, 'B'); // higher APR wins tiebreak
    });

    test('avalanche sorts by APR DESC', () {
      final debts = [
        _debt(id: 'A', balance: 50000, apr: '0.10'),
        _debt(id: 'B', balance: 20000, apr: '0.08'),
        _debt(id: 'C', balance: 150000, apr: '0.20'),
      ];

      final sorted = StrategySorter.sort(debts, Strategy.avalanche);

      expect(sorted.map((d) => d.id).toList(), ['C', 'A', 'B']);
    });

    test('avalanche tiebreak by lower balance', () {
      final debts = [
        _debt(id: 'A', balance: 100000, apr: '0.15'),
        _debt(id: 'B', balance: 50000, apr: '0.15'),
      ];

      final sorted = StrategySorter.sort(debts, Strategy.avalanche);
      expect(sorted.first.id, 'B'); // lower balance wins tiebreak
    });

    test('TV-3: Snowball vs Avalanche order divergence', () {
      /// Test Vector 3 from financial-engine-spec.md §12
      final debts = [
        _debt(id: 'A', balance: 50000, apr: '0.10'),
        _debt(id: 'B', balance: 20000, apr: '0.08'),
        _debt(id: 'C', balance: 150000, apr: '0.20'),
      ];

      final snowball = StrategySorter.sort(debts, Strategy.snowball);
      final avalanche = StrategySorter.sort(debts, Strategy.avalanche);

      // Snowball: B ($200) → A ($500) → C ($1500)
      expect(snowball.map((d) => d.id).toList(), ['B', 'A', 'C']);

      // Avalanche: C (20%) → A (10%) → B (8%)
      expect(avalanche.map((d) => d.id).toList(), ['C', 'A', 'B']);
    });
  });
}
