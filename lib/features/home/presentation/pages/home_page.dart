import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_permission_prompt_tracker.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/reminder_scheduler_service.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../monthly_action/presentation/pages/monthly_action_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SettingsRepository _settingsRepository = getIt<SettingsRepository>();
  final NotificationService _notificationService = getIt<NotificationService>();
  final NotificationPermissionPromptTracker _promptTracker =
      getIt<NotificationPermissionPromptTracker>();
  final ReminderSchedulerService _reminderSchedulerService =
      getIt<ReminderSchedulerService>();

  bool _didCheckNotificationPermissionPrompt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRequestNotificationPermission();
    });
  }

  Future<void> _maybeRequestNotificationPermission() async {
    if (_didCheckNotificationPermissionPrompt) {
      return;
    }
    _didCheckNotificationPermissionPrompt = true;

    final settings = await _settingsRepository.getSettings();
    if (!mounted ||
        !settings.onboardingCompleted ||
        (!settings.notifPaymentReminder &&
            !settings.notifMonthlyLog &&
            !settings.notifMilestone)) {
      return;
    }

    final hasPermissions = await _notificationService.hasPermissions();
    if (hasPermissions) {
      await _promptTracker.markPrompted();
      await _reminderSchedulerService.rescheduleAllReminders();
      return;
    }

    final hasPrompted = await _promptTracker.hasPrompted();
    if (hasPrompted || !mounted) {
      return;
    }

    await _promptTracker.markPrompted();
    final granted = await _notificationService.requestPermissions();
    if (!mounted || !granted) {
      return;
    }

    await _reminderSchedulerService.rescheduleAllReminders();
  }

  @override
  Widget build(BuildContext context) {
    return const MonthlyActionPage();
  }
}
