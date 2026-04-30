import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/entities/debt.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/payment_type.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import 'notification_service.dart';

typedef NowProvider = DateTime Function();

class ReminderSchedulerService {
  ReminderSchedulerService({
    required NotificationService notificationService,
    required DebtRepository debtRepository,
    required PaymentRepository paymentRepository,
    required SettingsRepository settingsRepository,
    NowProvider? nowProvider,
  }) : _notificationService = notificationService,
       _debtRepository = debtRepository,
       _paymentRepository = paymentRepository,
       _settingsRepository = settingsRepository,
       _nowProvider = nowProvider ?? DateTime.now;

  static const int _monthlyLogNotificationId = 904001;

  final NotificationService _notificationService;
  final DebtRepository _debtRepository;
  final PaymentRepository _paymentRepository;
  final SettingsRepository _settingsRepository;
  final NowProvider _nowProvider;
  StreamSubscription<Object?>? _settingsSubscription;
  StreamSubscription<Object?>? _debtSubscription;
  StreamSubscription<Object?>? _paymentSubscription;
  bool _initialized = false;
  String? _watchedScenarioId;

  /// Listen to settings and debts to automatically reschedule.
  void init() {
    if (_initialized) return;
    _initialized = true;

    _settingsSubscription = _settingsRepository.watchSettings().listen((
      settings,
    ) {
      unawaited(_watchScenarioData(settings.activeScenarioId));
      unawaited(rescheduleAllReminders());
    });

    unawaited(rescheduleAllReminders());
  }

  Future<void> dispose() async {
    await _settingsSubscription?.cancel();
    await _debtSubscription?.cancel();
    await _paymentSubscription?.cancel();
    _settingsSubscription = null;
    _debtSubscription = null;
    _paymentSubscription = null;
    _initialized = false;
    _watchedScenarioId = null;
  }

  /// Reschedules all due date reminders.
  /// Call this when debts change or when notification settings change.
  Future<void> rescheduleAllReminders() async {
    final settings = await _settingsRepository.getSettings();
    final scenarioId = settings.activeScenarioId;
    final debts = await _debtRepository.getAllDebts(scenarioId: scenarioId);
    await _cancelReminderNotifications(debts);

    if (!settings.notifPaymentReminder && !settings.notifMonthlyLog) {
      debugPrint('All reminder notifications are disabled in settings.');
      return;
    }

    final hasPerm = await _notificationService.hasPermissions();
    if (!hasPerm) {
      debugPrint('No notification permission, skipping scheduling.');
      return;
    }

    final activeDebts = debts
        .where((debt) => debt.status == DebtStatus.active)
        .toList(growable: false);
    if (activeDebts.isEmpty) {
      debugPrint('No active debts available for reminder scheduling.');
      return;
    }

    final now = _nowProvider();
    final daysBefore = settings.notifPaymentReminderDaysBefore;

    final localeParts = settings.localeCode.split('-');
    final locale = localeParts.length > 1
        ? Locale(localeParts[0], localeParts[1])
        : Locale(localeParts[0]);
    final l10n = lookupAppLocalizations(locale);

    if (settings.notifPaymentReminder) {
      for (final debt in activeDebts) {
        final dueDate = _calculateNextDueDate(debt.dueDayOfMonth, now);
        final scheduledDate = dueDate.subtract(Duration(days: daysBefore));

        var notificationTime = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          10,
        );

        if (notificationTime.isBefore(now)) {
          final nextMonthDueDate = _calculateNextDueDate(
            debt.dueDayOfMonth,
            DateTime(now.year, now.month + 1, 1),
          );
          final nextScheduledDate = nextMonthDueDate.subtract(
            Duration(days: daysBefore),
          );
          notificationTime = DateTime(
            nextScheduledDate.year,
            nextScheduledDate.month,
            nextScheduledDate.day,
            10,
          );
        }

        await _notificationService.scheduleNotification(
          id: debt.id.hashCode,
          title: l10n.notificationPaymentDueTitle,
          body: l10n.notificationPaymentDueBody(debt.name),
          scheduledDate: notificationTime,
          payload: 'debt_id=${debt.id}',
        );
      }
    }

    if (settings.notifMonthlyLog) {
      await _scheduleMonthlyLogReminder(
        activeDebtIds: activeDebts.map((debt) => debt.id).toSet(),
        scenarioId: scenarioId,
        now: now,
        l10n: l10n,
      );
    }

    debugPrint('Rescheduled reminders for ${activeDebts.length} active debts.');
  }

  DateTime _calculateNextDueDate(int dueDayOfMonth, DateTime fromDate) {
    int year = fromDate.year;
    int month = fromDate.month;

    if (fromDate.day > dueDayOfMonth) {
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    int day = dueDayOfMonth;
    final maxDaysInMonth = DateTime(year, month + 1, 0).day;
    if (day > maxDaysInMonth) {
      day = maxDaysInMonth;
    }

    return DateTime(year, month, day);
  }

  Future<void> _cancelReminderNotifications(List<Debt> debts) async {
    final ids = <int>{_monthlyLogNotificationId};
    for (final debt in debts) {
      ids.add(debt.id.hashCode);
    }
    for (final id in ids) {
      await _notificationService.cancelNotification(id);
    }
  }

  Future<void> _scheduleMonthlyLogReminder({
    required Set<String> activeDebtIds,
    required String scenarioId,
    required DateTime now,
    required AppLocalizations l10n,
  }) async {
    if (activeDebtIds.isEmpty) return;

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final paymentsThisMonth = await _paymentRepository.getAllPayments(
      scenarioId: scenarioId,
      fromDate: monthStart,
      toDate: monthEnd,
    );
    final debtIdsWithCompletedPayments = paymentsThisMonth
        .where((payment) => payment.status == PaymentStatus.completed)
        .map((payment) => payment.debtId)
        .where(activeDebtIds.contains)
        .toSet();

    final targetMonth =
        debtIdsWithCompletedPayments.length >= activeDebtIds.length
        ? DateTime(now.year, now.month + 1, 1)
        : monthStart;
    final scheduledDate = DateTime(
      targetMonth.year,
      targetMonth.month + 1,
      0,
      18,
    );

    await _notificationService.scheduleNotification(
      id: _monthlyLogNotificationId,
      title: l10n.notificationMonthlyLogTitle,
      body: l10n.notificationMonthlyLogBody,
      scheduledDate: scheduledDate.isBefore(now)
          ? DateTime(now.year, now.month + 2, 0, 18)
          : scheduledDate,
      payload: 'monthly_log',
    );
  }

  Future<void> _watchScenarioData(String scenarioId) async {
    if (_watchedScenarioId == scenarioId) return;
    _watchedScenarioId = scenarioId;
    await _debtSubscription?.cancel();
    await _paymentSubscription?.cancel();
    _debtSubscription = _debtRepository
        .watchAllDebts(scenarioId: scenarioId)
        .listen((_) => unawaited(rescheduleAllReminders()));
    _paymentSubscription = _paymentRepository
        .watchAllPayments(scenarioId: scenarioId)
        .listen((_) => unawaited(rescheduleAllReminders()));
  }
}
