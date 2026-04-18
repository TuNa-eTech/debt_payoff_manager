import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/payment_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';

import 'repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepo;
  late PaymentRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    debtRepo = DebtRepositoryImpl(db: db);
    repo = PaymentRepositoryImpl(db: db);
    await debtRepo.addDebt(makeRepoDebt());
  });

  tearDown(() async {
    await db.close();
  });

  group('PaymentRepositoryImpl', () {
    test('addPayment inserts and retrieves a payment', () async {
      final payment = makeRepoPayment();

      await repo.addPayment(payment);

      final retrieved = await repo.getPaymentById(payment.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, payment.id);
      expect(retrieved.amount, 5000);
      expect(retrieved.principalPortion, 4200);
      expect(retrieved.interestPortion, 800);
      expect(retrieved.type, PaymentType.minimum);
    });

    test('getAllPayments filters by date range and scenario', () async {
      await repo.addPayment(
        makeRepoPayment(id: 'jan-main', date: DateTime(2026, 1, 10)),
      );
      await repo.addPayment(
        makeRepoPayment(id: 'feb-main', date: DateTime(2026, 2, 10)),
      );
      await repo.addPayment(
        makeRepoPayment(
          id: 'feb-what-if',
          scenarioId: 'what-if',
          date: DateTime(2026, 2, 15),
        ),
      );

      final mainRange = await repo.getAllPayments(
        fromDate: DateTime(2026, 2, 1),
        toDate: DateTime(2026, 2, 28),
      );

      expect(mainRange.map((payment) => payment.id), ['feb-main']);
    });

    test(
      'getPaymentsForMonth returns payments inside the requested month',
      () async {
        await repo.addPayment(
          makeRepoPayment(id: 'jan', date: DateTime(2026, 1, 10)),
        );
        await repo.addPayment(
          makeRepoPayment(id: 'feb', date: DateTime(2026, 2, 10)),
        );

        final februaryPayments = await repo.getPaymentsForMonth('2026-02');

        expect(februaryPayments.map((payment) => payment.id), ['feb']);
      },
    );

    test('updatePayment persists changes', () async {
      await repo.addPayment(makeRepoPayment(id: 'update-me'));
      final updated = makeRepoPayment(
        id: 'update-me',
        amount: 6500,
        principalPortion: 5700,
        interestPortion: 800,
        note: 'Updated payment',
      );

      await repo.updatePayment(updated);

      final retrieved = await repo.getPaymentById('update-me');
      expect(retrieved!.amount, 6500);
      expect(retrieved.note, 'Updated payment');
    });

    test('deletePayment performs soft delete', () async {
      await repo.addPayment(makeRepoPayment(id: 'delete-me'));

      await repo.deletePayment('delete-me');

      expect(await repo.getPaymentById('delete-me'), isNull);
      final raw = await (db.select(
        db.paymentsTable,
      )..where((payment) => payment.id.equals('delete-me'))).getSingleOrNull();
      expect(raw, isNotNull);
      expect(raw!.deletedAt, isNotNull);
    });

    test('watchAllPayments emits updates', () async {
      final stream = repo.watchAllPayments();

      await expectLater(stream, emits(isEmpty));

      await repo.addPayment(makeRepoPayment(id: 'watched'));

      await expectLater(
        stream,
        emits(predicate<List<dynamic>>((payments) => payments.length == 1)),
      );
    });

    test(
      'payment entity enforces split invariant before repository write',
      () async {
        expect(
          () => makeRepoPayment(
            amount: 5000,
            principalPortion: 3000,
            interestPortion: 1000,
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'validates charge must use negative principal and higher balance',
      () async {
        expect(
          () => repo.addPayment(
            makeRepoPayment(
              type: PaymentType.charge,
              amount: 5000,
              principalPortion: 5000,
              interestPortion: 0,
              appliedBalanceBefore: 100000,
              appliedBalanceAfter: 105000,
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );

        final charge = makeRepoPayment(
          id: 'charge-ok',
          type: PaymentType.charge,
          amount: 5000,
          principalPortion: -5000,
          interestPortion: 10000,
          appliedBalanceBefore: 100000,
          appliedBalanceAfter: 105000,
        );
        await repo.addPayment(charge);
        final persisted = await repo.getPaymentById('charge-ok');
        expect(persisted, isNotNull);
        expect(persisted!.type, PaymentType.charge);
      },
    );

    test('validates payment status date rules', () async {
      final tomorrow = localDay(DateTime.now().add(const Duration(days: 1)));
      final yesterday = localDay(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(
        () => repo.addPayment(
          makeRepoPayment(id: 'future-completed', date: tomorrow),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repo.addPayment(
          makeRepoPayment(
            id: 'past-planned',
            status: PaymentStatus.planned,
            date: yesterday,
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repo.addPayment(
          makeRepoPayment(
            id: 'future-missed',
            status: PaymentStatus.missed,
            date: tomorrow,
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('round-trip preserves audit fields and notes', () async {
      final payment = makeRepoPayment(
        id: 'round-trip',
        note: 'Manual adjustment',
        feePortion: 200,
        amount: 5200,
        principalPortion: 4200,
        interestPortion: 800,
        appliedBalanceBefore: 200000,
        appliedBalanceAfter: 195800,
      );

      await repo.addPayment(payment);

      final retrieved = await repo.getPaymentById('round-trip');
      expect(retrieved!.scenarioId, payment.scenarioId);
      expect(retrieved.note, payment.note);
      expect(retrieved.feePortion, 200);
      expect(retrieved.appliedBalanceBefore, 200000);
      expect(retrieved.appliedBalanceAfter, 195800);
    });
  });
}
