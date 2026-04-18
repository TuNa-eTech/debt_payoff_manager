import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/mappers/debt_mapper.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/domain/entities/debt.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/domain/enums/interest_method.dart';
import 'package:debt_payoff_manager/domain/enums/min_payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/payment_cadence.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl repo;

  /// Create a valid test Debt with all required fields.
  Debt makeDebt({
    String id = 'test-debt-1',
    String name = 'Credit Card',
    DebtType type = DebtType.creditCard,
    int originalPrincipal = 500000, // $5,000.00
    int currentBalance = 480000,
    Decimal? apr,
    InterestMethod interestMethod = InterestMethod.simpleMonthly,
    int minimumPayment = 5000, // $50.00
    MinPaymentType minimumPaymentType = MinPaymentType.fixed,
    PaymentCadence paymentCadence = PaymentCadence.monthly,
    int dueDayOfMonth = 15,
    DebtStatus status = DebtStatus.active,
  }) {
    final now = DateTime.now().toUtc();
    return Debt(
      id: id,
      name: name,
      type: type,
      originalPrincipal: originalPrincipal,
      currentBalance: currentBalance,
      apr: apr ?? Decimal.parse('0.1899'),
      interestMethod: interestMethod,
      minimumPayment: minimumPayment,
      minimumPaymentType: minimumPaymentType,
      paymentCadence: paymentCadence,
      dueDayOfMonth: dueDayOfMonth,
      firstDueDate: DateTime(2024, 1, 15),
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DebtRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DebtRepositoryImpl', () {
    test('addDebt inserts and retrieves a debt', () async {
      final debt = makeDebt();
      await repo.addDebt(debt);

      final retrieved = await repo.getDebtById(debt.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, debt.id);
      expect(retrieved.name, 'Credit Card');
      expect(retrieved.currentBalance, 480000);
      expect(retrieved.apr, Decimal.parse('0.1899'));
    });

    test('getAllDebts returns only non-deleted debts', () async {
      await repo.addDebt(makeDebt(id: 'd1', name: 'Debt 1'));
      await repo.addDebt(makeDebt(id: 'd2', name: 'Debt 2'));
      await repo.addDebt(makeDebt(id: 'd3', name: 'Debt 3'));

      // Soft delete one
      await repo.deleteDebt('d2');

      final all = await repo.getAllDebts();
      expect(all.length, 2);
      expect(all.map((d) => d.id), containsAll(['d1', 'd3']));
    });

    test('getActiveDebts filters by active status', () async {
      await repo.addDebt(makeDebt(id: 'd1', status: DebtStatus.active));
      await repo.addDebt(makeDebt(id: 'd2', status: DebtStatus.paidOff));

      final active = await repo.getActiveDebts();
      expect(active.length, 1);
      expect(active.first.id, 'd1');
    });

    test('deleteDebt performs soft delete (sets deletedAt)', () async {
      await repo.addDebt(makeDebt(id: 'soft'));
      await repo.deleteDebt('soft');

      // Not visible via normal query
      final result = await repo.getDebtById('soft');
      expect(result, isNull);

      // But still in DB (raw query)
      final rawQuery = db.select(db.debtsTable)
        ..where((d) => d.id.equals('soft'));
      final raw = await rawQuery.getSingleOrNull();
      expect(raw, isNotNull);
      expect(raw!.deletedAt, isNotNull);
    });

    test('updateDebt modifies existing debt', () async {
      await repo.addDebt(makeDebt(id: 'upd'));
      final debt = (await repo.getDebtById('upd'))!;

      await repo.updateDebt(debt.copyWith(
        name: 'Updated Card',
        currentBalance: 300000,
      ));

      final updated = await repo.getDebtById('upd');
      expect(updated!.name, 'Updated Card');
      expect(updated.currentBalance, 300000);
    });

    test('watchAllDebts emits on changes', () async {
      final stream = repo.watchAllDebts();

      // Initial emission (empty)
      await expectLater(
        stream,
        emits(isEmpty),
      );

      // Add a debt
      await repo.addDebt(makeDebt(id: 'w1'));

      await expectLater(
        stream,
        emits(hasLength(1)),
      );
    });

    test('validates APR range', () async {
      expect(
        () => repo.addDebt(makeDebt(apr: Decimal.parse('1.5'))),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validates paused requires pausedUntil', () async {
      expect(
        () => repo.addDebt(makeDebt(status: DebtStatus.paused)),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('mapper round-trip preserves all fields', () async {
      final original = makeDebt(
        id: 'round-trip',
        name: 'Round Trip Test',
        currentBalance: 123456,
        apr: Decimal.parse('0.0525'),
      );

      await repo.addDebt(original);
      final retrieved = await repo.getDebtById('round-trip');

      expect(retrieved!.id, original.id);
      expect(retrieved.scenarioId, original.scenarioId);
      expect(retrieved.name, original.name);
      expect(retrieved.type, original.type);
      expect(retrieved.originalPrincipal, original.originalPrincipal);
      expect(retrieved.currentBalance, original.currentBalance);
      expect(retrieved.apr, original.apr);
      expect(retrieved.interestMethod, original.interestMethod);
      expect(retrieved.minimumPayment, original.minimumPayment);
      expect(retrieved.minimumPaymentType, original.minimumPaymentType);
      expect(retrieved.paymentCadence, original.paymentCadence);
      expect(retrieved.status, original.status);
    });
  });
}
