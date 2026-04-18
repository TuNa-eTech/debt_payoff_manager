import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../local/database.dart';
import '../mappers/user_settings_mapper.dart';

/// Concrete implementation of [SettingsRepository] using Drift (SQLite).
///
/// UserSettings is a singleton (id='singleton'), seeded on DB creation.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<UserSettings> getSettings() async {
    final query = _db.select(_db.userSettingsTable)
      ..where((s) => s.id.equals('singleton'));

    final row = await query.getSingle();
    return row.toDomain();
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    _validateSettings(settings);
    final updated = settings.copyWith(updatedAt: DateTime.now().toUtc());
    await (_db.update(
      _db.userSettingsTable,
    )..where((s) => s.id.equals('singleton'))).write(updated.toCompanion());
  }

  @override
  Stream<UserSettings> watchSettings() {
    final query = _db.select(_db.userSettingsTable)
      ..where((s) => s.id.equals('singleton'));

    return query.watchSingle().map((row) => row.toDomain());
  }

  void _validateSettings(UserSettings settings) {
    if (settings.id != 'singleton') {
      throw ArgumentError('UserSettings id must always be singleton');
    }

    if (settings.trustLevel < 0 || settings.trustLevel > 2) {
      throw ArgumentError('trustLevel must be between 0 and 2');
    }

    final hasFirebaseUid =
        settings.firebaseUid != null && settings.firebaseUid!.trim().isNotEmpty;
    if (settings.trustLevel >= 1 && !hasFirebaseUid) {
      throw ArgumentError('firebaseUid is required when trustLevel is 1 or 2');
    }

    if (settings.trustLevel == 0 && hasFirebaseUid) {
      throw ArgumentError('firebaseUid must be null when trustLevel is 0');
    }

    if (settings.onboardingStep < 0 || settings.onboardingStep > 5) {
      throw ArgumentError('onboardingStep must be between 0 and 5');
    }

    if (settings.onboardingCompleted && settings.onboardingStep != 5) {
      throw ArgumentError(
        'onboardingStep must be 5 when onboardingCompleted is true',
      );
    }

    if (settings.onboardingStep == 5 && !settings.onboardingCompleted) {
      throw ArgumentError(
        'onboardingCompleted must be true when onboardingStep is 5',
      );
    }

    if (settings.onboardingCompleted &&
        settings.onboardingCompletedAt == null) {
      throw ArgumentError(
        'onboardingCompletedAt required when onboarding is completed',
      );
    }

    if (!settings.onboardingCompleted &&
        settings.onboardingCompletedAt != null) {
      throw ArgumentError(
        'onboardingCompletedAt must be null until onboarding is completed',
      );
    }

    const validReminderDays = {1, 3, 7};
    if (!validReminderDays.contains(settings.notifPaymentReminderDaysBefore)) {
      throw ArgumentError(
        'notifPaymentReminderDaysBefore must be one of 1, 3, or 7',
      );
    }
  }
}
