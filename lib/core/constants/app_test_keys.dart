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
  static const onboardingAddAnotherContinue = ValueKey<String>(
    'onboarding:add-another-continue',
  );
  static const onboardingDebtEntryBack = ValueKey<String>(
    'onboarding:debt-entry-back',
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
  static const onboardingExtraBack = ValueKey<String>('onboarding:extra-back');
  static const onboardingExtraContinue = ValueKey<String>(
    'onboarding:extra-continue',
  );
  static const onboardingAhaBack = ValueKey<String>('onboarding:aha-back');
  static const onboardingComplete = ValueKey<String>('onboarding:complete');

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

  // Debt detail / actions
  static const debtDetailEdit = ValueKey<String>('debt-detail:edit');
  static const debtDetailMore = ValueKey<String>('debt-detail:more');
  static const debtDetailLogPayment = ValueKey<String>('debt-detail:log-payment');
  static const debtDetailPaymentHistory = ValueKey<String>(
    'debt-detail:payment-history',
  );
  static const debtOptionArchive = ValueKey<String>('debt-option:archive');
  static const debtOptionUnarchive = ValueKey<String>('debt-option:unarchive');
  static const debtOptionDelete = ValueKey<String>('debt-option:delete');
  static const dialogConfirmPrimary = ValueKey<String>(
    'dialog:confirm-primary',
  );
  static const snackbarUndo = ValueKey<String>('snackbar:undo');

  // Phase 4 payments / monthly action
  static const paymentLogAmount = ValueKey<String>('payment-log:amount');
  static const paymentLogDate = ValueKey<String>('payment-log:date');
  static const paymentLogSubmit = ValueKey<String>('payment-log:submit');
  static const paymentTypeMinimum = ValueKey<String>('payment-log:type-minimum');
  static const paymentTypeExtra = ValueKey<String>('payment-log:type-extra');
  static const paymentTypeLumpSum = ValueKey<String>('payment-log:type-lumpsum');

  static ValueKey<String> monthlyActionSection(String debtId) =>
      ValueKey<String>('monthly-action:section:$debtId');

  static ValueKey<String> monthlyActionItem(String actionId) =>
      ValueKey<String>('monthly-action:item:$actionId');

  static ValueKey<String> monthlyActionCheckOff(String actionId) =>
      ValueKey<String>('monthly-action:checkoff:$actionId');

  static ValueKey<String> paymentHistoryMonthChip(String yearMonth) =>
      ValueKey<String>('payment-history:month:$yearMonth');

  static ValueKey<String> timelineMonthCard(int monthIndex) =>
      ValueKey<String>('timeline:month:$monthIndex');

  static ValueKey<String> debtCard(String id) =>
      ValueKey<String>('debt-card:$id');

  static ValueKey<String> debtDetail(String id) =>
      ValueKey<String>('debt-detail:$id');
}
