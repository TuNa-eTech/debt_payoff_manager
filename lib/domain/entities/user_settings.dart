import 'package:equatable/equatable.dart';

/// UserSettings entity — singleton per user.
///
/// Reference: data-schema.md §7
///
/// Stores UI preferences, trust level, notification settings,
/// and onboarding progress.
class UserSettings extends Equatable {
  const UserSettings({
    this.id = 'singleton',
    this.trustLevel = 0,
    this.firebaseUid,
    this.currencyCode = 'USD',
    this.localeCode = 'en-US',
    this.dayCountConvention = 'actual365',
    this.notifPaymentReminder = true,
    this.notifPaymentReminderDaysBefore = 3,
    this.notifMilestone = true,
    this.notifMonthlyLog = true,
    this.onboardingStep = 0,
    this.onboardingCompleted = false,
    this.onboardingCompletedAt,
    this.isPremium = false,
    this.premiumExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// Progressive Trust Level: 0 = local only, 1 = cloud backup, 2 = sharing.
  final int trustLevel;
  final String? firebaseUid;

  final String currencyCode;
  final String localeCode;
  final String dayCountConvention;

  // Notification preferences
  final bool notifPaymentReminder;

  /// Days before due date to remind: {1, 3, 7}.
  final int notifPaymentReminderDaysBefore;
  final bool notifMilestone;
  final bool notifMonthlyLog;

  // Onboarding state
  /// 0=not started, 1=welcome, 2=first debt, 3=strategy,
  /// 4=extra amount, 5=completed.
  final int onboardingStep;
  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;

  // Premium
  final bool isPremium;
  final DateTime? premiumExpiresAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings copyWith({
    String? id,
    int? trustLevel,
    String? firebaseUid,
    String? currencyCode,
    String? localeCode,
    String? dayCountConvention,
    bool? notifPaymentReminder,
    int? notifPaymentReminderDaysBefore,
    bool? notifMilestone,
    bool? notifMonthlyLog,
    int? onboardingStep,
    bool? onboardingCompleted,
    DateTime? onboardingCompletedAt,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      trustLevel: trustLevel ?? this.trustLevel,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      currencyCode: currencyCode ?? this.currencyCode,
      localeCode: localeCode ?? this.localeCode,
      dayCountConvention: dayCountConvention ?? this.dayCountConvention,
      notifPaymentReminder: notifPaymentReminder ?? this.notifPaymentReminder,
      notifPaymentReminderDaysBefore:
          notifPaymentReminderDaysBefore ??
              this.notifPaymentReminderDaysBefore,
      notifMilestone: notifMilestone ?? this.notifMilestone,
      notifMonthlyLog: notifMonthlyLog ?? this.notifMonthlyLog,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, trustLevel, firebaseUid, currencyCode, localeCode,
        dayCountConvention, notifPaymentReminder,
        notifPaymentReminderDaysBefore, notifMilestone, notifMonthlyLog,
        onboardingStep, onboardingCompleted, onboardingCompletedAt,
        isPremium, premiumExpiresAt, createdAt, updatedAt,
      ];
}
