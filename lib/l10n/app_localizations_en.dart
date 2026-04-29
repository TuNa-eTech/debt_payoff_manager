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
  String get whatCanYouDoNow => 'What can you do right now?';

  @override
  String debtDueDay(Object day) {
    return 'Day $day';
  }

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
  String get debtStatusActive => 'Active';

  @override
  String get debtStatusPaidOff => 'Paid off';

  @override
  String get debtStatusArchived => 'Archived';

  @override
  String get debtStatusPaused => 'Paused';

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
  String get homeTotalBalanceLabel => 'Current total balance';

  @override
  String homePaidProgress(Object amount) {
    return 'Paid $amount';
  }

  @override
  String get homeTrackingCountLabel => 'Tracking';

  @override
  String get homePaidOffCountLabel => 'Paid off';

  @override
  String get homePausedCountLabel => 'Paused';

  @override
  String get homeDebtsToTrackTitle => 'Debts to track';

  @override
  String get homeDebtsToTrackSubtitle =>
      'This list is pulled directly from your saved data.';

  @override
  String get homeNoDebtsToTrackMessage => 'No debts to track yet.';

  @override
  String get homeTimelineConnectingTitle => 'Detailed timeline is connecting';

  @override
  String get homeTimelineConnectingSubtitle =>
      'You have enough background data to visit the Plan tab and see your current setup. The debt-free date and detailed projections will appear when the plan simulation is enabled.';

  @override
  String get homeOpenPlanTabButton => 'Open Plan tab';

  @override
  String get homeEmptyTitle => 'No debts yet';

  @override
  String get homeEmptySubtitle =>
      'Add your first debt for the app to start saving data and building your payoff plan.';

  @override
  String get homeFeatureMultiDebtTitle => 'Enter multiple debt types';

  @override
  String get homeFeatureMultiDebtSubtitle =>
      'Credit cards, student loans, car loans, mortgages, and more.';

  @override
  String get homeFeatureEditAnytimeTitle => 'Edit anytime';

  @override
  String get homeFeatureEditAnytimeSubtitle =>
      'All changes are saved locally and reflected in your debt list.';

  @override
  String get homeFeatureLocalFirstTitle => 'Local-first';

  @override
  String get homeFeatureLocalFirstSubtitle =>
      'You don\'t need an account to start and your data stays on your device.';

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
  String get monthlyActionDoneProofTitle => 'This month is done';

  @override
  String monthlyActionDoneProofSubtitle(String amount) {
    return 'Logged $amount this month.';
  }

  @override
  String monthlyActionDoneProofSingleRemaining(
    String debtName,
    String balance,
  ) {
    return '$debtName has $balance remaining.';
  }

  @override
  String monthlyActionDoneProofSinglePaidOff(String debtName) {
    return '$debtName is paid off.';
  }

  @override
  String get monthlyActionStatLogged => 'Logged';

  @override
  String get monthlyActionStatRemaining => 'Remaining';

  @override
  String get monthlyActionStatLatestLogged => 'Latest';

  @override
  String get monthlyActionNoLoggedDate => 'None';

  @override
  String get monthlyActionViewHistory => 'View history';

  @override
  String get monthlyActionLogAnother => 'Log another';

  @override
  String get monthlyActionViewProgress => 'View progress';

  @override
  String get monthlyActionAddAnotherDebt => 'Add another debt';

  @override
  String get monthlyActionSingleDebtTitle => 'This debt';

  @override
  String get monthlyActionSingleDebtPaidOffTitle => 'This debt is paid off';

  @override
  String get monthlyActionSingleDebtRemainingLabel => 'Remaining balance';

  @override
  String get monthlyActionSingleDebtDueDateLabel => 'Due date';

  @override
  String get monthlyActionSingleDebtStatusLabel => 'Status';

  @override
  String monthlyActionCompletedChecklistTitle(int completed, int total) {
    return 'Completed $completed/$total';
  }

  @override
  String monthlyActionLoggedProof(String amount, String date) {
    return 'Logged $amount on $date';
  }

  @override
  String get monthlyActionNextPay => 'Next to pay';

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
  String get monthlyActionMinimumSubtitle => 'Required payment for this debt.';

  @override
  String get monthlyActionExtraSubtitle =>
      'Suggested extra payment to finish sooner.';

  @override
  String monthlyActionExtraPrioritySubtitle(int rank) {
    return 'Priority #$rank extra payment to finish sooner.';
  }

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
  String get monthlyActionConfirmPrimary => 'Confirm paid';

  @override
  String get monthlyActionLogDifferent => 'Log a different payment';

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
  String get logPaymentNoteHint => 'E.g. autopay, bonus, extra payment';

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
  String get settingsMonthlyReminderTitle => 'End-of-month reminder';

  @override
  String get settingsMonthlyReminderSubtitle =>
      'Get one reminder near month end if payments still need to be logged.';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get settingsReminderDaysTitle => 'Days before due date';

  @override
  String get settingsReminderDaysSubtitle =>
      'Choose how early the due-date reminder should arrive.';

  @override
  String get settingsPaymentReminderSubtitle =>
      'The app will use this when payment reminders are enabled.';

  @override
  String get settingsPaymentReminderTitle => 'Payment reminders';

  @override
  String get notificationPaymentDueTitle => 'Payment Reminder';

  @override
  String notificationPaymentDueBody(String debtName) {
    return 'Your loan \"$debtName\" is due soon.';
  }

  @override
  String get notificationMonthlyLogTitle => 'Monthly check-in';

  @override
  String get notificationMonthlyLogBody =>
      'Open your plan and make sure this month\'s payments are fully logged before the month closes.';

  @override
  String get notificationMilestoneTitle => 'Milestone reached';

  @override
  String get notificationMilestoneBody =>
      'You unlocked a new payoff milestone. Open Progress to review your latest win.';

  @override
  String get settingsMilestoneReminderTitle => 'Milestone alerts';

  @override
  String get settingsMilestoneReminderSubtitle =>
      'Celebrate payoff progress when a new milestone is reached.';

  @override
  String get settingsNotificationPermissionRequired =>
      'Notification permission is required to enable this reminder.';

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
  String get settingsSectionReports => 'REPORTS';

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
  String get settingsReportsPreviewTitle => 'Report preview';

  @override
  String get settingsReportsPreviewSubtitle =>
      'Preview monthly, yearly, or full-history PDF exports before sharing.';

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
      'Sign in to back up this device to your private cloud mirror. Local export, local backup, and restore stay available.';

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
  String get syncBackupHeadline => 'Turn on cloud backup';

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
  String get syncBackupDisable => 'Disable cloud backup';

  @override
  String get syncBackupDisableConfirm => 'Delete cloud backup';

  @override
  String get syncBackupDisableDialogBody =>
      'This stops sync, deletes your cloud mirror, and keeps all data on this device.';

  @override
  String get syncBackupDisableDialogTitle => 'Disable cloud backup?';

  @override
  String get syncBackupDisableSuccess =>
      'Cloud backup is disabled. Your local data is unchanged.';

  @override
  String get syncBackupEnableSuccess => 'Cloud backup is enabled.';

  @override
  String get syncBackupEnabledBody =>
      'This device is connected to your private backup. Changes continue to sync when the app is online.';

  @override
  String get syncBackupEnabledHeadline => 'Cloud backup is on';

  @override
  String get syncBackupLastSynced => 'Last synced';

  @override
  String get syncBackupLastSyncedPending => 'Waiting for first sync';

  @override
  String get syncBackupSignedInAs => 'Signed in as';

  @override
  String get syncBackupSignInApple => 'Continue with Apple';

  @override
  String get syncBackupSignInGoogle => 'Continue with Google';

  @override
  String get syncBackupStatus => 'Status';

  @override
  String get syncBackupStatusEnabled => 'Enabled';

  @override
  String get syncBackupSyncing => 'Syncing';

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

  @override
  String get planExtraAmountSheetTitle => 'Extra amount';

  @override
  String get planExtraAmountSheetSubtitle =>
      'Increasing your extra monthly payment helps you shorten your debt-free timeline significantly.';

  @override
  String get planExtraAmountSheetSave => 'Save changes';

  @override
  String get planExtraAmountSheetReset => 'Reset to \$0 (Minimum)';

  @override
  String get planTimelineTitle => 'Plan';

  @override
  String get planTimelineEmptyTitle => 'No plan to show yet';

  @override
  String get planTimelineEmptySubtitle =>
      'Add at least one debt so the app can recast your timeline, debt-free date, and projected interest.';

  @override
  String get planTimelineAllPaidTitle => 'All debts are paid off';

  @override
  String get planTimelineAllPaidSubtitle =>
      'Monthly timeline has no active debts. The app keeps your last plan summary for reference.';

  @override
  String get planTimelineRecasting => 'Recasting...';

  @override
  String planTimelineStrategySummary(
    String strategy,
    String amount,
    int months,
  ) {
    return '$strategy · Extra $amount / month · $months months projected';
  }

  @override
  String get planTimelineRecastNeutral =>
      'Plan was just recast from latest data.';

  @override
  String get planTimelineComparisonTitle => 'Projected vs minimum-only';

  @override
  String get planTimelineComparisonCurrent => 'Current plan';

  @override
  String get planTimelineComparisonBaseline => 'Minimum-only baseline';

  @override
  String get planTimelineComparisonSaved => 'Saved interest';

  @override
  String get planTimelineSectionTitle => 'Monthly timeline';

  @override
  String get planTimelineSectionSubtitle =>
      'List-first view with payment breakdown, ending balance, and milestone payoff based on the latest projection.';

  @override
  String get planTimelineHeroDebtFree => 'Debt-free date';

  @override
  String get planTimelineHeroProjectedInterest => 'Projected interest';

  @override
  String get planTimelineHeroSavedVsMinimum => 'Saved vs minimum';

  @override
  String get planTimelineMonthEndingBalance => 'Ending balance';

  @override
  String get planTimelineMonthDebtsPaidOff => 'Debts paid off';

  @override
  String get planTimelineMonthStartingBalance => 'Starting balance';

  @override
  String get planTimelineMonthInterestAccrued => 'Interest accrued';

  @override
  String get planTimelineMonthPaymentApplied => 'Payment applied';

  @override
  String get planTimelineMonthPaymentLabel => 'Payment';

  @override
  String get planTimelineMonthInterestLabel => 'Interest';

  @override
  String get planTimelinePaidOffBadge => 'Paid off';

  @override
  String get onboardingDebtEntryTitle => 'Add Your First Debt';

  @override
  String get onboardingDebtEntrySave => 'Save Debt';

  @override
  String get onboardingStep1 => 'Step 1/4';

  @override
  String get onboardingAddAnotherTitle => 'Review Your Debts';

  @override
  String get onboardingStep2 => 'Step 2/4';

  @override
  String get onboardingAddAnotherEmpty => 'You haven\'t saved any debts yet.';

  @override
  String onboardingAddAnotherCount(int count) {
    return 'You have saved $count debts. You can add more or continue to strategy selection.';
  }

  @override
  String get onboardingAddAnotherRequirement =>
      'Please add at least 1 debt to continue onboarding.';

  @override
  String get onboardingAddAnotherContinue => 'Choose Strategy';

  @override
  String get onboardingAddAnotherAddMore => 'Add Another Debt';

  @override
  String get onboardingStrategyTitle => 'Choose Strategy';

  @override
  String get onboardingStep3 => 'Step 3/4';

  @override
  String get onboardingStrategySubtitle =>
      'Choose how the app prioritizes debts when you pay extra.';

  @override
  String get onboardingStrategyRequirement =>
      'You need at least one debt to choose a strategy.';

  @override
  String get onboardingStrategyDescription =>
      'The app is comparing live projections of Snowball and Avalanche based on your current debts.';

  @override
  String get onboardingStrategyEmptyTitle => 'No debts to apply strategy';

  @override
  String get onboardingStrategyEmptySubtitle =>
      'Please add at least one debt before continuing.';

  @override
  String get onboardingStrategyBackToAdd => 'Go back and add debt';

  @override
  String get onboardingStrategySnowballFallback =>
      'Prioritize the smallest balance.';

  @override
  String get onboardingStrategyAvalancheFallback =>
      'Prioritize the highest APR to reduce interest.';

  @override
  String get onboardingStrategyChangeNote =>
      'You can change your strategy anytime after onboarding. The plan summary and timeline will recast automatically.';

  @override
  String get onboardingStrategyContinue => 'Save Strategy & Continue';

  @override
  String get onboardingStrategyTopPriorityExcluded =>
      'All debts are currently excluded from the strategy.';

  @override
  String onboardingStrategyTopPriority(String name) {
    return 'Start with $name';
  }

  @override
  String get onboardingStrategyPreviewCalculating =>
      'Calculating payoff date and projected interest from current data...';

  @override
  String get onboardingStrategyPreviewRecasting => 'Recasting';

  @override
  String onboardingStrategyPreviewSummary(
    String date,
    String duration,
    String interest,
  ) {
    return 'Debt-free $date · $duration · interest $interest';
  }

  @override
  String onboardingStrategyPreviewSaved(String saved) {
    return 'Save $saved vs minimum-only';
  }

  @override
  String get onboardingStrategyError =>
      'Could not save strategy. Please try again.';

  @override
  String get onboardingStrategyPreviewTitle => 'Current Preview';

  @override
  String get onboardingExtraTitle => 'Extra Budget';

  @override
  String get onboardingStep4 => 'Step 4/4';

  @override
  String get onboardingExtraSubtitle =>
      'Besides the minimum, how much extra do you want to pay each month?';

  @override
  String get onboardingExtraDescription =>
      'Default is \$0. Preview will live recast after 300ms to show your actual debt-free date and saved interest.';

  @override
  String get onboardingExtraMonthlyLabel => 'Extra payment per month';

  @override
  String onboardingExtraTrackedCount(String strategy, int count) {
    return '$strategy · Tracking $count debts';
  }

  @override
  String get onboardingExtraMaxLabel => 'Max';

  @override
  String get onboardingExtraWhatsNextTitle => 'What happens next?';

  @override
  String get onboardingExtraWhatsNextDescription =>
      'This extra amount will be used as additional budget each month. When you save, your plan summary and timeline cache will recast immediately.';

  @override
  String get onboardingExtraSave => 'Save and view summary';

  @override
  String get onboardingExtraUseZero => 'Use \$0 for now';

  @override
  String get onboardingExtraError =>
      'Could not save extra budget. Please try again.';

  @override
  String get onboardingExtraPreviewEmpty =>
      'Add at least one debt to see the actual payoff preview.';

  @override
  String get onboardingExtraPreviewTitle => 'Live preview';

  @override
  String get onboardingExtraPreviewRecasting => 'Recasting...';

  @override
  String onboardingExtraPreviewDebtFree(String extraAmount) {
    return 'Debt-free date with extra $extraAmount / month';
  }

  @override
  String get onboardingExtraPreviewProjectedInterest => 'Projected interest';

  @override
  String get onboardingExtraPreviewSavedVsMinimum => 'Saved vs minimum';

  @override
  String get onboardingAhaEmpty => 'You have no debts in your plan yet.';

  @override
  String get onboardingAhaRecasting => 'Your plan is recasting.';

  @override
  String onboardingAhaDebtFree(String date) {
    return 'You can be debt-free by $date.';
  }

  @override
  String get onboardingAhaEmptySubtitle =>
      'Please go back to the previous step and add at least one debt.';

  @override
  String get onboardingAhaReadySubtitle =>
      'Plan has been recast. Your monthly checklist is ready.';

  @override
  String get onboardingAhaSummaryTitle => 'Current Summary';

  @override
  String get onboardingAhaTotalBalance => 'Total Balance';

  @override
  String get onboardingAhaTrackedCount => 'Tracked Debts';

  @override
  String get onboardingAhaDataCompact =>
      'Data saved locally. No account needed.';

  @override
  String get onboardingAhaDataFull =>
      'Your data is saved locally on your device. From here you can open the Monthly Action View to check off actual payments and watch the timeline recast instantly.';

  @override
  String get onboardingAhaBackToAdd => 'Go back to add debt';

  @override
  String get onboardingAhaOpenMonthly => 'Open Monthly Action View';

  @override
  String get onboardingAhaRecastingShort => 'Recasting';

  @override
  String get onboardingAhaDebtFreeDate => 'Debt-free date';

  @override
  String get onboardingAhaExtraMonthly => 'Extra / month';

  @override
  String get onboardingAhaProjectedInterest => 'Projected interest';

  @override
  String get onboardingAhaSavedVsMinimum => 'Saved vs minimum';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonTotalDebt => 'Total Debt';

  @override
  String get commonNotes => 'Notes';

  @override
  String get debtDetailTitle => 'Debt Details';

  @override
  String get debtDetailInitialPrincipal => 'Initial Principal';

  @override
  String get debtDetailApr => 'APR';

  @override
  String get debtDetailDueDate => 'Due Date';

  @override
  String get debtDetailMinimumPayment => 'Minimum payment';

  @override
  String get debtDetailInterestCalc => 'Interest Calculation';

  @override
  String get debtDetailLogPayment => 'Log payment';

  @override
  String get debtDetailViewHistory => 'View history';

  @override
  String get debtDetailArchiveTitle => 'Archive Debt?';

  @override
  String get debtDetailArchivedMsg => 'Debt archived.';

  @override
  String get debtDetailUnarchivedMsg => 'Debt restored to paid list.';

  @override
  String get debtDetailDeleteTitle => 'Delete Debt?';

  @override
  String get debtDetailDeletedMsg => 'Debt deleted.';

  @override
  String get debtsListTitle => 'Debts';

  @override
  String get debtsListFilterAll => 'All';

  @override
  String get debtsListFilterActive => 'Active';

  @override
  String get debtsListFilterPaid => 'Paid';

  @override
  String get debtsListFilterArchived => 'Archived';

  @override
  String get logPaymentNotFound =>
      'This debt no longer exists or has been deleted.';

  @override
  String get paymentHistoryTitle => 'Payment History';

  @override
  String get paymentHistoryNoPayments => 'No payments for this filter';

  @override
  String get debtOptionsEdit => 'Edit debt';

  @override
  String get debtOptionsPause => 'Pause payments';

  @override
  String get debtOptionsPauseSubtitle => 'Temporarily stop payments';

  @override
  String get debtOptionsResume => 'Resume payments';

  @override
  String debtOptionsResumeSubtitle(Object date) {
    return 'Auto-resumes on $date';
  }

  @override
  String get debtPauseSelectDuration => 'Select pause duration';

  @override
  String get debtPause1Month => '1 month';

  @override
  String get debtPause2Months => '2 months';

  @override
  String get debtPause3Months => '3 months';

  @override
  String get debtPause6Months => '6 months';

  @override
  String debtPausedMsg(Object date) {
    return 'Paused until $date';
  }

  @override
  String get debtResumedMsg => 'Resumed payments';

  @override
  String debtsListPausedSection(Object count) {
    return 'Paused ($count)';
  }

  @override
  String debtPausedUntil(Object date) {
    return 'Paused until $date';
  }

  @override
  String get debtPausedIndefinitely => 'Paused indefinitely';

  @override
  String get debtResumeNow => 'Resume now';

  @override
  String get debtDetailRateHistory => 'Interest rates';

  @override
  String get rateHistoryTitle => 'Interest Rate History';

  @override
  String get rateHistoryEmpty => 'No rate history';

  @override
  String get rateHistoryEmptySubtitle =>
      'Interest rate will appear here when changed';

  @override
  String get rateHistoryCurrent => 'Current';

  @override
  String get rateHistoryAddTitle => 'Add Rate Change';

  @override
  String get rateHistoryEditTitle => 'Edit Rate Change';

  @override
  String get rateHistoryAprLabel => 'APR (%)';

  @override
  String get rateHistoryAprInvalid => 'Enter a valid APR (0-100%)';

  @override
  String get rateHistoryEffectiveFrom => 'Effective from';

  @override
  String get rateHistoryEffectiveTo => 'Effective to (optional)';

  @override
  String rateHistoryEffectiveFromOnly(Object date) {
    return 'From $date';
  }

  @override
  String rateHistoryEffectiveToPeriod(Object from, Object to) {
    return '$from — $to';
  }

  @override
  String get rateHistoryReason => 'Reason';

  @override
  String get rateHistoryReasonHint => 'e.g., Promo expired, Refinanced';

  @override
  String get rateHistoryDeleteTitle => 'Delete rate?';

  @override
  String get rateHistoryDeleteMessage =>
      'This will permanently delete this rate history entry.';

  @override
  String get rateHistoryDeletedMsg => 'Rate history deleted';

  @override
  String get rateHistoryOpenEnded => 'No end date (current rate)';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonSave => 'Save';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonError => 'Error';

  @override
  String get debtOptionsDelete => 'Delete debt';

  @override
  String get debtOptionsDeleteSubtitle =>
      'You can restore it right after deleting.';

  @override
  String get editDebtTitle => 'Edit Debt';

  @override
  String get monthlyActionThisMonth => 'This month';

  @override
  String get monthlyActionNoChecklist => 'No checklist for this month';

  @override
  String get monthlyActionNeedToPay => 'What you need to pay this month';

  @override
  String get monthlyActionTotalThisMonth => 'Total this month';

  @override
  String get monthlyActionCompleted => 'Completed';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressNoProgress => 'No progress to show yet';

  @override
  String get progressByDebt => 'Progress by debt';

  @override
  String get progressPlanSummary => 'Plan summary';

  @override
  String get progressDebtFreeDate => 'Debt-free date';

  @override
  String get progressProjectedInterest => 'Projected interest';

  @override
  String get progressSavedVsMinimum => 'Saved vs minimum';

  @override
  String get debtDetailInfo => 'Debt Info';

  @override
  String get debtDetailWarnings => 'Data Warnings';

  @override
  String get debtDetailTracking => 'Payment Tracking';

  @override
  String get debtDetailTrackingHelper =>
      'Log real payments to reduce current balance, create an audit trail, and instantly recast your timeline.';

  @override
  String get debtDetailAddCharge => 'Add Charge';

  @override
  String get newChargeDialogTitle => 'Log New Charge';

  @override
  String get newChargeAmountLabel => 'Charge Amount';

  @override
  String get newChargeNoteLabel => 'Note (optional)';

  @override
  String get newChargeSave => 'Save Charge';

  @override
  String get newChargeSuccess => 'New charge added.';

  @override
  String get newChargeErrorInvalid => 'Please enter a valid amount.';

  @override
  String get debtDetailArchiveMessage =>
      'This paid-off debt will be moved to the archive.';

  @override
  String get debtDetailArchiveConfirm => 'Archive';

  @override
  String get debtDetailDeleteMessage =>
      'This debt will be hidden, but you can recover it right after deleting.';

  @override
  String get debtDetailDeleteConfirm => 'Delete';

  @override
  String get debtsListSectionAll => 'All debts';

  @override
  String get debtsListSectionActive => 'Active debts';

  @override
  String get debtsListSectionPaidOff => 'Paid-off debts';

  @override
  String get debtsListSectionArchived => 'Archived debts';

  @override
  String get debtsListEmptyAll => 'You have no debts. Add your first one.';

  @override
  String get debtsListEmptyActive => 'You have no active debts being tracked.';

  @override
  String get debtsListEmptyPaidOff => 'You have no paid-off debts.';

  @override
  String get debtsListEmptyArchived => 'You have no archived debts.';

  @override
  String get logPaymentHelperAmount =>
      'Amount reduces current balance directly (balance-first model).';

  @override
  String get logPaymentAuditHelper =>
      'This payment will create an audit trail with balance before/after and recast timeline immediately after saving.';

  @override
  String get logPaymentErrorInvalidAmount =>
      'Please enter a valid amount greater than 0.';

  @override
  String get monthlyActionNoChecklistSubtitle =>
      'All your tracked debts are paid off or paused. Timeline is still recast from latest data.';

  @override
  String get monthlyActionChecklistHelper =>
      'This checklist is computed directly from your strategy, timeline cache, and payment history.';

  @override
  String get monthlyActionRecasting => 'Recasting...';

  @override
  String monthlyActionInMonth(String monthYear) {
    return 'In $monthYear';
  }

  @override
  String get monthlyActionLogged => 'Logged';

  @override
  String get monthlyActionCheckOff => 'Check off';

  @override
  String get progressEmptySubtitle =>
      'Add your first debt so the app can start tracking your completion.';

  @override
  String get progressPaidSoFar => 'Paid so far';

  @override
  String progressRemainingAmount(String amount) {
    return 'Remaining $amount';
  }

  @override
  String get progressOverall => 'Overall progress';

  @override
  String get progressTabHelper =>
      'Progress here combines actual balance and recast plan summary. The previous overview from Home has been moved to this tab.';

  @override
  String get progressByDebtHelper =>
      'Based on current balance versus original principal for each debt.';

  @override
  String progressStreakMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count month streak',
      one: '1 month streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get progressInterestSaved => 'Interest saved';

  @override
  String get progressAchievements => 'Achievements';

  @override
  String get milestoneCelebrationFirstPayment => 'First payment made!';

  @override
  String get milestoneCelebrationDebtPaidOff => 'Debt paid off!';

  @override
  String get milestoneCelebrationAllDebtFree => 'All debt-free!';

  @override
  String get milestoneCelebrationProgress25 => '25% there!';

  @override
  String get milestoneCelebrationProgress50 => 'Halfway there!';

  @override
  String get milestoneCelebrationProgress75 => '75% complete!';

  @override
  String get milestoneCelebrationStreak3 => '3-month streak!';

  @override
  String get milestoneCelebrationStreak6 => '6-month streak!';

  @override
  String get milestoneCelebrationStreak12 => '1 year streak!';

  @override
  String get progressDebtPaidOffStatus => 'This debt is marked as paid off.';

  @override
  String get progressDebtPausedStatus => 'This debt is paused.';

  @override
  String progressDebtRemainingVsOriginal(String current, String original) {
    return 'Remaining $current out of $original principal';
  }

  @override
  String paymentHistorySubtitle(int count, String balance) {
    return '$count payments logged · Current balance $balance';
  }

  @override
  String get paymentHistoryByMonth => 'By month';

  @override
  String get paymentHistoryNoPaymentsSubtitle =>
      'Log payments from debt details or Monthly Action View to see actual history.';

  @override
  String get paymentTypeFeeLabel => 'Fee adjustment';

  @override
  String get paymentTypeRefundLabel => 'Refund';

  @override
  String get paymentTypeChargeLabel => 'Charge';

  @override
  String get debtOptionsUnarchive => 'Unarchive';

  @override
  String get debtOptionsArchive => 'Archive debt';

  @override
  String get addDebtTitle => 'Add Debt';

  @override
  String get addDebtSave => 'Save debt';

  @override
  String get addDebtSaveChanges => 'Save changes';

  @override
  String get commonMonth => 'month';

  @override
  String get reportsPreviewReportSummary => 'Report Summary';

  @override
  String get reportsPreviewTotalPaid => 'Total Paid';

  @override
  String get reportsPreviewTotalInterest => 'Total Interest';

  @override
  String get reportsPreviewDebtFreeDate => 'Debt Free Date';

  @override
  String get reportsPreviewGenerating => 'Generating...';

  @override
  String get reportsPreviewExportToPdf => 'Export to PDF';

  @override
  String get reportsPreviewNotAvailable => 'N/A';

  @override
  String get reportsPreviewPageTitle => 'Reports';

  @override
  String get reportsPreviewRangeTitle => 'Report range';

  @override
  String get reportsPreviewRangeMonthly => 'Monthly';

  @override
  String get reportsPreviewRangeYearly => 'Yearly';

  @override
  String get reportsPreviewRangeFullHistory => 'Full history';

  @override
  String get reportsPreviewTableTitle => 'Preview rows';

  @override
  String reportsPreviewGenerateFailed(String message) {
    return 'Could not generate the report: $message';
  }

  @override
  String get reportsPdfAppTitle => 'Debt Payoff Manager';

  @override
  String get reportsPdfAmortizationTitle => 'Amortization report';

  @override
  String get reportsPdfGeneratedOnLabel => 'Generated on';

  @override
  String reportsPdfPageXOfY(int pageNumber, int pagesCount) {
    return 'Page $pageNumber of $pagesCount';
  }

  @override
  String get reportsPdfColMonth => 'Month';

  @override
  String get reportsPdfColPayment => 'Payment';

  @override
  String get reportsPdfColPrincipal => 'Principal';

  @override
  String get reportsPdfColInterest => 'Interest';

  @override
  String get reportsPdfColBalance => 'Balance';

  @override
  String get scenariosTitle => 'What-If Scenarios';

  @override
  String get scenariosEmptyTitle => 'No scenarios yet';

  @override
  String get scenariosEmptySubtitle =>
      'Create a scenario to explore different payoff strategies side by side.';

  @override
  String get scenariosAddTitle => 'New scenario';

  @override
  String get scenariosNameHint => 'Scenario name';

  @override
  String get scenariosDuplicateTitle => 'Duplicate scenario';

  @override
  String get scenariosActiveBadge => 'Active';

  @override
  String get scenariosMainBadge => 'Main';

  @override
  String get scenariosDeleteConfirm => 'Delete scenario';

  @override
  String get scenariosDeleteMessage =>
      'This scenario and its debts will be deleted. Payments are not affected.';

  @override
  String get scenariosCompareTitle => 'Compare Scenarios';

  @override
  String get scenariosComparePickPrompt => 'Select a scenario to compare';

  @override
  String get scenariosCompareSelectA => 'Scenario A';

  @override
  String get scenariosCompareSelectB => 'Scenario B';

  @override
  String get scenariosCompareDebtFreeDate => 'Debt-free date';

  @override
  String get scenariosCompareTotalBalance => 'Total balance';

  @override
  String get scenariosCompareProjectedInterest => 'Projected interest';

  @override
  String get scenariosCompareSavedVsMinimum => 'Saved vs minimum';

  @override
  String get scenariosCompareTotalDebts => 'Debts tracked';

  @override
  String get scenariosCompareNoPlan => 'No plan yet';

  @override
  String get scenariosCompareNotAvailable => '—';

  @override
  String scenariosCompareFaster(int months) {
    return '$months mo faster';
  }

  @override
  String scenariosCompareCheaper(String amount) {
    return '$amount less interest';
  }

  @override
  String get scenariosCompareAction => 'Compare';

  @override
  String get scenariosCopyDebtsTitle => 'Copy debts to another scenario';

  @override
  String scenariosCopyDebtsMessage(String source, String target) {
    return 'Debts from \'$source\' will be copied to \'$target\'. Existing debts in the target are kept. Payments are not copied.';
  }

  @override
  String get scenariosCopyDebtsConfirm => 'Copy debts';

  @override
  String get scenariosCopyDebtsSuccess => 'Debts copied successfully';

  @override
  String scenariosCompareDeltaTitle(String name) {
    return '$name is the better choice';
  }

  @override
  String scenariosCompareDeltaMonths(int months) {
    return 'Debt-free $months months earlier';
  }

  @override
  String scenariosCompareDeltaInterest(String amount) {
    return 'Saves $amount in interest';
  }

  @override
  String get scenariosCompareTie => 'Both scenarios are equivalent';

  @override
  String get monthlySummaryTitle => 'Monthly Summary';

  @override
  String get monthlySummaryTotalPaid => 'Total Paid';

  @override
  String get monthlySummaryPrincipal => 'Principal';

  @override
  String get monthlySummaryInterest => 'Interest';

  @override
  String get monthlySummaryCharges => 'New Charges';

  @override
  String get monthlySummaryPerDebt => 'By Debt';

  @override
  String get monthlySummaryNoActivity => 'No payments recorded this month';

  @override
  String get monthlySummaryNoActivitySub =>
      'Log a payment to see your progress here.';

  @override
  String monthlySummaryPaidMore(String amount) {
    return 'Paid $amount more than planned';
  }

  @override
  String monthlySummaryPaidLess(String amount) {
    return 'Paid $amount less than planned';
  }

  @override
  String monthlySummaryBalanceReduced(String amount) {
    return 'Balance reduced by $amount';
  }
}
