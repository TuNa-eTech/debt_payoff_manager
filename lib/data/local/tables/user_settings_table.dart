import 'package:drift/drift.dart';

import '../converters/datetime_converters.dart';

/// UserSettings table — singleton per user.
///
/// Reference: data-schema.md §7
///
/// PK is always 'singleton'. Stores UI preferences, trust level,
/// notification settings, and onboarding state.
@DataClassName('UserSettingsRow')
class UserSettingsTable extends Table {
  @override
  String get tableName => 'user_settings';

  TextColumn get id =>
      text().withDefault(const Constant('singleton'))();

  // Trust level (ADR-003)
  IntColumn get trustLevel =>
      integer().withDefault(const Constant(0))();
  TextColumn get firebaseUid => text().nullable()();

  // Display
  TextColumn get currencyCode =>
      text().withDefault(const Constant('USD'))();
  TextColumn get localeCode =>
      text().withDefault(const Constant('en-US'))();
  TextColumn get dayCountConvention =>
      text().withDefault(const Constant('actual365'))();

  // Notifications
  BoolColumn get notifPaymentReminder =>
      boolean().withDefault(const Constant(true))();
  IntColumn get notifPaymentReminderDaysBefore =>
      integer().withDefault(const Constant(3))();
  BoolColumn get notifMilestone =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get notifMonthlyLog =>
      boolean().withDefault(const Constant(true))();

  // Onboarding
  // 0=not started, 1=welcome, 2=first debt, 3=strategy,
  // 4=extra amount, 5=completed
  IntColumn get onboardingStep =>
      integer().withDefault(const Constant(0))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get onboardingCompletedAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  // Premium
  BoolColumn get isPremium =>
      boolean().withDefault(const Constant(false))();
  TextColumn get premiumExpiresAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  // Standard
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
