import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/services/payment_logging_service.dart';
import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/data/local/stores/timeline_cache_store.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/payment_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';

import '../../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepository;
  late PaymentRepositoryImpl paymentRepository;
  late PlanRepositoryImpl planRepository;
  late SyncStateStore syncStateStore;
  late TimelineCacheStore timelineCacheStore;
  late PlanRecastService planRecastService;
  late PaymentLoggingService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    debtRepository = DebtRepositoryImpl(db: db);
    paymentRepository = PaymentRepositoryImpl(db: db);
    planRepository = PlanRepositoryImpl(db: db);
    syncStateStore = SyncStateStore(db: db);
    timelineCacheStore = TimelineCacheStore(db: db);
    planRecastService = PlanRecastService(
      debtRepository: debtRepository,
      planRepository: planRepository,
      syncStateStore: syncStateStore,
      timelineCacheStore: timelineCacheStore,
    );
    service = PaymentLoggingService(
      db: db,
      debtRepository: debtRepository,
      paymentRepository: paymentRepository,
      syncStateStore: syncStateStore,
      planRecastService: planRecastService,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'logPayment updates the balance, persists audit snapshots, and marks dirty sync states',
    () async {
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'visa',
          name: 'Visa',
          currentBalance: 100000,
          originalPrincipal: 100000,
          minimumPayment: 12000,
        ),
      );

      final payment = await service.logPayment(
        debtId: 'visa',
        amountCents: 25000,
        type: PaymentType.minimum,
        source: PaymentSource.manual,
        date: DateTime(2026, 1, 15),
        note: 'Autopay',
      );

      final storedDebt = await debtRepository.getDebtById('visa');
      final storedPayments = await paymentRepository.getPaymentsForDebt('visa');
      final storedPlan = await planRepository.getCurrentPlan();

      expect(payment.principalPortion, 25000);
      expect(payment.interestPortion, 0);
      expect(payment.feePortion, 0);
      expect(payment.appliedBalanceBefore, 100000);
      expect(payment.appliedBalanceAfter, 75000);
      expect(storedDebt!.currentBalance, 75000);
      expect(storedDebt.status, DebtStatus.active);
      expect(storedPayments, hasLength(1));
      expect(storedPayments.single.source, PaymentSource.manual);
      expect(storedPayments.single.note, 'Autopay');
      expect(storedPlan!.projectedDebtFreeDate, isNotNull);

      expect((await syncStateStore.getState('debts'))?.pendingWrites, 1);
      expect((await syncStateStore.getState('payments'))?.pendingWrites, 1);
      expect((await syncStateStore.getState('plans'))?.pendingWrites, 1);
    },
  );

  test(
    'logPayment rejects overpay and marks the debt paid off on an exact check-off payment',
    () async {
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'small-balance',
          name: 'Small Balance',
          currentBalance: 20000,
          originalPrincipal: 20000,
          minimumPayment: 4000,
        ),
      );

      await expectLater(
        () => service.logPayment(
          debtId: 'small-balance',
          amountCents: 25000,
          type: PaymentType.extra,
          source: PaymentSource.checkOff,
        ),
        throwsArgumentError,
      );

      final payment = await service.logPayment(
        debtId: 'small-balance',
        amountCents: 20000,
        type: PaymentType.extra,
        source: PaymentSource.checkOff,
      );
      final storedDebt = await debtRepository.getDebtById('small-balance');

      expect(payment.source, PaymentSource.checkOff);
      expect(storedDebt!.currentBalance, 0);
      expect(storedDebt.status, DebtStatus.paidOff);
      expect(storedDebt.paidOffAt, isNotNull);
    },
  );
}
