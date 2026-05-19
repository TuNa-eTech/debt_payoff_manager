import 'package:flutter/widgets.dart';

/// Shared keys for app-level smoke tests.
///
/// These keys are intentionally limited to critical-path controls and views so
/// widget tests can target stable nodes without coupling to UI copy or icon
/// order.
class AppTestKeys {
  AppTestKeys._();

  // Onboarding
  static const welcomeAddFirstDebt = ValueKey<String>('welcome:add-first-debt');
  static const welcomeChangeLanguage = ValueKey<String>(
    'welcome:change-language',
  );
  static const onboardingAddAnotherContinue = ValueKey<String>(
    'onboarding:add-another-continue',
  );
  static const onboardingDebtEntryBack = ValueKey<String>(
    'onboarding:debt-entry-back',
  );
  static const onboardingDebtTypeContinue = ValueKey<String>(
    'onboarding:debt-type-continue',
  );
  static const onboardingDebtOptionalDetails = ValueKey<String>(
    'onboarding:debt-optional-details',
  );
  static const onboardingAddAnotherBack = ValueKey<String>(
    'onboarding:add-another-back',
  );
  static const onboardingAddAnotherDebt = ValueKey<String>(
    'onboarding:add-another-debt',
  );
  static const onboardingStrategyBack = ValueKey<String>(
    'onboarding:strategy-back',
  );
  static const onboardingStrategySnowball = ValueKey<String>(
    'onboarding:strategy-snowball',
  );
  static const onboardingStrategyAvalanche = ValueKey<String>(
    'onboarding:strategy-avalanche',
  );
  static const onboardingStrategyContinue = ValueKey<String>(
    'onboarding:strategy-continue',
  );
  static const onboardingExtraPreset100 = ValueKey<String>(
    'onboarding:extra-preset-100',
  );
  static const onboardingExtraAmountInput = ValueKey<String>(
    'onboarding:extra-amount-input',
  );
  static const onboardingExtraBack = ValueKey<String>('onboarding:extra-back');
  static const onboardingExtraContinue = ValueKey<String>(
    'onboarding:extra-continue',
  );
  static const onboardingAhaBack = ValueKey<String>('onboarding:aha-back');
  static const onboardingComplete = ValueKey<String>('onboarding:complete');

  static ValueKey<String> onboardingDebtTypeOption(String type) =>
      ValueKey<String>('onboarding:debt-type:$type');

  static ValueKey<String> onboardingReviewDebtEdit(String debtId) =>
      ValueKey<String>('onboarding:review-debt-edit:$debtId');

  // Debt form
  static const debtFormName = ValueKey<String>('debt-form:name');
  static const debtFormCurrentBalance = ValueKey<String>(
    'debt-form:current-balance',
  );
  static const debtFormOriginalPrincipal = ValueKey<String>(
    'debt-form:original-principal',
  );
  static const debtFormApr = ValueKey<String>('debt-form:apr');
  static const debtFormMinimumPayment = ValueKey<String>(
    'debt-form:minimum-payment',
  );
  static const debtFormDueDay = ValueKey<String>('debt-form:due-day');
  static const debtFormAdvancedToggle = ValueKey<String>(
    'debt-form:advanced-toggle',
  );
  static const debtFormSave = ValueKey<String>('debt-form:save');
  static const debtFormCancel = ValueKey<String>('debt-form:cancel');

  // Main shell
  static const navHomeTab = ValueKey<String>('nav:home');
  static const navDebtsTab = ValueKey<String>('nav:debts');
  static const debtsAddFab = ValueKey<String>('debts:add-fab');
  static const debtsFilterPaidOff = ValueKey<String>('debts:filter-paid-off');
  static const debtsFilterArchived = ValueKey<String>('debts:filter-archived');
  static const settingsCloudBackup = ValueKey<String>(
    'settings:data-cloud-backup',
  );
  static const settingsPaymentReminders = ValueKey<String>(
    'settings:payment-reminders',
  );
  static const settingsMonthlyReminder = ValueKey<String>(
    'settings:monthly-reminder',
  );
  static const settingsMilestoneReminder = ValueKey<String>(
    'settings:milestone-reminder',
  );
  static const settingsMonthlyLog = ValueKey<String>('settings:monthly-log');
  static const settingsReportsPreview = ValueKey<String>(
    'settings:reports-preview',
  );
  static const settingsPremium = ValueKey<String>('settings:premium');
  static const settingsLocale = ValueKey<String>('settings:locale');
  static const settingsLocaleOptionEnglish = ValueKey<String>(
    'settings:locale-option-english',
  );
  static const settingsLocaleOptionVietnamese = ValueKey<String>(
    'settings:locale-option-vietnamese',
  );
  static const syncBackupViewPricing = ValueKey<String>(
    'settings:sync-backup-view-pricing',
  );
  static const syncBackupGoogle = ValueKey<String>(
    'settings:sync-backup-google',
  );
  static const syncBackupApple = ValueKey<String>('settings:sync-backup-apple');
  static const syncBackupDisable = ValueKey<String>(
    'settings:sync-backup-disable',
  );
  static const syncBackupDisableConfirm = ValueKey<String>(
    'settings:sync-backup-disable-confirm',
  );
  static const settingsPartnerSharing = ValueKey<String>(
    'settings:partner-sharing',
  );
  static const partnerSharingGoogle = ValueKey<String>(
    'partner-sharing:google',
  );
  static const partnerSharingApple = ValueKey<String>('partner-sharing:apple');
  static const partnerSharingInvite = ValueKey<String>(
    'partner-sharing:invite',
  );
  static const partnerSharingEmail = ValueKey<String>('partner-sharing:email');
  static const partnerSharingModeReadonly = ValueKey<String>(
    'partner-sharing:mode-readonly',
  );
  static const partnerSharingModeCollaborative = ValueKey<String>(
    'partner-sharing:mode-collaborative',
  );
  static const pricingContinueFree = ValueKey<String>('pricing:continue-free');
  static const pricingMonthlyProduct = ValueKey<String>(
    'pricing:product-monthly',
  );
  static const pricingYearlyProduct = ValueKey<String>(
    'pricing:product-yearly',
  );
  static const pricingPurchasePremium = ValueKey<String>(
    'pricing:purchase-premium',
  );
  static const pricingRestorePurchases = ValueKey<String>(
    'pricing:restore-purchases',
  );
  static const pricingDebugClearPremium = ValueKey<String>(
    'pricing:debug-clear-premium',
  );
  static const pricingDebugManageSubscription = ValueKey<String>(
    'pricing:debug-manage-subscription',
  );
  static const settingsDataExportCsv = ValueKey<String>(
    'settings:data-export-csv',
  );
  static const settingsDataLocalBackup = ValueKey<String>(
    'settings:data-local-backup',
  );
  static const settingsDataRestoreBackup = ValueKey<String>(
    'settings:data-restore-backup',
  );
  static const settingsDataClearAll = ValueKey<String>(
    'settings:data-clear-all',
  );
  static const settingsDataRestoreConfirm = ValueKey<String>(
    'settings:data-restore-confirm',
  );
  static const settingsDataClearAllConfirmOne = ValueKey<String>(
    'settings:data-clear-all-confirm-one',
  );
  static const settingsDataClearAllConfirmTwo = ValueKey<String>(
    'settings:data-clear-all-confirm-two',
  );

  // Debt detail / actions
  static const debtDetailEdit = ValueKey<String>('debt-detail:edit');
  static const debtDetailMore = ValueKey<String>('debt-detail:more');
  static const debtDetailLogPayment = ValueKey<String>(
    'debt-detail:log-payment',
  );
  static const debtDetailAddCharge = ValueKey<String>('debt-detail:add-charge');
  static const debtDetailPaymentHistory = ValueKey<String>(
    'debt-detail:payment-history',
  );
  static const debtOptionArchive = ValueKey<String>('debt-option:archive');
  static const debtOptionUnarchive = ValueKey<String>('debt-option:unarchive');
  static const debtOptionPause = ValueKey<String>('debt-option:pause');
  static const debtOptionResume = ValueKey<String>('debt-option:resume');
  static const debtOptionDelete = ValueKey<String>('debt-option:delete');
  static const dialogConfirmPrimary = ValueKey<String>(
    'dialog:confirm-primary',
  );
  static const snackbarUndo = ValueKey<String>('snackbar:undo');

  // Phase 4 payments / monthly action
  static const paymentLogAmount = ValueKey<String>('payment-log:amount');
  static const paymentLogDate = ValueKey<String>('payment-log:date');
  static const paymentLogSubmit = ValueKey<String>('payment-log:submit');
  static const addChargeAmount = ValueKey<String>('add-charge:amount');
  static const addChargeNote = ValueKey<String>('add-charge:note');
  static const addChargeSubmit = ValueKey<String>('add-charge:submit');
  static const paymentTypeMinimum = ValueKey<String>(
    'payment-log:type-minimum',
  );
  static const paymentTypeExtra = ValueKey<String>('payment-log:type-extra');
  static const paymentTypeLumpSum = ValueKey<String>(
    'payment-log:type-lumpsum',
  );

  static ValueKey<String> monthlyActionSection(String debtId) =>
      ValueKey<String>('monthly-action:section:$debtId');

  static ValueKey<String> monthlyActionItem(String actionId) =>
      ValueKey<String>('monthly-action:item:$actionId');

  static ValueKey<String> monthlyActionCheckOff(String actionId) =>
      ValueKey<String>('monthly-action:checkoff:$actionId');

  static const monthlyActionEmptyAddDebt = ValueKey<String>(
    'monthly-action:empty-add-debt',
  );
  static const monthlyActionNextAction = ValueKey<String>(
    'monthly-action:next-action',
  );
  static const monthlyActionDoneDashboard = ValueKey<String>(
    'monthly-action:done-dashboard',
  );
  static const monthlyActionSingleDebtCard = ValueKey<String>(
    'monthly-action:single-debt-card',
  );
  static const monthlyActionCompletedChecklistToggle = ValueKey<String>(
    'monthly-action:completed-checklist-toggle',
  );
  static ValueKey<String> monthlyActionNextCheckOff(String actionId) =>
      ValueKey<String>('monthly-action:next-checkoff:$actionId');
  static const monthlyActionConfirmSheet = ValueKey<String>(
    'monthly-action:confirm-sheet',
  );
  static const monthlyActionConfirmPrimary = ValueKey<String>(
    'monthly-action:confirm-primary',
  );
  static const monthlyActionConfirmCustom = ValueKey<String>(
    'monthly-action:confirm-custom',
  );

  static ValueKey<String> paymentHistoryMonthChip(String yearMonth) =>
      ValueKey<String>('payment-history:month:$yearMonth');

  static ValueKey<String> timelineMonthCard(int monthIndex) =>
      ValueKey<String>('timeline:month:$monthIndex');

  static ValueKey<String> debtCard(String id) =>
      ValueKey<String>('debt-card:$id');

  static ValueKey<String> debtDetail(String id) =>
      ValueKey<String>('debt-detail:$id');

  static ValueKey<String> settingsReminderDayOption(int days) =>
      ValueKey<String>('settings:reminder-days:$days');

  static ValueKey<String> reportsPreviewRange(String range) =>
      ValueKey<String>('reports-preview:range:$range');

  static const reportsPreviewExport = ValueKey<String>(
    'reports-preview:export',
  );
}
