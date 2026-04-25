import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/i18n/app_locale.dart';
import 'core/services/app_analytics.dart';
import 'core/services/milestone_notification_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_scheduler_service.dart';
import 'core/theme/app_colors.dart';
import 'sync/cloud_backup_service.dart';

void main() async {
  // Wrap in runZonedGuarded so async errors are also forwarded to Crashlytics.
  runZonedGuarded(_appMain, _onZoneError);
}

void _onZoneError(Object error, StackTrace stack) {
  if (!kIsWeb) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  }
}

Future<void> _appMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Lock the Android/iOS system chrome to the app's light theme.
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppColors.mdSurface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependency injection
  configureDependencies(
    appAnalytics: await _bootstrapAnalytics(),
    seedLocaleCode: AppLocale.localeCodeForSystemLocale(
      WidgetsBinding.instance.platformDispatcher.locale,
    ),
  );

  // Initialize notifications
  await getIt<NotificationService>().initialize();
  getIt<ReminderSchedulerService>().init();
  getIt<MilestoneNotificationService>().init();
  await getIt<CloudBackupService>().init();

  runApp(const DebtPayoffApp());
}

Future<AppAnalytics> _bootstrapAnalytics() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    // Wire Crashlytics error handlers (no-op on web or if Firebase failed).
    if (!kIsWeb) {
      final crashlytics = FirebaseCrashlytics.instance;
      FlutterError.onError = crashlytics.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    }
    return FirebaseAppAnalytics();
  } catch (_) {
    return const NoopAppAnalytics();
  }
}
