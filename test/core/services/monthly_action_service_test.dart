import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/models/monthly_action_models.dart';
import 'package:debt_payoff_manager/core/services/monthly_action_service.dart';
import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/data/local/stores/timeline_cache_store.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/payment_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';

import '../../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepository;
  late PaymentRepositoryImpl paymentRepository;
  late PlanRepositoryImpl planRepository;
  late SyncStateStore syncStateStore;
  late TimelineCacheStore timelineCacheStore;
  late PlanRecastService planRecastService;
  late MonthlyActionService service;

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
    service = MonthlyActionService(
      debtRepository: debtRepository,
      paymentRepository: paymentRepository,
      planRepository: planRepository,
      planRecastService: planRecastService,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'load groups minimum and extra actions by debt and flags overdue/upcoming only for minimum items',
    () async {
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'overdue',
          name: 'Overdue Card',
          currentBalance: 50000,
          originalPrincipal: 50000,
          minimumPayment: 5000,
          dueDayOfMonth: 10,
          firstDueDate: DateTime(2026, 1, 10),
        ),
      );
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'upcoming',
          name: 'Upcoming Loan',
          currentBalance: 80000,
          originalPrincipal: 80000,
          minimumPayment: 6000,
          dueDayOfMonth: 25,
          firstDueDate: DateTime(2026, 1, 25),
        ),
      );

      final seededPlan = await planRepository.getCurrentPlan();
      await planRepository.savePlan(
        seededPlan!.copyWith(
          strategy: Strategy.snowball,
          extraMonthlyAmount: 3000,
        ),
      );

      final snapshot = await service.load(referenceDate: DateTime(2026, 1, 18));
      final overdueSection = snapshot.sections.firstWhere(
        (section) => section.debtId == 'overdue',
      );
      final overdueMinimum = overdueSection.items.firstWhere(
        (item) => item.kind == MonthlyActionKind.minimum,
      );
      final overdueExtra = overdueSection.items.firstWhere(
        (item) => item.kind == MonthlyActionKind.extra,
      );
      final upcomingSection = snapshot.sections.firstWhere(
        (section) => section.debtId == 'upcoming',
      );
      final upcomingMinimum = upcomingSection.items.firstWhere(
        (item) => item.kind == MonthlyActionKind.minimum,
      );

      expect(snapshot.hasTrackedDebts, isTrue);
      expect(snapshot.plan?.projectedDebtFreeDate, isNotNull);
      expect(snapshot.sections, hasLength(2));
      expect(overdueMinimum.isOverdue, isTrue);
      expect(overdueMinimum.isUpcoming, isFalse);
      expect(overdueExtra.isOverdue, isFalse);
      expect(overdueExtra.isUpcoming, isFalse);
      expect(overdueExtra.paymentType, PaymentType.extra);
      expect(upcomingMinimum.isUpcoming, isTrue);
      expect(upcomingMinimum.isOverdue, isFalse);
      expect(snapshot.summary.overdueCount, 1);
    },
  );

  test(
    'completed payments mark monthly action items done without changing their grouping',
    () async {
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'snowball-target',
          name: 'Snowball Target',
          currentBalance: 45000,
          originalPrincipal: 45000,
          minimumPayment: 5000,
          dueDayOfMonth: 10,
          firstDueDate: DateTime(2026, 1, 10),
        ),
      );
      await debtRepository.addDebt(
        makeRepoDebt(
          id: 'second',
          name: 'Second Debt',
          currentBalance: 90000,
          originalPrincipal: 90000,
          minimumPayment: 6000,
          dueDayOfMonth: 25,
          firstDueDate: DateTime(2026, 1, 25),
        ),
      );

      final seededPlan = await planRepository.getCurrentPlan();
      await planRepository.savePlan(
        seededPlan!.copyWith(
          strategy: Strategy.snowball,
          extraMonthlyAmount: 3000,
        ),
      );
      await paymentRepository.addPayment(
        makeRepoPayment(
          id: 'minimum-completed',
          debtId: 'snowball-target',
          amount: 5000,
          principalPortion: 5000,
          interestPortion: 0,
          date: DateTime(2026, 1, 5),
          type: PaymentType.minimum,
          appliedBalanceBefore: 45000,
          appliedBalanceAfter: 40000,
        ),
      );
      await paymentRepository.addPayment(
        makeRepoPayment(
          id: 'extra-completed',
          debtId: 'snowball-target',
          amount: 3000,
          principalPortion: 3000,
          interestPortion: 0,
          date: DateTime(2026, 1, 6),
          type: PaymentType.extra,
          appliedBalanceBefore: 40000,
          appliedBalanceAfter: 37000,
        ),
      );

      final snapshot = await service.load(referenceDate: DateTime(2026, 1, 18));
      final targetSection = snapshot.sections.firstWhere(
        (section) => section.debtId == 'snowball-target',
      );

      expect(targetSection.items, hasLength(2));
      expect(targetSection.items.every((item) => item.isCompleted), isTrue);
      expect(targetSection.isCompleted, isTrue);
      expect(snapshot.summary.completedCount, 2);
      expect(snapshot.summary.totalCount, 3);
    },
  );
}
