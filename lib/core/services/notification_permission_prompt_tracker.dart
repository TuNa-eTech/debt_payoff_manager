import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationPermissionPromptTracker {
  Future<bool> hasPrompted();

  Future<void> markPrompted();
}

class SharedPrefsNotificationPermissionPromptTracker
    implements NotificationPermissionPromptTracker {
  SharedPrefsNotificationPermissionPromptTracker({
    Future<SharedPreferences>? sharedPreferences,
  }) : _sharedPreferences =
           sharedPreferences ?? SharedPreferences.getInstance();

  static const _promptedKey = 'notification_permission_prompt_tracker.prompted';

  final Future<SharedPreferences> _sharedPreferences;

  @override
  Future<bool> hasPrompted() async {
    final prefs = await _sharedPreferences;
    return prefs.getBool(_promptedKey) ?? false;
  }

  @override
  Future<void> markPrompted() async {
    final prefs = await _sharedPreferences;
    await prefs.setBool(_promptedKey, true);
  }
}
