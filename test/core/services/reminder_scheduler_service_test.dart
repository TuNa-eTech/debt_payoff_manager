import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/core/services/notification_service.dart';
import 'package:debt_payoff_manager/core/services/reminder_scheduler_service.dart';
import 'package:debt_payoff_manager/domain/entities/debt.dart';
import 'package:debt_payoff_manager/domain/entities/payment.dart';
import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/payment_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';

import '../../data/repositories/repository_test_helpers.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockDebtRepository extends Mock implements DebtRepository {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockNotificationService mockNotificationService;
  late MockDebtRepository mockDebtRepository;
  late MockPaymentRepository mockPaymentRepository;
  late MockSettingsRepository mockSettingsRepository;
  late ReminderSchedulerService service;

  final fixedNow = DateTime(2026, 4, 15, 12);

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockDebtRepository = MockDebtRepository();
    mockPaymentRepository = MockPaymentRepository();
    mockSettingsRepository = MockSettingsRepository();

    service = ReminderSchedulerService(
      notificationService: mockNotificationService,
      debtRepository: mockDebtRepository,
      paymentRepository: mockPaymentRepository,
      settingsRepository: mockSettingsRepository,
      nowProvider: () => fixedNow,
    );

    when(
      () => mockNotificationService.cancelNotification(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.scheduleNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.hasPermissions(),
    ).thenAnswer((_) async => true);

    when(
      () =>
          mockDebtRepository.getAllDebts(scenarioId: any(named: 'scenarioId')),
    ).thenAnswer((_) async => <Debt>[]);
    when(
      () => mockPaymentRepository.getAllPayments(
        scenarioId: any(named: 'scenarioId'),
        fromDate: any(named: 'fromDate'),
        toDate: any(named: 'toDate'),
      ),
    ).thenAnswer((_) async => <Payment>[]);
    when(() => mockSettingsRepository.getSettings()).thenAnswer(
      (_) async => UserSettings(
        notifPaymentReminder: false,
        notifMonthlyLog: false,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
    );
  });

  group('rescheduleAllReminders', () {
    test('does nothing when all reminder categories are disabled', () async {
      final debt = makeRepoDebt(id: 'disabled');
      when(
        () => mockDebtRepository.getAllDebts(
          scenarioId: any(named: 'scenarioId'),
        ),
      ).thenAnswer((_) async => <Debt>[debt]);

      await service.rescheduleAllReminders();

      verify(
        () => mockNotificationService.cancelNotification(debt.id.hashCode),
      ).called(1);
      verifyNever(
        () => mockNotificationService.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test(
      'does nothing when notification permissions are unavailable',
      () async {
        final debt = makeRepoDebt(id: 'active');
        when(() => mockSettingsRepository.getSettings()).thenAnswer(
          (_) async => UserSettings(
            notifPaymentReminder: true,
            notifMonthlyLog: false,
            localeCode: 'en-US',
            createdAt: fixedNow,
            updatedAt: fixedNow,
          ),
        );
        when(
          () => mockDebtRepository.getAllDebts(
            scenarioId: any(named: 'scenarioId'),
          ),
        ).thenAnswer((_) async => <Debt>[debt]);
        when(
          () => mockNotificationService.hasPermissions(),
        ).thenAnswer((_) async => false);

        await service.rescheduleAllReminders();

        verifyNever(
          () => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
          ),
        );
      },
    );

    test('schedules due-date reminders for active debts only', () async {
      final activeDebt1 = makeRepoDebt(
        id: '1',
        name: 'Credit Card',
        dueDayOfMonth: 20,
      );
      final activeDebt2 = makeRepoDebt(
        id: '2',
        name: 'Auto Loan',
        dueDayOfMonth: 10,
      );
      final paidOffDebt = makeRepoDebt(
        id: '3',
        name: 'Paid Off',
        currentBalance: 0,
        status: DebtStatus.paidOff,
      );

      when(() => mockSettingsRepository.getSettings()).thenAnswer(
        (_) async => UserSettings(
          notifPaymentReminder: true,
          notifMonthlyLog: false,
          notifPaymentReminderDaysBefore: 1,
          localeCode: 'en-US',
          createdAt: fixedNow,
          updatedAt: fixedNow,
        ),
      );
      when(
        () => mockDebtRepository.getAllDebts(
          scenarioId: any(named: 'scenarioId'),
        ),
      ).thenAnswer((_) async => <Debt>[activeDebt1, activeDebt2, paidOffDebt]);

      await service.rescheduleAllReminders();

      verify(
        () => mockNotificationService.scheduleNotification(
          id: activeDebt1.id.hashCode,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: DateTime(2026, 4, 19, 10),
          payload: 'debt_id=1',
        ),
      ).called(1);
      verify(
        () => mockNotificationService.scheduleNotification(
          id: activeDebt2.id.hashCode,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: DateTime(2026, 5, 9, 10),
          payload: 'debt_id=2',
        ),
      ).called(1);
      verifyNever(
        () => mockNotificationService.scheduleNotification(
          id: paidOffDebt.id.hashCode,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test('handles end-of-month clamping for due-date reminders', () async {
      final service = ReminderSchedulerService(
        notificationService: mockNotificationService,
        debtRepository: mockDebtRepository,
        paymentRepository: mockPaymentRepository,
        settingsRepository: mockSettingsRepository,
        nowProvider: () => DateTime(2026, 4, 15),
      );
      final debt = makeRepoDebt(id: '31', dueDayOfMonth: 31);

      when(() => mockSettingsRepository.getSettings()).thenAnswer(
        (_) async => UserSettings(
          notifPaymentReminder: true,
          notifMonthlyLog: false,
          notifPaymentReminderDaysBefore: 2,
          localeCode: 'en-US',
          createdAt: fixedNow,
          updatedAt: fixedNow,
        ),
      );
      when(
        () => mockDebtRepository.getAllDebts(
          scenarioId: any(named: 'scenarioId'),
        ),
      ).thenAnswer((_) async => <Debt>[debt]);

      await service.rescheduleAllReminders();

      verify(
        () => mockNotificationService.scheduleNotification(
          id: debt.id.hashCode,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: DateTime(2026, 4, 28, 10),
          payload: 'debt_id=31',
        ),
      ).called(1);
    });

    test(
      'rolls due-date reminder into the next month if today is already too late',
      () async {
        final debt = makeRepoDebt(id: '4', dueDayOfMonth: 16);
        when(() => mockSettingsRepository.getSettings()).thenAnswer(
          (_) async => UserSettings(
            notifPaymentReminder: true,
            notifMonthlyLog: false,
            notifPaymentReminderDaysBefore: 1,
            localeCode: 'en-US',
            createdAt: fixedNow,
            updatedAt: fixedNow,
          ),
        );
        when(
          () => mockDebtRepository.getAllDebts(
            scenarioId: any(named: 'scenarioId'),
          ),
        ).thenAnswer((_) async => <Debt>[debt]);

        await service.rescheduleAllReminders();

        verify(
          () => mockNotificationService.scheduleNotification(
            id: debt.id.hashCode,
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: DateTime(2026, 5, 15, 10),
            payload: 'debt_id=4',
          ),
        ).called(1);
      },
    );

    test(
      'schedules an end-of-month reminder when at least one debt is missing a logged payment',
      () async {
        final debtA = makeRepoDebt(id: 'a');
        final debtB = makeRepoDebt(id: 'b');
        final paymentA = makeRepoPayment(
          id: 'payment-a',
          debtId: debtA.id,
          date: DateTime(2026, 4, 10),
        );

        when(() => mockSettingsRepository.getSettings()).thenAnswer(
          (_) async => UserSettings(
            notifPaymentReminder: false,
            notifMonthlyLog: true,
            localeCode: 'en-US',
            createdAt: fixedNow,
            updatedAt: fixedNow,
          ),
        );
        when(
          () => mockDebtRepository.getAllDebts(
            scenarioId: any(named: 'scenarioId'),
          ),
        ).thenAnswer((_) async => <Debt>[debtA, debtB]);
        when(
          () => mockPaymentRepository.getAllPayments(
            scenarioId: any(named: 'scenarioId'),
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
          ),
        ).thenAnswer((_) async => <Payment>[paymentA]);

        await service.rescheduleAllReminders();

        verify(
          () => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: 'Monthly check-in',
            body: any(named: 'body'),
            scheduledDate: DateTime(2026, 4, 30, 18),
            payload: 'monthly_log',
          ),
        ).called(1);
      },
    );

    test(
      'moves the monthly reminder to the next month once all debts are already logged this month',
      () async {
        final debt = makeRepoDebt(id: 'solo');
        final payment = makeRepoPayment(
          id: 'payment-solo',
          debtId: debt.id,
          date: DateTime(2026, 4, 5),
        );

        when(() => mockSettingsRepository.getSettings()).thenAnswer(
          (_) async => UserSettings(
            notifPaymentReminder: false,
            notifMonthlyLog: true,
            localeCode: 'en-US',
            createdAt: fixedNow,
            updatedAt: fixedNow,
          ),
        );
        when(
          () => mockDebtRepository.getAllDebts(
            scenarioId: any(named: 'scenarioId'),
          ),
        ).thenAnswer((_) async => <Debt>[debt]);
        when(
          () => mockPaymentRepository.getAllPayments(
            scenarioId: any(named: 'scenarioId'),
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
          ),
        ).thenAnswer((_) async => <Payment>[payment]);

        await service.rescheduleAllReminders();

        verify(
          () => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: 'Monthly check-in',
            body: any(named: 'body'),
            scheduledDate: DateTime(2026, 5, 31, 18),
            payload: 'monthly_log',
          ),
        ).called(1);
      },
    );
  });
}
