import 'package:drift/drift.dart';

import '../../domain/entities/user_settings.dart';
import '../local/database.dart';

/// Maps between Drift [UserSettingsRow] and domain [UserSettings] entity.
extension UserSettingsRowMapper on UserSettingsRow {
  UserSettings toDomain() {
    return UserSettings(
      id: id,
      trustLevel: trustLevel,
      firebaseUid: firebaseUid,
      currencyCode: currencyCode,
      localeCode: localeCode,
      dayCountConvention: dayCountConvention,
      notifPaymentReminder: notifPaymentReminder,
      notifPaymentReminderDaysBefore: notifPaymentReminderDaysBefore,
      notifMilestone: notifMilestone,
      notifMonthlyLog: notifMonthlyLog,
      onboardingStep: onboardingStep,
      onboardingCompleted: onboardingCompleted,
      onboardingCompletedAt: onboardingCompletedAt,
      isPremium: isPremium,
      premiumExpiresAt: premiumExpiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Maps from domain [UserSettings] to Drift [UserSettingsTableCompanion].
extension UserSettingsCompanionMapper on UserSettings {
  UserSettingsTableCompanion toCompanion() {
    return UserSettingsTableCompanion(
      id: Value(id),
      trustLevel: Value(trustLevel),
      firebaseUid: Value(firebaseUid),
      currencyCode: Value(currencyCode),
      localeCode: Value(localeCode),
      dayCountConvention: Value(dayCountConvention),
      notifPaymentReminder: Value(notifPaymentReminder),
      notifPaymentReminderDaysBefore: Value(notifPaymentReminderDaysBefore),
      notifMilestone: Value(notifMilestone),
      notifMonthlyLog: Value(notifMonthlyLog),
      onboardingStep: Value(onboardingStep),
      onboardingCompleted: Value(onboardingCompleted),
      onboardingCompletedAt: Value(onboardingCompletedAt),
      isPremium: Value(isPremium),
      premiumExpiresAt: Value(premiumExpiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
