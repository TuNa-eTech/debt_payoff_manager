// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Debt Payoff X';

  @override
  String get navDebts => 'Debts';

  @override
  String get navPlan => 'Plan';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get navThisMonth => 'This month';

  @override
  String get commonAddDebt => 'Add debt';

  @override
  String get commonSavePayment => 'Save payment';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonViewAll => 'View all';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String commonComingSoonFeature(String feature) {
    return '$feature is coming soon.';
  }

  @override
  String get commonRecordAnotherAmount => 'Enter another amount';

  @override
  String get paymentTypeMinimumLabel => 'Minimum';

  @override
  String get paymentTypeExtraLabel => 'Extra';

  @override
  String get paymentTypeLumpSumLabel => 'Lump sum';

  @override
  String get homeCurrentBalanceTitle => 'Current total balance';

  @override
  String get homeStrategyLabel => 'Strategy';

  @override
  String get homeExtraMonthlyLabel => 'Extra / month';

  @override
  String homePaidAmountLabel(String amount) {
    return 'Paid $amount';
  }

  @override
  String get homeTrackedLabel => 'Tracking';

  @override
  String get homePaidOffLabel => 'Paid off';

  @override
  String get homePausedLabel => 'Paused';

  @override
  String get homeTrackedDebtsTitle => 'Debts to watch';

  @override
  String get homeTrackedDebtsSubtitle =>
      'This list comes directly from the debts you have saved.';

  @override
  String get homeDuePaused => 'Paused';

  @override
  String homeDueDay(int day) {
    return 'Day $day';
  }

  @override
  String get homeNoDebtsTracked => 'There are no debts to track yet.';

  @override
  String get homeCurrentPlanTitle => 'Current payoff plan';

  @override
  String get homeCurrentPlanPendingSubtitle =>
      'The app will recalculate your payoff date as soon as you record the latest payment.';

  @override
  String homeCurrentPlanProjectedSubtitle(String monthYear) {
    return 'If you keep this pace, you could be debt-free by $monthYear.';
  }

  @override
  String homeCurrentPlanStrategyLine(String strategy, String amount) {
    return '$strategy · Extra $amount / month';
  }

  @override
  String get homeViewPlanDetails => 'View detailed plan';

  @override
  String get monthlyActionStandaloneTitle => 'This month\'s actions';

  @override
  String get monthlyActionEmptyTitle => 'No debts are being tracked yet';

  @override
  String get monthlyActionEmptySubtitle =>
      'Add your first debt so the app can suggest what to do this month.';

  @override
  String get monthlyActionSectionTitle => 'This month\'s actions';

  @override
  String get monthlyActionSectionSubtitle =>
      'Handle required items first. The app will suggest extra payments separately.';

  @override
  String monthlyActionCompletionChip(int completed, int total) {
    return '$completed/$total done';
  }

  @override
  String get monthlyActionSummaryDebtFreeLabel => 'Projected payoff date';

  @override
  String get monthlyActionSummaryRecalculating => 'Recalculating';

  @override
  String get monthlyActionSummaryRequired => 'Required';

  @override
  String get monthlyActionSummaryExtra => 'Extra';

  @override
  String get monthlyActionSummaryOverdue => 'Overdue';

  @override
  String get monthlyActionRequiredSectionTitle => 'Required this month';

  @override
  String get monthlyActionRequiredSectionSubtitle =>
      'Start with overdue items, then the ones coming up soon.';

  @override
  String get monthlyActionOptionalSectionTitle => 'Pay extra to finish sooner';

  @override
  String get monthlyActionOptionalSectionSubtitle =>
      'Only do this after the required items are covered.';

  @override
  String get monthlyActionAllDoneTitle =>
      'You have finished this month\'s required payments';

  @override
  String get monthlyActionAllDoneSubtitle =>
      'If you still have room in the budget, use the extra section below to finish sooner.';

  @override
  String get monthlyActionNextActionTitle =>
      'There is nothing left to handle this month';

  @override
  String get monthlyActionNextActionSubtitle =>
      'You can review your current plan or record another payment if you just paid extra.';

  @override
  String get monthlyActionNextActionPrimary => 'View plan';

  @override
  String monthlyActionRequiredTotal(String amount) {
    return 'Need to pay $amount';
  }

  @override
  String monthlyActionSuggestedTotal(String amount) {
    return 'Suggested $amount';
  }

  @override
  String get monthlyActionDoneBadge => 'Done';

  @override
  String monthlyActionDueDate(String date) {
    return 'Due $date';
  }

  @override
  String get monthlyActionOptionalTiming =>
      'After your required payments for this month are done';

  @override
  String get monthlyActionOptionalHelper =>
      'This payment helps shorten your payoff timeline.';

  @override
  String get monthlyActionOverdueChip => 'Overdue';

  @override
  String get monthlyActionUpcomingChip => 'Upcoming';

  @override
  String monthlyActionPriorityChip(int rank) {
    return 'Priority #$rank';
  }

  @override
  String get monthlyActionSavedButton => 'Saved';

  @override
  String get monthlyActionPaidButton => 'Paid';

  @override
  String monthlyActionSnackbarSaved(String debtName) {
    return 'Saved a payment for $debtName.';
  }

  @override
  String get monthlyActionConfirmTitle => 'Confirm payment';

  @override
  String get monthlyActionConfirmSubtitle =>
      'This will be added to your history and will update your payoff plan.';

  @override
  String get monthlyActionInfoDebt => 'Debt';

  @override
  String get monthlyActionInfoType => 'Payment type';

  @override
  String get monthlyActionInfoAmount => 'Amount';

  @override
  String get monthlyActionInfoDate => 'Applied date';

  @override
  String monthlyActionRecastDebtFree(
    String previous,
    String current,
    String delta,
  ) {
    return 'Projected payoff date: $previous → $current$delta';
  }

  @override
  String monthlyActionRecastProjectedInterest(
    String previous,
    String current,
    String delta,
  ) {
    return 'Projected interest: $previous → $current$delta';
  }

  @override
  String monthlyActionRecastSavedInterest(
    String previous,
    String current,
    String delta,
  ) {
    return 'Interest saved: $previous → $current$delta';
  }

  @override
  String monthlyActionDeltaSooner(int months) {
    return ' ($months months sooner)';
  }

  @override
  String monthlyActionDeltaLater(int months) {
    return ' ($months months later)';
  }

  @override
  String monthlyActionDeltaReduced(String amount) {
    return ' (down $amount)';
  }

  @override
  String monthlyActionDeltaIncreased(String amount) {
    return ' (up $amount)';
  }

  @override
  String get monthlyActionRecastNeutral =>
      'Your plan has been refreshed using your latest data.';

  @override
  String get logPaymentTitle => 'Log payment';

  @override
  String get logPaymentMissingDebt =>
      'This debt no longer exists or has already been deleted.';

  @override
  String logPaymentCurrentBalance(String amount) {
    return 'Current balance $amount';
  }

  @override
  String get logPaymentAmountLabel => 'Amount paid';

  @override
  String get logPaymentAmountHelper =>
      'This amount will be subtracted directly from the current balance.';

  @override
  String get logPaymentTypeLabel => 'Payment type';

  @override
  String get logPaymentDateLabel => 'Applied date';

  @override
  String get logPaymentNoteLabel => 'Note';

  @override
  String get logPaymentNoteHint => 'Example: autopay, bonus, paycheck sweep';

  @override
  String get logPaymentInfo =>
      'This payment will store the before and after balances and refresh your payoff plan right away.';

  @override
  String get logPaymentInvalidAmount => 'Enter a valid amount greater than 0.';

  @override
  String get logPaymentSavedMessage => 'Payment saved and plan updated.';

  @override
  String get pricingBody =>
      'The current MVP keeps the full core payoff flow free. Premium is the next step for cloud backup, PDF reports, and shared planning.';

  @override
  String get pricingContinueFree => 'Continue with Free';

  @override
  String get pricingFreeBulletExport =>
      'CSV export + local backup/restore + clear all';

  @override
  String get pricingFreeBulletPayments =>
      'Payment logging + monthly action view';

  @override
  String get pricingFreeBulletStrategies =>
      'Snowball / Avalanche + living timeline';

  @override
  String get pricingFreeBulletUnlimitedDebts =>
      'Unlimited debt entry and editing';

  @override
  String get pricingFreeSubtitle => 'Included in the MVP';

  @override
  String get pricingFreeTitle => 'Free';

  @override
  String get pricingHeadline =>
      'Local-first first. Premium only unlocks when it adds real value.';

  @override
  String get pricingMvpNotice => 'Premium is not available in this MVP yet.';

  @override
  String get pricingPageTitle => 'Free vs Premium';

  @override
  String get pricingPremiumBulletCloud => 'Cloud backup across devices';

  @override
  String get pricingPremiumBulletPdf =>
      'PDF reports to print or share with an advisor';

  @override
  String get pricingPremiumBulletPricing =>
      'Transparent pricing, no fuzzy trial';

  @override
  String get pricingPremiumBulletSharing =>
      'Partner sharing and scenario comparison';

  @override
  String get pricingPremiumSubtitle => 'Monetization placeholder, no IAP yet';

  @override
  String get pricingPremiumTitle => 'Premium';

  @override
  String get pricingTrustMessage =>
      'Our trust model stays the same on Premium: no bank linking, no fuzzy auto-charges, and local export always stays available.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsClearAllDialogBody =>
      'This will delete all local data and return the app to its first-launch state.';

  @override
  String get settingsClearAllDialogTitle => 'Clear all data?';

  @override
  String get settingsClearAllSubtitle =>
      'Only resets data on this device. Cloud is not enabled at Level 0.';

  @override
  String get settingsClearAllTitle => 'Clear all data';

  @override
  String get settingsCloudBackupTitle => 'Cloud backup';

  @override
  String get settingsContinue => 'Continue';

  @override
  String get settingsCopyrightFooter => '© 2026 Debt Payoff X';

  @override
  String get settingsCurrencySubtitle =>
      'Currently used for display formatting only.';

  @override
  String get settingsCurrencyTitle => 'Currency';

  @override
  String get settingsDataBannerLocalBody =>
      'Your data currently lives on this device. You always have CSV export, local backup/restore, and clear all without an account or bank linking.';

  @override
  String get settingsDataBannerLocalTitle => 'Local-first is enabled';

  @override
  String get settingsDataBannerTrustBody =>
      'You are using trust level > 0. Local export is still available, but reset actions need more care because they may relate to cloud semantics.';

  @override
  String get settingsDataBannerTrustTitle => 'Advanced trust mode is enabled';

  @override
  String get settingsDeleteAllConfirm => 'Delete everything';

  @override
  String get settingsExportCsvSubtitle =>
      'ZIP bundle with multiple CSV files + manifest so you can inspect each table yourself.';

  @override
  String get settingsExportCsvTitle => 'Export data (CSV)';

  @override
  String get settingsExtraMonthlySubtitle => 'Saved in your main plan.';

  @override
  String get settingsExtraMonthlyTitle => 'Extra monthly amount';

  @override
  String get settingsFinalConfirmBody =>
      'You will lose all debts, payments, milestones, and the current local backup stored in this app.';

  @override
  String get settingsFinalConfirmTitle => 'Final confirmation';

  @override
  String get settingsGoBack => 'Go back';

  @override
  String get settingsCurrentStrategySubtitle =>
      'Open the Plan tab to view the detailed priority order.';

  @override
  String get settingsCurrentStrategyTitle => 'Current strategy';

  @override
  String get settingsLocaleSheetTitle => 'Choose language';

  @override
  String get settingsLocaleSubtitle =>
      'Changes the display language and date formatting.';

  @override
  String get settingsLocaleTitle => 'Language';

  @override
  String get settingsLocalBackupSubtitle =>
      'Create a full JSON backup ZIP to save in Files, Drive, or external storage.';

  @override
  String get settingsLocalBackupTitle => 'Local backup';

  @override
  String get settingsMonthlyLogSubtitle =>
      'Used for monthly log summaries when that flow is enabled.';

  @override
  String get settingsMonthlyLogTitle => 'Monthly log';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get settingsPaymentReminderSubtitle =>
      'The app will use this when payment reminders are enabled.';

  @override
  String get settingsPaymentReminderTitle => 'Payment reminders';

  @override
  String get settingsResetAction => 'Reset';

  @override
  String get settingsRestoreAction => 'Restore';

  @override
  String get settingsRestoreConfirm => 'Restore';

  @override
  String get settingsRestoreDialogDataHeader => 'Data in this backup:';

  @override
  String get settingsRestoreDialogExportedAtLabel => 'Exported at';

  @override
  String get settingsRestoreDialogFileLabel => 'File';

  @override
  String get settingsRestoreDialogTitle => 'Restore from backup?';

  @override
  String get settingsRestoreDialogTotalRecordsLabel => 'Total records';

  @override
  String get settingsRestoreDialogWarning =>
      'All current local data will be replaced.';

  @override
  String get settingsRestoreSubtitle =>
      'Read the manifest preview and row counts before replacing local data.';

  @override
  String get settingsRestoreSuccess =>
      'Local data restored from the selected backup.';

  @override
  String get settingsRestoreTitle => 'Restore from backup';

  @override
  String get settingsSectionData => 'DATA';

  @override
  String get settingsSectionOptions => 'OPTIONS';

  @override
  String get settingsSectionPlan => 'PAYOFF PLAN';

  @override
  String get settingsSectionReminders => 'REMINDERS';

  @override
  String get settingsStrategyAvalanche => 'Avalanche';

  @override
  String get settingsStrategyCustom => 'Custom';

  @override
  String get settingsStrategySnowball => 'Snowball';

  @override
  String get settingsTrustLevelLocalOnlyBody =>
      'You are currently in local-only mode. Cloud backup is the next roadmap step, not a requirement to use the app.';

  @override
  String get settingsTrustLevelLocalOnlyLabel => 'Local only';

  @override
  String get settingsTrustLevelOneBody =>
      'Basic cloud backup is enabled. Local export is still always available.';

  @override
  String get settingsTrustLevelOneLabel => 'Trust 1';

  @override
  String get settingsTrustLevelTwoBody =>
      'A higher trust mode is active. Review sharing permissions before resetting local data.';

  @override
  String get settingsTrustLevelTwoLabel => 'Trust 2';

  @override
  String get settingsVersionFooter => 'Version 1.0.0 (MVP)';

  @override
  String get settingsZipLabel => 'ZIP';

  @override
  String get syncBackupBody =>
      'Your app is currently running in local-only mode. You still have full export, local backup, and restore without an account.';

  @override
  String get syncBackupContinueLocal => 'Keep using local-only';

  @override
  String get syncBackupFreeBulletBackup =>
      'Local backup ZIP for manual storage in Files or Drive';

  @override
  String get syncBackupFreeBulletCsv => 'Full CSV export for Excel or Numbers';

  @override
  String get syncBackupFreeBulletPreview =>
      'Restore preview before replacing local data';

  @override
  String get syncBackupFreeBulletReset =>
      'Clear all / factory reset without losing access to your data';

  @override
  String get syncBackupFreeTitle => 'Already included in Free';

  @override
  String get syncBackupHeadline =>
      'Cloud backup is the next step, not a requirement to use the app.';

  @override
  String get syncBackupPremiumBulletCloud => 'Cloud backup across devices';

  @override
  String get syncBackupPremiumBulletPdf =>
      'PDF reports to print or send to an advisor';

  @override
  String get syncBackupPremiumBulletPricing =>
      'Transparent pricing, no fuzzy trial';

  @override
  String get syncBackupPremiumBulletSharing =>
      'Partner sharing and scenario comparison';

  @override
  String get syncBackupPremiumTitle => 'Premium will add later';

  @override
  String get syncBackupTrustMessage =>
      'Our trust commitment does not change: data starts on-device, no bank linking, and local export stays open even when Premium arrives.';

  @override
  String get syncBackupViewPricing => 'View Free vs Premium';

  @override
  String get welcomeAddFirstDebt => 'Add your first debt';

  @override
  String get welcomeChangeLanguage => 'Change language';

  @override
  String get welcomeSubtitle =>
      'Build a personalized payoff plan in 3 minutes.\nNo account. No bank connection.';

  @override
  String get welcomeTitle => 'Take control of debt,\nfree your future.';

  @override
  String get welcomeTrustFree => 'Free to use';

  @override
  String get welcomeTrustLocalFirst => 'Local-first';

  @override
  String get welcomeTrustNoBankSync => 'No bank sync';
}
