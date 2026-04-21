import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// Application name shown in localized UI.
  ///
  /// In en, this message translates to:
  /// **'Debt Payoff X'**
  String get appName;

  /// Bottom navigation label for the debts tab.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get navDebts;

  /// Bottom navigation label for the plan tab.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navPlan;

  /// Bottom navigation label for the progress tab.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// Bottom navigation label for the settings tab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Bottom navigation label for the overview home tab.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get navThisMonth;

  /// Generic action to add a new debt.
  ///
  /// In en, this message translates to:
  /// **'Add debt'**
  String get commonAddDebt;

  /// Generic action to save a payment.
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get commonSavePayment;

  /// Generic undo action.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// Generic action to view all items in a list.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// Short label for features that are not available yet.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// Snackbar message shown when a feature is not part of the current MVP.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon.'**
  String commonComingSoonFeature(String feature);

  /// Action to switch from a suggested amount to a custom amount.
  ///
  /// In en, this message translates to:
  /// **'Enter another amount'**
  String get commonRecordAnotherAmount;

  /// Label for a minimum payment type.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get paymentTypeMinimumLabel;

  /// Label for an extra payment type.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get paymentTypeExtraLabel;

  /// Label for a lump-sum payment type.
  ///
  /// In en, this message translates to:
  /// **'Lump sum'**
  String get paymentTypeLumpSumLabel;

  /// Title on the home hero card for the current outstanding balance.
  ///
  /// In en, this message translates to:
  /// **'Current total balance'**
  String get homeCurrentBalanceTitle;

  /// Label for the active payoff strategy on the home hero card.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get homeStrategyLabel;

  /// Label for the extra monthly amount on the home hero card.
  ///
  /// In en, this message translates to:
  /// **'Extra / month'**
  String get homeExtraMonthlyLabel;

  /// Label showing how much has already been paid.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount}'**
  String homePaidAmountLabel(String amount);

  /// Label for the number of active tracked debts.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get homeTrackedLabel;

  /// Label for the number of debts already paid off.
  ///
  /// In en, this message translates to:
  /// **'Paid off'**
  String get homePaidOffLabel;

  /// Label for the number of paused debts.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get homePausedLabel;

  /// Section title for the debt list on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Debts to watch'**
  String get homeTrackedDebtsTitle;

  /// Section subtitle for the debt list on the home screen.
  ///
  /// In en, this message translates to:
  /// **'This list comes directly from the debts you have saved.'**
  String get homeTrackedDebtsSubtitle;

  /// Due-date text for a paused debt.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get homeDuePaused;

  /// Due-date label showing the calendar day of month.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String homeDueDay(int day);

  /// Empty-state text when the home debt snapshot has no visible debts.
  ///
  /// In en, this message translates to:
  /// **'There are no debts to track yet.'**
  String get homeNoDebtsTracked;

  /// Title for the current payoff plan card on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Current payoff plan'**
  String get homeCurrentPlanTitle;

  /// Subtitle shown when the projected payoff date is not available yet.
  ///
  /// In en, this message translates to:
  /// **'The app will recalculate your payoff date as soon as you record the latest payment.'**
  String get homeCurrentPlanPendingSubtitle;

  /// Subtitle shown when the payoff date projection is available.
  ///
  /// In en, this message translates to:
  /// **'If you keep this pace, you could be debt-free by {monthYear}.'**
  String homeCurrentPlanProjectedSubtitle(String monthYear);

  /// Compact line showing the current strategy and extra monthly amount.
  ///
  /// In en, this message translates to:
  /// **'{strategy} · Extra {amount} / month'**
  String homeCurrentPlanStrategyLine(String strategy, String amount);

  /// CTA on the home plan summary card.
  ///
  /// In en, this message translates to:
  /// **'View detailed plan'**
  String get homeViewPlanDetails;

  /// App bar title for the standalone monthly action page.
  ///
  /// In en, this message translates to:
  /// **'This month\'s actions'**
  String get monthlyActionStandaloneTitle;

  /// Empty-state title for the monthly action section when there are no debts.
  ///
  /// In en, this message translates to:
  /// **'No debts are being tracked yet'**
  String get monthlyActionEmptyTitle;

  /// Empty-state subtitle for the monthly action section when there are no debts.
  ///
  /// In en, this message translates to:
  /// **'Add your first debt so the app can suggest what to do this month.'**
  String get monthlyActionEmptySubtitle;

  /// Main title for the monthly action section.
  ///
  /// In en, this message translates to:
  /// **'This month\'s actions'**
  String get monthlyActionSectionTitle;

  /// Subtitle for the monthly action section.
  ///
  /// In en, this message translates to:
  /// **'Handle required items first. The app will suggest extra payments separately.'**
  String get monthlyActionSectionSubtitle;

  /// Progress chip for completed required actions.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} done'**
  String monthlyActionCompletionChip(int completed, int total);

  /// Label for the projected payoff date in the monthly action summary card.
  ///
  /// In en, this message translates to:
  /// **'Projected payoff date'**
  String get monthlyActionSummaryDebtFreeLabel;

  /// Fallback text when monthly action metrics are still recalculating.
  ///
  /// In en, this message translates to:
  /// **'Recalculating'**
  String get monthlyActionSummaryRecalculating;

  /// Label for required monthly payment total.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get monthlyActionSummaryRequired;

  /// Label for extra monthly payment total.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get monthlyActionSummaryExtra;

  /// Label for overdue count in the monthly action summary card.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get monthlyActionSummaryOverdue;

  /// Title for the required monthly action section.
  ///
  /// In en, this message translates to:
  /// **'Required this month'**
  String get monthlyActionRequiredSectionTitle;

  /// Subtitle for the required monthly action section.
  ///
  /// In en, this message translates to:
  /// **'Start with overdue items, then the ones coming up soon.'**
  String get monthlyActionRequiredSectionSubtitle;

  /// Title for the optional extra-payment section.
  ///
  /// In en, this message translates to:
  /// **'Pay extra to finish sooner'**
  String get monthlyActionOptionalSectionTitle;

  /// Subtitle for the optional extra-payment section.
  ///
  /// In en, this message translates to:
  /// **'Only do this after the required items are covered.'**
  String get monthlyActionOptionalSectionSubtitle;

  /// Title for the completion card when all required payments are done.
  ///
  /// In en, this message translates to:
  /// **'You have finished this month\'s required payments'**
  String get monthlyActionAllDoneTitle;

  /// Subtitle for the completion card when all required payments are done.
  ///
  /// In en, this message translates to:
  /// **'If you still have room in the budget, use the extra section below to finish sooner.'**
  String get monthlyActionAllDoneSubtitle;

  /// Title for the next-best-action card when there are no monthly actions.
  ///
  /// In en, this message translates to:
  /// **'There is nothing left to handle this month'**
  String get monthlyActionNextActionTitle;

  /// Subtitle for the next-best-action card when there are no monthly actions.
  ///
  /// In en, this message translates to:
  /// **'You can review your current plan or record another payment if you just paid extra.'**
  String get monthlyActionNextActionSubtitle;

  /// Primary CTA on the next-best-action card.
  ///
  /// In en, this message translates to:
  /// **'View plan'**
  String get monthlyActionNextActionPrimary;

  /// Subtitle on a required monthly-action debt card.
  ///
  /// In en, this message translates to:
  /// **'Need to pay {amount}'**
  String monthlyActionRequiredTotal(String amount);

  /// Subtitle on an optional monthly-action debt card.
  ///
  /// In en, this message translates to:
  /// **'Suggested {amount}'**
  String monthlyActionSuggestedTotal(String amount);

  /// Badge shown when a monthly action section is already completed.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get monthlyActionDoneBadge;

  /// Due-date label for a required monthly action.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String monthlyActionDueDate(String date);

  /// Timing hint for an optional extra payment item.
  ///
  /// In en, this message translates to:
  /// **'After your required payments for this month are done'**
  String get monthlyActionOptionalTiming;

  /// Helper text for an optional extra payment item.
  ///
  /// In en, this message translates to:
  /// **'This payment helps shorten your payoff timeline.'**
  String get monthlyActionOptionalHelper;

  /// Status chip for overdue monthly actions.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get monthlyActionOverdueChip;

  /// Status chip for upcoming monthly actions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get monthlyActionUpcomingChip;

  /// Priority chip for optional monthly actions.
  ///
  /// In en, this message translates to:
  /// **'Priority #{rank}'**
  String monthlyActionPriorityChip(int rank);

  /// Disabled CTA label after a monthly action has already been logged.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get monthlyActionSavedButton;

  /// Primary CTA label for monthly actions.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get monthlyActionPaidButton;

  /// Snackbar shown after confirming a monthly action payment.
  ///
  /// In en, this message translates to:
  /// **'Saved a payment for {debtName}.'**
  String monthlyActionSnackbarSaved(String debtName);

  /// Title of the monthly action confirmation bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get monthlyActionConfirmTitle;

  /// Subtitle of the monthly action confirmation bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'This will be added to your history and will update your payoff plan.'**
  String get monthlyActionConfirmSubtitle;

  /// Label for the debt name row in the monthly action confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get monthlyActionInfoDebt;

  /// Label for the payment type row in the monthly action confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get monthlyActionInfoType;

  /// Label for the amount row in the monthly action confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get monthlyActionInfoAmount;

  /// Label for the date row in the monthly action confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Applied date'**
  String get monthlyActionInfoDate;

  /// Banner text describing a projected payoff date change after a recast.
  ///
  /// In en, this message translates to:
  /// **'Projected payoff date: {previous} → {current}{delta}'**
  String monthlyActionRecastDebtFree(
    String previous,
    String current,
    String delta,
  );

  /// Banner text describing a projected interest change after a recast.
  ///
  /// In en, this message translates to:
  /// **'Projected interest: {previous} → {current}{delta}'**
  String monthlyActionRecastProjectedInterest(
    String previous,
    String current,
    String delta,
  );

  /// Banner text describing a saved-interest change after a recast.
  ///
  /// In en, this message translates to:
  /// **'Interest saved: {previous} → {current}{delta}'**
  String monthlyActionRecastSavedInterest(
    String previous,
    String current,
    String delta,
  );

  /// Suffix for an earlier payoff-date projection.
  ///
  /// In en, this message translates to:
  /// **' ({months} months sooner)'**
  String monthlyActionDeltaSooner(int months);

  /// Suffix for a later payoff-date projection.
  ///
  /// In en, this message translates to:
  /// **' ({months} months later)'**
  String monthlyActionDeltaLater(int months);

  /// Suffix for a reduced interest projection.
  ///
  /// In en, this message translates to:
  /// **' (down {amount})'**
  String monthlyActionDeltaReduced(String amount);

  /// Suffix for an increased interest projection.
  ///
  /// In en, this message translates to:
  /// **' (up {amount})'**
  String monthlyActionDeltaIncreased(String amount);

  /// Neutral banner text when the recast has no highlighted payoff change.
  ///
  /// In en, this message translates to:
  /// **'Your plan has been refreshed using your latest data.'**
  String get monthlyActionRecastNeutral;

  /// App bar title on the log payment page.
  ///
  /// In en, this message translates to:
  /// **'Log payment'**
  String get logPaymentTitle;

  /// Fallback text when the debt referenced by the log payment page cannot be found.
  ///
  /// In en, this message translates to:
  /// **'This debt no longer exists or has already been deleted.'**
  String get logPaymentMissingDebt;

  /// Label showing the current debt balance on the log payment page.
  ///
  /// In en, this message translates to:
  /// **'Current balance {amount}'**
  String logPaymentCurrentBalance(String amount);

  /// Label for the payment amount input.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get logPaymentAmountLabel;

  /// Helper text under the payment amount input.
  ///
  /// In en, this message translates to:
  /// **'This amount will be subtracted directly from the current balance.'**
  String get logPaymentAmountHelper;

  /// Label above the payment type chips.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get logPaymentTypeLabel;

  /// Label for the payment date field.
  ///
  /// In en, this message translates to:
  /// **'Applied date'**
  String get logPaymentDateLabel;

  /// Label for the optional payment note field.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get logPaymentNoteLabel;

  /// Hint text for the optional payment note field.
  ///
  /// In en, this message translates to:
  /// **'Example: autopay, bonus, paycheck sweep'**
  String get logPaymentNoteHint;

  /// Info card text on the log payment page.
  ///
  /// In en, this message translates to:
  /// **'This payment will store the before and after balances and refresh your payoff plan right away.'**
  String get logPaymentInfo;

  /// Inline validation error when the payment amount is invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than 0.'**
  String get logPaymentInvalidAmount;

  /// Snackbar shown after manually logging a payment.
  ///
  /// In en, this message translates to:
  /// **'Payment saved and plan updated.'**
  String get logPaymentSavedMessage;

  /// Body copy on the pricing page.
  ///
  /// In en, this message translates to:
  /// **'The current MVP keeps the full core payoff flow free. Premium is the next step for cloud backup, PDF reports, and shared planning.'**
  String get pricingBody;

  /// Primary CTA on the pricing page.
  ///
  /// In en, this message translates to:
  /// **'Continue with Free'**
  String get pricingContinueFree;

  /// Free tier bullet describing export and backup support.
  ///
  /// In en, this message translates to:
  /// **'CSV export + local backup/restore + clear all'**
  String get pricingFreeBulletExport;

  /// Free tier bullet describing payment logging features.
  ///
  /// In en, this message translates to:
  /// **'Payment logging + monthly action view'**
  String get pricingFreeBulletPayments;

  /// Free tier bullet describing strategy and timeline features.
  ///
  /// In en, this message translates to:
  /// **'Snowball / Avalanche + living timeline'**
  String get pricingFreeBulletStrategies;

  /// Free tier bullet describing unlimited debt management.
  ///
  /// In en, this message translates to:
  /// **'Unlimited debt entry and editing'**
  String get pricingFreeBulletUnlimitedDebts;

  /// Subtitle for the free tier card.
  ///
  /// In en, this message translates to:
  /// **'Included in the MVP'**
  String get pricingFreeSubtitle;

  /// Title for the free tier card.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get pricingFreeTitle;

  /// Headline on the pricing page.
  ///
  /// In en, this message translates to:
  /// **'Local-first first. Premium only unlocks when it adds real value.'**
  String get pricingHeadline;

  /// Notice below the pricing CTA.
  ///
  /// In en, this message translates to:
  /// **'Premium is not available in this MVP yet.'**
  String get pricingMvpNotice;

  /// App bar title on the pricing page.
  ///
  /// In en, this message translates to:
  /// **'Free vs Premium'**
  String get pricingPageTitle;

  /// Premium tier bullet describing cloud backup.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup across devices'**
  String get pricingPremiumBulletCloud;

  /// Premium tier bullet describing PDF reports.
  ///
  /// In en, this message translates to:
  /// **'PDF reports to print or share with an advisor'**
  String get pricingPremiumBulletPdf;

  /// Premium tier bullet describing pricing philosophy.
  ///
  /// In en, this message translates to:
  /// **'Transparent pricing, no fuzzy trial'**
  String get pricingPremiumBulletPricing;

  /// Premium tier bullet describing sharing features.
  ///
  /// In en, this message translates to:
  /// **'Partner sharing and scenario comparison'**
  String get pricingPremiumBulletSharing;

  /// Subtitle for the premium tier card.
  ///
  /// In en, this message translates to:
  /// **'Monetization placeholder, no IAP yet'**
  String get pricingPremiumSubtitle;

  /// Title for the premium tier card.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get pricingPremiumTitle;

  /// Trust reassurance card copy on the pricing page.
  ///
  /// In en, this message translates to:
  /// **'Our trust model stays the same on Premium: no bank linking, no fuzzy auto-charges, and local export always stays available.'**
  String get pricingTrustMessage;

  /// Generic cancel action in settings dialogs.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// Body text for the first clear-all confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This will delete all local data and return the app to its first-launch state.'**
  String get settingsClearAllDialogBody;

  /// Title for the first clear-all confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Clear all data?'**
  String get settingsClearAllDialogTitle;

  /// Subtitle for the clear-all settings tile.
  ///
  /// In en, this message translates to:
  /// **'Only resets data on this device. Cloud is not enabled at Level 0.'**
  String get settingsClearAllSubtitle;

  /// Title for the clear-all settings tile.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get settingsClearAllTitle;

  /// Title for the cloud backup settings tile.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup'**
  String get settingsCloudBackupTitle;

  /// Continue action in settings dialogs.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get settingsContinue;

  /// Footer copyright label on the settings page.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Debt Payoff X'**
  String get settingsCopyrightFooter;

  /// Subtitle for the currency settings tile.
  ///
  /// In en, this message translates to:
  /// **'Currently used for display formatting only.'**
  String get settingsCurrencySubtitle;

  /// Title for the currency settings tile.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrencyTitle;

  /// Body text for the local-only trust banner in settings.
  ///
  /// In en, this message translates to:
  /// **'Your data currently lives on this device. You always have CSV export, local backup/restore, and clear all without an account or bank linking.'**
  String get settingsDataBannerLocalBody;

  /// Title for the local-only trust banner in settings.
  ///
  /// In en, this message translates to:
  /// **'Local-first is enabled'**
  String get settingsDataBannerLocalTitle;

  /// Body text for the elevated trust banner in settings.
  ///
  /// In en, this message translates to:
  /// **'You are using trust level > 0. Local export is still available, but reset actions need more care because they may relate to cloud semantics.'**
  String get settingsDataBannerTrustBody;

  /// Title for the elevated trust banner in settings.
  ///
  /// In en, this message translates to:
  /// **'Advanced trust mode is enabled'**
  String get settingsDataBannerTrustTitle;

  /// Final destructive confirmation button for clear-all.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get settingsDeleteAllConfirm;

  /// Subtitle for the CSV export settings tile.
  ///
  /// In en, this message translates to:
  /// **'ZIP bundle with multiple CSV files + manifest so you can inspect each table yourself.'**
  String get settingsExportCsvSubtitle;

  /// Title for the CSV export settings tile.
  ///
  /// In en, this message translates to:
  /// **'Export data (CSV)'**
  String get settingsExportCsvTitle;

  /// Subtitle for the extra monthly amount settings tile.
  ///
  /// In en, this message translates to:
  /// **'Saved in your main plan.'**
  String get settingsExtraMonthlySubtitle;

  /// Title for the extra monthly amount settings tile.
  ///
  /// In en, this message translates to:
  /// **'Extra monthly amount'**
  String get settingsExtraMonthlyTitle;

  /// Body text for the final clear-all confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'You will lose all debts, payments, milestones, and the current local backup stored in this app.'**
  String get settingsFinalConfirmBody;

  /// Title for the final clear-all confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Final confirmation'**
  String get settingsFinalConfirmTitle;

  /// Go back action in the final clear-all confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get settingsGoBack;

  /// Subtitle for the current strategy settings tile.
  ///
  /// In en, this message translates to:
  /// **'Open the Plan tab to view the detailed priority order.'**
  String get settingsCurrentStrategySubtitle;

  /// Title for the current strategy settings tile.
  ///
  /// In en, this message translates to:
  /// **'Current strategy'**
  String get settingsCurrentStrategyTitle;

  /// Title for the settings locale picker sheet.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsLocaleSheetTitle;

  /// Subtitle for the language settings tile.
  ///
  /// In en, this message translates to:
  /// **'Changes the display language and date formatting.'**
  String get settingsLocaleSubtitle;

  /// Title for the language settings tile.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLocaleTitle;

  /// Subtitle for the local backup settings tile.
  ///
  /// In en, this message translates to:
  /// **'Create a full JSON backup ZIP to save in Files, Drive, or external storage.'**
  String get settingsLocalBackupSubtitle;

  /// Title for the local backup settings tile.
  ///
  /// In en, this message translates to:
  /// **'Local backup'**
  String get settingsLocalBackupTitle;

  /// Subtitle for the monthly log settings toggle.
  ///
  /// In en, this message translates to:
  /// **'Used for monthly log summaries when that flow is enabled.'**
  String get settingsMonthlyLogSubtitle;

  /// Title for the monthly log settings toggle.
  ///
  /// In en, this message translates to:
  /// **'Monthly log'**
  String get settingsMonthlyLogTitle;

  /// App bar title for the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// Subtitle for the payment reminders settings toggle.
  ///
  /// In en, this message translates to:
  /// **'The app will use this when payment reminders are enabled.'**
  String get settingsPaymentReminderSubtitle;

  /// Title for the payment reminders settings toggle.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders'**
  String get settingsPaymentReminderTitle;

  /// Short trailing action label for reset on the clear-all tile.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetAction;

  /// Short trailing action label for restore on the restore tile.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingsRestoreAction;

  /// Confirmation button label for the restore dialog.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingsRestoreConfirm;

  /// Header introducing backup row counts in the restore dialog.
  ///
  /// In en, this message translates to:
  /// **'Data in this backup:'**
  String get settingsRestoreDialogDataHeader;

  /// Label for the exported-at timestamp in the restore dialog.
  ///
  /// In en, this message translates to:
  /// **'Exported at'**
  String get settingsRestoreDialogExportedAtLabel;

  /// Label for the file name in the restore dialog.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get settingsRestoreDialogFileLabel;

  /// Title for the restore confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup?'**
  String get settingsRestoreDialogTitle;

  /// Label for the total records count in the restore dialog.
  ///
  /// In en, this message translates to:
  /// **'Total records'**
  String get settingsRestoreDialogTotalRecordsLabel;

  /// Warning shown in the restore confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'All current local data will be replaced.'**
  String get settingsRestoreDialogWarning;

  /// Subtitle for the restore settings tile.
  ///
  /// In en, this message translates to:
  /// **'Read the manifest preview and row counts before replacing local data.'**
  String get settingsRestoreSubtitle;

  /// Snackbar message shown after a successful local restore.
  ///
  /// In en, this message translates to:
  /// **'Local data restored from the selected backup.'**
  String get settingsRestoreSuccess;

  /// Title for the restore settings tile.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get settingsRestoreTitle;

  /// Section header for data settings.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get settingsSectionData;

  /// Section header for general options in settings.
  ///
  /// In en, this message translates to:
  /// **'OPTIONS'**
  String get settingsSectionOptions;

  /// Section header for plan-related settings.
  ///
  /// In en, this message translates to:
  /// **'PAYOFF PLAN'**
  String get settingsSectionPlan;

  /// Section header for reminders in settings.
  ///
  /// In en, this message translates to:
  /// **'REMINDERS'**
  String get settingsSectionReminders;

  /// Localized label for the avalanche payoff strategy.
  ///
  /// In en, this message translates to:
  /// **'Avalanche'**
  String get settingsStrategyAvalanche;

  /// Localized label for the custom payoff strategy.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get settingsStrategyCustom;

  /// Localized label for the snowball payoff strategy.
  ///
  /// In en, this message translates to:
  /// **'Snowball'**
  String get settingsStrategySnowball;

  /// Subtitle copy for cloud backup when trust level is local-only.
  ///
  /// In en, this message translates to:
  /// **'You are currently in local-only mode. Cloud backup is the next roadmap step, not a requirement to use the app.'**
  String get settingsTrustLevelLocalOnlyBody;

  /// Trailing label for cloud backup when trust level is local-only.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get settingsTrustLevelLocalOnlyLabel;

  /// Subtitle copy for cloud backup when trust level is 1.
  ///
  /// In en, this message translates to:
  /// **'Basic cloud backup is enabled. Local export is still always available.'**
  String get settingsTrustLevelOneBody;

  /// Trailing label for cloud backup when trust level is 1.
  ///
  /// In en, this message translates to:
  /// **'Trust 1'**
  String get settingsTrustLevelOneLabel;

  /// Subtitle copy for cloud backup when trust level is 2.
  ///
  /// In en, this message translates to:
  /// **'A higher trust mode is active. Review sharing permissions before resetting local data.'**
  String get settingsTrustLevelTwoBody;

  /// Trailing label for cloud backup when trust level is 2.
  ///
  /// In en, this message translates to:
  /// **'Trust 2'**
  String get settingsTrustLevelTwoLabel;

  /// Version footer on the settings page.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 (MVP)'**
  String get settingsVersionFooter;

  /// Short trailing label for ZIP-based data actions.
  ///
  /// In en, this message translates to:
  /// **'ZIP'**
  String get settingsZipLabel;

  /// Body copy on the sync backup page.
  ///
  /// In en, this message translates to:
  /// **'Your app is currently running in local-only mode. You still have full export, local backup, and restore without an account.'**
  String get syncBackupBody;

  /// Secondary CTA on the sync backup page.
  ///
  /// In en, this message translates to:
  /// **'Keep using local-only'**
  String get syncBackupContinueLocal;

  /// Free bullet on the sync backup page describing local backup.
  ///
  /// In en, this message translates to:
  /// **'Local backup ZIP for manual storage in Files or Drive'**
  String get syncBackupFreeBulletBackup;

  /// Free bullet on the sync backup page describing CSV export.
  ///
  /// In en, this message translates to:
  /// **'Full CSV export for Excel or Numbers'**
  String get syncBackupFreeBulletCsv;

  /// Free bullet on the sync backup page describing restore preview.
  ///
  /// In en, this message translates to:
  /// **'Restore preview before replacing local data'**
  String get syncBackupFreeBulletPreview;

  /// Free bullet on the sync backup page describing reset controls.
  ///
  /// In en, this message translates to:
  /// **'Clear all / factory reset without losing access to your data'**
  String get syncBackupFreeBulletReset;

  /// Title for the free capability card on the sync backup page.
  ///
  /// In en, this message translates to:
  /// **'Already included in Free'**
  String get syncBackupFreeTitle;

  /// Headline on the sync backup page.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup is the next step, not a requirement to use the app.'**
  String get syncBackupHeadline;

  /// Premium bullet on the sync backup page describing cloud backup.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup across devices'**
  String get syncBackupPremiumBulletCloud;

  /// Premium bullet on the sync backup page describing PDF reports.
  ///
  /// In en, this message translates to:
  /// **'PDF reports to print or send to an advisor'**
  String get syncBackupPremiumBulletPdf;

  /// Premium bullet on the sync backup page describing pricing philosophy.
  ///
  /// In en, this message translates to:
  /// **'Transparent pricing, no fuzzy trial'**
  String get syncBackupPremiumBulletPricing;

  /// Premium bullet on the sync backup page describing sharing features.
  ///
  /// In en, this message translates to:
  /// **'Partner sharing and scenario comparison'**
  String get syncBackupPremiumBulletSharing;

  /// Title for the premium capability card on the sync backup page.
  ///
  /// In en, this message translates to:
  /// **'Premium will add later'**
  String get syncBackupPremiumTitle;

  /// Trust reassurance card copy on the sync backup page.
  ///
  /// In en, this message translates to:
  /// **'Our trust commitment does not change: data starts on-device, no bank linking, and local export stays open even when Premium arrives.'**
  String get syncBackupTrustMessage;

  /// Primary CTA on the sync backup page that opens pricing.
  ///
  /// In en, this message translates to:
  /// **'View Free vs Premium'**
  String get syncBackupViewPricing;

  /// Primary CTA on the welcome page.
  ///
  /// In en, this message translates to:
  /// **'Add your first debt'**
  String get welcomeAddFirstDebt;

  /// Small text action on the welcome page that opens the language picker.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get welcomeChangeLanguage;

  /// Subtitle on the welcome page.
  ///
  /// In en, this message translates to:
  /// **'Build a personalized payoff plan in 3 minutes.\nNo account. No bank connection.'**
  String get welcomeSubtitle;

  /// Headline on the welcome page.
  ///
  /// In en, this message translates to:
  /// **'Take control of debt,\nfree your future.'**
  String get welcomeTitle;

  /// Trust badge label on the welcome page describing free access.
  ///
  /// In en, this message translates to:
  /// **'Free to use'**
  String get welcomeTrustFree;

  /// Trust badge label on the welcome page describing local-first behavior.
  ///
  /// In en, this message translates to:
  /// **'Local-first'**
  String get welcomeTrustLocalFirst;

  /// Trust badge label on the welcome page describing no bank connection.
  ///
  /// In en, this message translates to:
  /// **'No bank sync'**
  String get welcomeTrustNoBankSync;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
