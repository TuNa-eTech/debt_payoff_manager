import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Initializes the plugin and timezones. Call this during app startup.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezones.
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    try {
      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
    } on MissingPluginException catch (error) {
      debugPrint('NotificationService initialize skipped: $error');
      return;
    }

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification clicked: ${response.payload}');
    // TODO: Handle routing if payload exists
  }

  /// Request permissions dynamically. Returns true if granted.
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final result = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return result ?? false;
      } else if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
    } on MissingPluginException catch (error) {
      debugPrint('NotificationService permission request skipped: $error');
    }
    return false;
  }

  /// Checks if permissions are granted.
  Future<bool> hasPermissions() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } on MissingPluginException catch (error) {
      debugPrint('NotificationService permission status skipped: $error');
      return false;
    }
  }

  /// Show a basic immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'debt_payoff_reminders',
            'Reminders',
            channelDescription: 'Reminders for due dates and missing payments',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFF1B6B4A), // Forest Green
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } on MissingPluginException catch (error) {
      debugPrint('NotificationService show skipped: $error');
    }
  }

  /// Schedule a notification for a specific date and time.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('Cannot schedule notification in the past: $scheduledDate');
      return;
    }

    final scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'debt_payoff_reminders',
            'Reminders',
            channelDescription: 'Reminders for due dates and missing payments',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFF1B6B4A),
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('Scheduled notification $id for $scheduledTzDate');
    } on MissingPluginException catch (error) {
      debugPrint('NotificationService schedule skipped: $error');
    }
  }

  /// Cancel a specific notification.
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      debugPrint('Cancelled notification $id');
    } on MissingPluginException catch (error) {
      debugPrint('NotificationService cancel skipped: $error');
    }
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      debugPrint('Cancelled all notifications');
    } on MissingPluginException catch (error) {
      debugPrint('NotificationService cancelAll skipped: $error');
    }
  }
}
