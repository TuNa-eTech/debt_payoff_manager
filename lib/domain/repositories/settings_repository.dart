import '../entities/user_settings.dart';

/// Abstract interface for user settings data access.
///
/// UserSettings is a singleton — only 1 row with id='singleton'.
abstract class SettingsRepository {
  /// Get the singleton settings.
  Future<UserSettings> getSettings();

  /// Update settings.
  Future<void> updateSettings(UserSettings settings);

  /// Watch settings as a stream.
  Stream<UserSettings> watchSettings();
}
