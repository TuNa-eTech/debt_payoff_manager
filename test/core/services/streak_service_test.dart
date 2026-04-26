import 'package:debt_payoff_manager/core/services/streak_service.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/repositories/repository_test_helpers.dart';

void main() {
  const service = StreakService();

  group('StreakService.computeCurrentStreak', () {
    final asOf = DateTime(2026, 4, 15);

    test('returns 0 when no payments', () {
      expect(service.computeCurrentStreak([], asOf), 0);
    });

    test('returns 0 when payments are all planned (not completed)', () {
      final payments = [
        makeRepoPayment(
          date: DateTime(2026, 4, 1),
          status: PaymentStatus.planned,
        ),
        makeRepoPayment(
          date: DateTime(2026, 3, 1),
          status: PaymentStatus.missed,
        ),
      ];
      expect(service.computeCurrentStreak(payments, asOf), 0);
    });

    test('counts consecutive completed months ending at asOf', () {
      final payments = [
        makeRepoPayment(date: DateTime(2026, 4, 1)),
        makeRepoPayment(date: DateTime(2026, 3, 15)),
        makeRepoPayment(date: DateTime(2026, 2, 10)),
        makeRepoPayment(date: DateTime(2026, 1, 5)),
      ];
      expect(service.computeCurrentStreak(payments, asOf), 4);
    });

    test('breaks streak on missing month', () {
      final payments = [
        makeRepoPayment(date: DateTime(2026, 4, 1)),
        // March missing
        makeRepoPayment(date: DateTime(2026, 2, 1)),
        makeRepoPayment(date: DateTime(2026, 1, 1)),
      ];
      expect(service.computeCurrentStreak(payments, asOf), 1);
    });

    test('multiple payments in one month count as one month', () {
      final payments = [
        makeRepoPayment(date: DateTime(2026, 4, 1)),
        makeRepoPayment(date: DateTime(2026, 4, 15)),
        makeRepoPayment(date: DateTime(2026, 3, 5)),
        makeRepoPayment(date: DateTime(2026, 3, 20)),
      ];
      expect(service.computeCurrentStreak(payments, asOf), 2);
    });

    test('ignores soft-deleted payments', () {
      final payments = [
        makeRepoPayment(date: DateTime(2026, 4, 1)).copyWith(
          deletedAt: DateTime(2026, 4, 2),
        ),
      ];
      expect(service.computeCurrentStreak(payments, asOf), 0);
    });
  });
}
