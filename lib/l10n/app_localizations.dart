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

  /// Section title on home empty state explaining capabilities.
  ///
  /// In en, this message translates to:
  /// **'What can you do right now?'**
  String get whatCanYouDoNow;

  /// Due day label for debt card showing day of month.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String debtDueDay(Object day);

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

  /// Localized debt status label.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get debtStatusActive;

  /// Localized debt status label.
  ///
  /// In en, this message translates to:
  /// **'Paid off'**
  String get debtStatusPaidOff;

  /// Localized debt status label.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get debtStatusArchived;

  /// Localized debt status label.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get debtStatusPaused;

  /// Default label for an overdue status badge.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get statusBadgeOverdue;

  /// Default label for a paid status badge.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get statusBadgePaid;

  /// Default label for an active status badge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get statusBadgeActive;

  /// Default label for an upcoming status badge.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get statusBadgeUpcoming;

  /// Label for the minimum payment detail on a shared debt card.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get debtCardMinimumLabel;

  /// Label for the due date detail on a shared debt card.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get debtCardDueLabel;

  /// Title on the home hero card for the current outstanding balance.
  ///
  /// In en, this message translates to:
  /// **'Current total balance'**
  String get homeCurrentBalanceTitle;

  /// Label for strategy stat card on home screen.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get homeStrategyLabel;

  /// Label for extra monthly payment stat on home screen.
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

  /// Hero card title on home screen showing total balance.
  ///
  /// In en, this message translates to:
  /// **'Current total balance'**
  String get homeTotalBalanceLabel;

  /// Progress label showing paid amount on home screen.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount}'**
  String homePaidProgress(Object amount);

  /// Label for active debts count on home screen.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get homeTrackingCountLabel;

  /// Label for paid off debts count on home screen.
  ///
  /// In en, this message translates to:
  /// **'Paid off'**
  String get homePaidOffCountLabel;

  /// Label for paused debts count on home screen.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get homePausedCountLabel;

  /// Section title for debts list on home screen.
  ///
  /// In en, this message translates to:
  /// **'Debts to track'**
  String get homeDebtsToTrackTitle;

  /// Section subtitle for debts list on home screen.
  ///
  /// In en, this message translates to:
  /// **'This list is pulled directly from your saved data.'**
  String get homeDebtsToTrackSubtitle;

  /// Message when no active debts on home screen.
  ///
  /// In en, this message translates to:
  /// **'No debts to track yet.'**
  String get homeNoDebtsToTrackMessage;

  /// Card title for timeline connection status on home screen.
  ///
  /// In en, this message translates to:
  /// **'Detailed timeline is connecting'**
  String get homeTimelineConnectingTitle;

  /// Card subtitle for timeline connection status on home screen.
  ///
  /// In en, this message translates to:
  /// **'You have enough background data to visit the Plan tab and see your current setup. The debt-free date and detailed projections will appear when the plan simulation is enabled.'**
  String get homeTimelineConnectingSubtitle;

  /// Button to navigate to Plan tab from home screen.
  ///
  /// In en, this message translates to:
  /// **'Open Plan tab'**
  String get homeOpenPlanTabButton;

  /// Empty state title when no debts exist on home screen.
  ///
  /// In en, this message translates to:
  /// **'No debts yet'**
  String get homeEmptyTitle;

  /// Empty state subtitle when no debts exist on home screen.
  ///
  /// In en, this message translates to:
  /// **'Add your first debt for the app to start saving data and building your payoff plan.'**
  String get homeEmptySubtitle;

  /// Feature row title for multi-debt support on home empty state.
  ///
  /// In en, this message translates to:
  /// **'Enter multiple debt types'**
  String get homeFeatureMultiDebtTitle;

  /// Feature row subtitle for multi-debt support on home empty state.
  ///
  /// In en, this message translates to:
  /// **'Credit cards, student loans, car loans, mortgages, and more.'**
  String get homeFeatureMultiDebtSubtitle;

  /// Feature row title for edit flexibility on home empty state.
  ///
  /// In en, this message translates to:
  /// **'Edit anytime'**
  String get homeFeatureEditAnytimeTitle;

  /// Feature row subtitle for edit flexibility on home empty state.
  ///
  /// In en, this message translates to:
  /// **'All changes are saved locally and reflected in your debt list.'**
  String get homeFeatureEditAnytimeSubtitle;

  /// Feature row title for local-first approach on home empty state.
  ///
  /// In en, this message translates to:
  /// **'Local-first'**
  String get homeFeatureLocalFirstTitle;

  /// Feature row subtitle for local-first approach on home empty state.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need an account to start and your data stays on your device.'**
  String get homeFeatureLocalFirstSubtitle;

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

  /// Title for the all-done proof dashboard.
  ///
  /// In en, this message translates to:
  /// **'This month is done'**
  String get monthlyActionDoneProofTitle;

  /// Subtitle for the all-done proof dashboard.
  ///
  /// In en, this message translates to:
  /// **'Logged {amount} this month.'**
  String monthlyActionDoneProofSubtitle(String amount);

  /// All-done subtitle when only one debt is tracked and still has balance.
  ///
  /// In en, this message translates to:
  /// **'{debtName} has {balance} remaining.'**
  String monthlyActionDoneProofSingleRemaining(String debtName, String balance);

  /// All-done subtitle when the only tracked debt is paid off.
  ///
  /// In en, this message translates to:
  /// **'{debtName} is paid off.'**
  String monthlyActionDoneProofSinglePaidOff(String debtName);

  /// Label for total logged payments this month.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get monthlyActionStatLogged;

  /// Label for remaining debt balance.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get monthlyActionStatRemaining;

  /// Label for latest logged payment date.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get monthlyActionStatLatestLogged;

  /// Fallback when there is no logged payment date.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get monthlyActionNoLoggedDate;

  /// CTA to view payment history.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get monthlyActionViewHistory;

  /// CTA to log another payment.
  ///
  /// In en, this message translates to:
  /// **'Log another'**
  String get monthlyActionLogAnother;

  /// CTA to view payoff progress.
  ///
  /// In en, this message translates to:
  /// **'View progress'**
  String get monthlyActionViewProgress;

  /// CTA to add another debt after payoff.
  ///
  /// In en, this message translates to:
  /// **'Add another debt'**
  String get monthlyActionAddAnotherDebt;

  /// Title for a compact single-debt status card.
  ///
  /// In en, this message translates to:
  /// **'This debt'**
  String get monthlyActionSingleDebtTitle;

  /// Title for a compact single-debt payoff card.
  ///
  /// In en, this message translates to:
  /// **'This debt is paid off'**
  String get monthlyActionSingleDebtPaidOffTitle;

  /// Label for remaining balance on the single-debt card.
  ///
  /// In en, this message translates to:
  /// **'Remaining balance'**
  String get monthlyActionSingleDebtRemainingLabel;

  /// Label for due date on the single-debt card.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get monthlyActionSingleDebtDueDateLabel;

  /// Label for status on the single-debt card.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get monthlyActionSingleDebtStatusLabel;

  /// Collapsed checklist header after all monthly actions are complete.
  ///
  /// In en, this message translates to:
  /// **'Completed {completed}/{total}'**
  String monthlyActionCompletedChecklistTitle(int completed, int total);

  /// Proof line for a completed monthly action item.
  ///
  /// In en, this message translates to:
  /// **'Logged {amount} on {date}'**
  String monthlyActionLoggedProof(String amount, String date);

  /// Small label on the first monthly action card.
  ///
  /// In en, this message translates to:
  /// **'Next to pay'**
  String get monthlyActionNextPay;

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

  /// Short helper text for a minimum-payment monthly action.
  ///
  /// In en, this message translates to:
  /// **'Required payment for this debt.'**
  String get monthlyActionMinimumSubtitle;

  /// Short helper text for an extra-payment monthly action.
  ///
  /// In en, this message translates to:
  /// **'Suggested extra payment to finish sooner.'**
  String get monthlyActionExtraSubtitle;

  /// Short helper text for a prioritized extra-payment monthly action.
  ///
  /// In en, this message translates to:
  /// **'Priority #{rank} extra payment to finish sooner.'**
  String monthlyActionExtraPrioritySubtitle(int rank);

  /// Chip label
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get monthlyActionOverdueChip;

  /// Chip label
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get monthlyActionUpcomingChip;

  /// Chip label
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

  /// Primary CTA in the monthly action confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Confirm paid'**
  String get monthlyActionConfirmPrimary;

  /// Secondary CTA in the monthly action confirmation sheet for custom payment details.
  ///
  /// In en, this message translates to:
  /// **'Log a different payment'**
  String get monthlyActionLogDifferent;

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

  /// Label text.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get logPaymentTypeLabel;

  /// Label text.
  ///
  /// In en, this message translates to:
  /// **'Applied date'**
  String get logPaymentDateLabel;

  /// Label for the optional payment note field.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get logPaymentNoteLabel;

  /// Hint text.
  ///
  /// In en, this message translates to:
  /// **'E.g. autopay, bonus, extra payment'**
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
  /// **'The core payoff flow stays free. Premium unlocks power tools for deeper planning, reports, and collaboration.'**
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
  /// **'Premium purchases are processed by the App Store. You can continue with Free at any time.'**
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

  /// Premium tier bullet describing scenario planning.
  ///
  /// In en, this message translates to:
  /// **'What-if scenarios and scenario comparison'**
  String get pricingPremiumBulletScenarios;

  /// Subtitle for the premium tier card.
  ///
  /// In en, this message translates to:
  /// **'Power features for serious payoff planning'**
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

  /// Subtitle for premium tier when App Store products are loaded.
  ///
  /// In en, this message translates to:
  /// **'Choose monthly or yearly Premium'**
  String get pricingPremiumLoadedSubtitle;

  /// Monthly premium subscription option title.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get pricingMonthlyPlan;

  /// Monthly premium subscription option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Flexible access, renews monthly'**
  String get pricingMonthlyPlanSubtitle;

  /// Yearly premium subscription option title.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get pricingYearlyPlan;

  /// Yearly premium subscription option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Best value, renews yearly'**
  String get pricingYearlyPlanSubtitle;

  /// Primary purchase button label with App Store price.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for {price}'**
  String pricingPurchaseCta(String price);

  /// Button label to restore App Store purchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get pricingRestorePurchases;

  /// Debug-only button label that clears cached Premium entitlement locally.
  ///
  /// In en, this message translates to:
  /// **'Debug: Clear local Premium'**
  String get pricingDebugClearPremium;

  /// Debug-only confirmation after clearing cached Premium entitlement locally.
  ///
  /// In en, this message translates to:
  /// **'Premium cache cleared for debug.'**
  String get pricingDebugClearPremiumMessage;

  /// Debug-only button label that opens the App Store subscription management sheet.
  ///
  /// In en, this message translates to:
  /// **'Debug: Manage App Store subscription'**
  String get pricingDebugManageSubscription;

  /// Disabled purchase CTA when premium is active.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get pricingPremiumActiveCta;

  /// Message while loading App Store products.
  ///
  /// In en, this message translates to:
  /// **'Loading App Store products...'**
  String get pricingLoadingProducts;

  /// Disabled purchase CTA when store is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Store unavailable'**
  String get pricingStoreUnavailableCta;

  /// Recoverable store unavailable message.
  ///
  /// In en, this message translates to:
  /// **'The App Store is unavailable right now. Check your connection or try again later.'**
  String get pricingStoreUnavailableMessage;

  /// Disabled purchase CTA when subscription products are missing.
  ///
  /// In en, this message translates to:
  /// **'Products unavailable'**
  String get pricingProductsMissingCta;

  /// Recoverable product missing message.
  ///
  /// In en, this message translates to:
  /// **'Premium products are not available yet. Product metadata can take time to appear in sandbox.'**
  String get pricingProductsMissingMessage;

  /// Subscription disclosure on the pricing page.
  ///
  /// In en, this message translates to:
  /// **'No free trial. Subscription renews through your Apple Account and can be managed in App Store settings.'**
  String get pricingNoTrialNotice;

  /// Link label for the Privacy Policy on the pricing / subscription page.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get pricingPrivacyPolicy;

  /// Link label for the Terms of Service / EULA on the pricing / subscription page.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get pricingTermsOfService;

  /// Title for active premium status card.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get pricingPremiumActiveTitle;

  /// Body for active premium without an expiry date.
  ///
  /// In en, this message translates to:
  /// **'Your Premium access is active.'**
  String get pricingPremiumActiveBody;

  /// Body for active premium with an expiry date.
  ///
  /// In en, this message translates to:
  /// **'Active until {date}'**
  String pricingPremiumActiveUntil(String date);

  /// Dialog title shown after a successful Premium purchase or restore.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get pricingPurchaseSuccessTitle;

  /// Dialog body shown after successful Premium activation without an expiry date.
  ///
  /// In en, this message translates to:
  /// **'Your purchase was verified. Premium features are now unlocked.'**
  String get pricingPurchaseSuccessBody;

  /// Dialog body shown after successful Premium activation with an expiry date.
  ///
  /// In en, this message translates to:
  /// **'Your purchase was verified. Premium is active until {date}.'**
  String pricingPurchaseSuccessBodyUntil(String date);

  /// Dialog action label for successful Premium activation.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get pricingPurchaseSuccessAction;

  /// Title shown for locked premium entry points.
  ///
  /// In en, this message translates to:
  /// **'Premium feature'**
  String get premiumLockedTitle;

  /// Body shown for locked premium entry points.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to use this power feature. Your core payoff plan stays free.'**
  String get premiumLockedBody;

  /// CTA shown for locked premium entry points.
  ///
  /// In en, this message translates to:
  /// **'View Premium'**
  String get premiumLockedAction;

  /// Settings section title for subscription and Premium status.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTION'**
  String get settingsSectionSubscription;

  /// Settings row title for Premium subscription.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get settingsPremiumTitle;

  /// Settings Premium row subtitle when Premium is active.
  ///
  /// In en, this message translates to:
  /// **'View your subscription status and restore purchases.'**
  String get settingsPremiumSubtitleActive;

  /// Settings Premium row subtitle when Premium is not active.
  ///
  /// In en, this message translates to:
  /// **'View plans or restore an App Store purchase.'**
  String get settingsPremiumSubtitleFree;

  /// Settings Premium row trailing status when Premium is active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get settingsPremiumStatusActive;

  /// Settings Premium row trailing status when Premium is not active.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get settingsPremiumStatusFree;

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

  /// Title for the end-of-month reminder settings toggle.
  ///
  /// In en, this message translates to:
  /// **'End-of-month reminder'**
  String get settingsMonthlyReminderTitle;

  /// Subtitle for the end-of-month reminder settings toggle.
  ///
  /// In en, this message translates to:
  /// **'Get one reminder near month end if payments still need to be logged.'**
  String get settingsMonthlyReminderSubtitle;

  /// App bar title for the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// Label above the due-date reminder lead-time choices.
  ///
  /// In en, this message translates to:
  /// **'Days before due date'**
  String get settingsReminderDaysTitle;

  /// Helper copy for due-date reminder lead-time choices.
  ///
  /// In en, this message translates to:
  /// **'Choose how early the due-date reminder should arrive.'**
  String get settingsReminderDaysSubtitle;

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

  /// Title for payment due notification.
  ///
  /// In en, this message translates to:
  /// **'Payment Reminder'**
  String get notificationPaymentDueTitle;

  /// Body for payment due notification.
  ///
  /// In en, this message translates to:
  /// **'Your loan \"{debtName}\" is due soon.'**
  String notificationPaymentDueBody(String debtName);

  /// Title for the end-of-month missing payment reminder.
  ///
  /// In en, this message translates to:
  /// **'Monthly check-in'**
  String get notificationMonthlyLogTitle;

  /// Body for the end-of-month missing payment reminder.
  ///
  /// In en, this message translates to:
  /// **'Open your plan and make sure this month\'s payments are fully logged before the month closes.'**
  String get notificationMonthlyLogBody;

  /// Title for milestone notifications.
  ///
  /// In en, this message translates to:
  /// **'Milestone reached'**
  String get notificationMilestoneTitle;

  /// Body for milestone notifications.
  ///
  /// In en, this message translates to:
  /// **'You unlocked a new payoff milestone. Open Progress to review your latest win.'**
  String get notificationMilestoneBody;

  /// Title for milestone notification settings.
  ///
  /// In en, this message translates to:
  /// **'Milestone alerts'**
  String get settingsMilestoneReminderTitle;

  /// Subtitle for milestone notification settings.
  ///
  /// In en, this message translates to:
  /// **'Celebrate payoff progress when a new milestone is reached.'**
  String get settingsMilestoneReminderSubtitle;

  /// Error snackbar shown when notification permission is required.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required to enable this reminder.'**
  String get settingsNotificationPermissionRequired;

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

  /// Section header for reports in settings.
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get settingsSectionReports;

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

  /// Title for the reports preview settings tile.
  ///
  /// In en, this message translates to:
  /// **'Report preview'**
  String get settingsReportsPreviewTitle;

  /// Subtitle for the reports preview settings tile.
  ///
  /// In en, this message translates to:
  /// **'Preview monthly, yearly, or full-history PDF exports before sharing.'**
  String get settingsReportsPreviewSubtitle;

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
  /// **'Sign in to back up this device to your private cloud mirror. Local export, local backup, and restore stay available.'**
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
  /// **'Turn on cloud backup'**
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

  /// Button label for disabling cloud backup.
  ///
  /// In en, this message translates to:
  /// **'Disable cloud backup'**
  String get syncBackupDisable;

  /// Confirmation button for disabling cloud backup and deleting cloud data.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud backup'**
  String get syncBackupDisableConfirm;

  /// Body copy for the disable cloud backup confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This stops sync, deletes your cloud mirror, and keeps all data on this device.'**
  String get syncBackupDisableDialogBody;

  /// Title for the disable cloud backup confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Disable cloud backup?'**
  String get syncBackupDisableDialogTitle;

  /// Snackbar shown after cloud backup is disabled.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup is disabled. Your local data is unchanged.'**
  String get syncBackupDisableSuccess;

  /// Snackbar shown after cloud backup is enabled.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup is enabled.'**
  String get syncBackupEnableSuccess;

  /// Body copy on the sync backup page when cloud backup is enabled.
  ///
  /// In en, this message translates to:
  /// **'This device is connected to your private backup. Changes continue to sync when the app is online.'**
  String get syncBackupEnabledBody;

  /// Headline on the sync backup page when cloud backup is enabled.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup is on'**
  String get syncBackupEnabledHeadline;

  /// Label for the last synced timestamp.
  ///
  /// In en, this message translates to:
  /// **'Last synced'**
  String get syncBackupLastSynced;

  /// Status when no sync timestamp is available yet.
  ///
  /// In en, this message translates to:
  /// **'Waiting for first sync'**
  String get syncBackupLastSyncedPending;

  /// Label for the signed-in cloud backup account.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get syncBackupSignedInAs;

  /// Button label for Apple sign-in.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get syncBackupSignInApple;

  /// Button label for Google sign-in.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get syncBackupSignInGoogle;

  /// Label for cloud backup status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get syncBackupStatus;

  /// Enabled cloud backup status value.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get syncBackupStatusEnabled;

  /// Syncing status value.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncBackupSyncing;

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

  /// Trust badge label on the welcome page describing no bank sync behavior.
  ///
  /// In en, this message translates to:
  /// **'No bank sync'**
  String get welcomeTrustNoBankSync;

  /// Title of the extra amount bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Extra amount'**
  String get planExtraAmountSheetTitle;

  /// Subtitle of the extra amount bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Increasing your extra monthly payment helps you shorten your debt-free timeline significantly.'**
  String get planExtraAmountSheetSubtitle;

  /// Save action in the extra amount bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get planExtraAmountSheetSave;

  /// Reset action in the extra amount bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Reset to \$0 (Minimum)'**
  String get planExtraAmountSheetReset;

  /// Title of the timeline page.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planTimelineTitle;

  /// Empty state title on the timeline page.
  ///
  /// In en, this message translates to:
  /// **'No plan to show yet'**
  String get planTimelineEmptyTitle;

  /// Empty state subtitle on the timeline page.
  ///
  /// In en, this message translates to:
  /// **'Add at least one debt so the app can recast your timeline, debt-free date, and projected interest.'**
  String get planTimelineEmptySubtitle;

  /// Title when all debts are paid off on the timeline page.
  ///
  /// In en, this message translates to:
  /// **'All debts are paid off'**
  String get planTimelineAllPaidTitle;

  /// Subtitle when all debts are paid off on the timeline page.
  ///
  /// In en, this message translates to:
  /// **'Monthly timeline has no active debts. The app keeps your last plan summary for reference.'**
  String get planTimelineAllPaidSubtitle;

  /// Text shown when timeline is recalculating.
  ///
  /// In en, this message translates to:
  /// **'Recasting...'**
  String get planTimelineRecasting;

  /// Summary string showing strategy, extra amount and projected months.
  ///
  /// In en, this message translates to:
  /// **'{strategy} · Extra {amount} / month · {months} months projected'**
  String planTimelineStrategySummary(
    String strategy,
    String amount,
    int months,
  );

  /// Neutral banner text on timeline page.
  ///
  /// In en, this message translates to:
  /// **'Plan was just recast from latest data.'**
  String get planTimelineRecastNeutral;

  /// Title of the interest comparison card.
  ///
  /// In en, this message translates to:
  /// **'Projected vs minimum-only'**
  String get planTimelineComparisonTitle;

  /// Label for the current plan in comparison.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get planTimelineComparisonCurrent;

  /// Label for the baseline plan in comparison.
  ///
  /// In en, this message translates to:
  /// **'Minimum-only baseline'**
  String get planTimelineComparisonBaseline;

  /// Label for saved interest in comparison.
  ///
  /// In en, this message translates to:
  /// **'Saved interest'**
  String get planTimelineComparisonSaved;

  /// Title for the monthly timeline section.
  ///
  /// In en, this message translates to:
  /// **'Monthly timeline'**
  String get planTimelineSectionTitle;

  /// Subtitle for the monthly timeline section.
  ///
  /// In en, this message translates to:
  /// **'List-first view with payment breakdown, ending balance, and milestone payoff based on the latest projection.'**
  String get planTimelineSectionSubtitle;

  /// Hero stat label for debt-free date.
  ///
  /// In en, this message translates to:
  /// **'Debt-free date'**
  String get planTimelineHeroDebtFree;

  /// Hero stat label for projected interest.
  ///
  /// In en, this message translates to:
  /// **'Projected interest'**
  String get planTimelineHeroProjectedInterest;

  /// Hero stat label for saved interest.
  ///
  /// In en, this message translates to:
  /// **'Saved vs minimum'**
  String get planTimelineHeroSavedVsMinimum;

  /// Mini stat label for ending balance.
  ///
  /// In en, this message translates to:
  /// **'Ending balance'**
  String get planTimelineMonthEndingBalance;

  /// Mini stat label for debts paid off.
  ///
  /// In en, this message translates to:
  /// **'Debts paid off'**
  String get planTimelineMonthDebtsPaidOff;

  /// Comparison label for starting balance.
  ///
  /// In en, this message translates to:
  /// **'Starting balance'**
  String get planTimelineMonthStartingBalance;

  /// Comparison label for interest accrued.
  ///
  /// In en, this message translates to:
  /// **'Interest accrued'**
  String get planTimelineMonthInterestAccrued;

  /// Comparison label for payment applied.
  ///
  /// In en, this message translates to:
  /// **'Payment applied'**
  String get planTimelineMonthPaymentApplied;

  /// Prefix for monthly payment amount.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get planTimelineMonthPaymentLabel;

  /// Prefix for monthly interest amount.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get planTimelineMonthInterestLabel;

  /// No description provided for @planTimelinePaidOffBadge.
  ///
  /// In en, this message translates to:
  /// **'Paid off'**
  String get planTimelinePaidOffBadge;

  /// Title for debt entry page in onboarding
  ///
  /// In en, this message translates to:
  /// **'Add Your First Debt'**
  String get onboardingDebtEntryTitle;

  /// Save action for debt entry page
  ///
  /// In en, this message translates to:
  /// **'Save Debt'**
  String get onboardingDebtEntrySave;

  /// Step 1 progress label
  ///
  /// In en, this message translates to:
  /// **'Step 1/4'**
  String get onboardingStep1;

  /// Title for add another debt page
  ///
  /// In en, this message translates to:
  /// **'Review Your Debts'**
  String get onboardingAddAnotherTitle;

  /// Step 2 progress label
  ///
  /// In en, this message translates to:
  /// **'Step 2/4'**
  String get onboardingStep2;

  /// Empty state text for add another debt page
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any debts yet.'**
  String get onboardingAddAnotherEmpty;

  /// Text showing count of saved debts
  ///
  /// In en, this message translates to:
  /// **'You have saved {count} debts. You can add more or continue to strategy selection.'**
  String onboardingAddAnotherCount(int count);

  /// Requirement text for adding debt
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 debt to continue onboarding.'**
  String get onboardingAddAnotherRequirement;

  /// Continue action to strategy selection
  ///
  /// In en, this message translates to:
  /// **'Choose Strategy'**
  String get onboardingAddAnotherContinue;

  /// Action to add another debt
  ///
  /// In en, this message translates to:
  /// **'Add Another Debt'**
  String get onboardingAddAnotherAddMore;

  /// Title for strategy selection page
  ///
  /// In en, this message translates to:
  /// **'Choose Strategy'**
  String get onboardingStrategyTitle;

  /// Step 3 progress label
  ///
  /// In en, this message translates to:
  /// **'Step 3/4'**
  String get onboardingStep3;

  /// Subtitle for strategy selection
  ///
  /// In en, this message translates to:
  /// **'Choose how the app prioritizes debts when you pay extra.'**
  String get onboardingStrategySubtitle;

  /// Requirement text for strategy selection
  ///
  /// In en, this message translates to:
  /// **'You need at least one debt to choose a strategy.'**
  String get onboardingStrategyRequirement;

  /// Description of strategy preview
  ///
  /// In en, this message translates to:
  /// **'The app is comparing live projections of Snowball and Avalanche based on your current debts.'**
  String get onboardingStrategyDescription;

  /// Empty state title for strategy selection
  ///
  /// In en, this message translates to:
  /// **'No debts to apply strategy'**
  String get onboardingStrategyEmptyTitle;

  /// Empty state subtitle for strategy selection
  ///
  /// In en, this message translates to:
  /// **'Please add at least one debt before continuing.'**
  String get onboardingStrategyEmptySubtitle;

  /// Action to go back and add debt
  ///
  /// In en, this message translates to:
  /// **'Go back and add debt'**
  String get onboardingStrategyBackToAdd;

  /// Fallback text for snowball strategy
  ///
  /// In en, this message translates to:
  /// **'Prioritize the smallest balance.'**
  String get onboardingStrategySnowballFallback;

  /// Fallback text for avalanche strategy
  ///
  /// In en, this message translates to:
  /// **'Prioritize the highest APR to reduce interest.'**
  String get onboardingStrategyAvalancheFallback;

  /// Note about changing strategy later
  ///
  /// In en, this message translates to:
  /// **'You can change your strategy anytime after onboarding. The plan summary and timeline will recast automatically.'**
  String get onboardingStrategyChangeNote;

  /// Action to save strategy and continue
  ///
  /// In en, this message translates to:
  /// **'Save Strategy & Continue'**
  String get onboardingStrategyContinue;

  /// Text when all debts are excluded from strategy
  ///
  /// In en, this message translates to:
  /// **'All debts are currently excluded from the strategy.'**
  String get onboardingStrategyTopPriorityExcluded;

  /// Text showing top priority debt
  ///
  /// In en, this message translates to:
  /// **'Start with {name}'**
  String onboardingStrategyTopPriority(String name);

  /// Text when preview is calculating
  ///
  /// In en, this message translates to:
  /// **'Calculating payoff date and projected interest from current data...'**
  String get onboardingStrategyPreviewCalculating;

  /// Text when preview is recasting
  ///
  /// In en, this message translates to:
  /// **'Recasting'**
  String get onboardingStrategyPreviewRecasting;

  /// Summary of strategy preview
  ///
  /// In en, this message translates to:
  /// **'Debt-free {date} · {duration} · interest {interest}'**
  String onboardingStrategyPreviewSummary(
    String date,
    String duration,
    String interest,
  );

  /// Text showing saved interest in preview
  ///
  /// In en, this message translates to:
  /// **'Save {saved} vs minimum-only'**
  String onboardingStrategyPreviewSaved(String saved);

  /// Error message when saving strategy fails
  ///
  /// In en, this message translates to:
  /// **'Could not save strategy. Please try again.'**
  String get onboardingStrategyError;

  /// Title for strategy preview
  ///
  /// In en, this message translates to:
  /// **'Current Preview'**
  String get onboardingStrategyPreviewTitle;

  /// Label for the projected payoff length in the selected strategy preview card.
  ///
  /// In en, this message translates to:
  /// **'Projected length'**
  String get onboardingStrategyPreviewProjectedLength;

  /// Title for extra amount page
  ///
  /// In en, this message translates to:
  /// **'Extra Budget'**
  String get onboardingExtraTitle;

  /// Step 4 progress label
  ///
  /// In en, this message translates to:
  /// **'Step 4/4'**
  String get onboardingStep4;

  /// Subtitle for extra amount page
  ///
  /// In en, this message translates to:
  /// **'Besides the minimum, how much extra do you want to pay each month?'**
  String get onboardingExtraSubtitle;

  /// Description for extra amount
  ///
  /// In en, this message translates to:
  /// **'Default is \$0. Preview will live recast after 300ms to show your actual debt-free date and saved interest.'**
  String get onboardingExtraDescription;

  /// Label for extra monthly payment
  ///
  /// In en, this message translates to:
  /// **'Extra payment per month'**
  String get onboardingExtraMonthlyLabel;

  /// Text showing strategy and tracked count
  ///
  /// In en, this message translates to:
  /// **'{strategy} · Tracking {count} debts'**
  String onboardingExtraTrackedCount(String strategy, int count);

  /// Label for max extra amount
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get onboardingExtraMaxLabel;

  /// Title for what's next section
  ///
  /// In en, this message translates to:
  /// **'What happens next?'**
  String get onboardingExtraWhatsNextTitle;

  /// Description for what's next
  ///
  /// In en, this message translates to:
  /// **'This extra amount will be used as additional budget each month. When you save, your plan summary and timeline cache will recast immediately.'**
  String get onboardingExtraWhatsNextDescription;

  /// Save action for extra amount
  ///
  /// In en, this message translates to:
  /// **'Save and view summary'**
  String get onboardingExtraSave;

  /// Action to use zero extra amount
  ///
  /// In en, this message translates to:
  /// **'Use \$0 for now'**
  String get onboardingExtraUseZero;

  /// Error message when saving extra amount fails
  ///
  /// In en, this message translates to:
  /// **'Could not save extra budget. Please try again.'**
  String get onboardingExtraError;

  /// Empty state text for extra preview
  ///
  /// In en, this message translates to:
  /// **'Add at least one debt to see the actual payoff preview.'**
  String get onboardingExtraPreviewEmpty;

  /// Title for live preview
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get onboardingExtraPreviewTitle;

  /// Text when extra preview is recasting
  ///
  /// In en, this message translates to:
  /// **'Recasting...'**
  String get onboardingExtraPreviewRecasting;

  /// Text showing debt-free date with extra amount
  ///
  /// In en, this message translates to:
  /// **'Debt-free date with extra {extraAmount} / month'**
  String onboardingExtraPreviewDebtFree(String extraAmount);

  /// Label for projected interest
  ///
  /// In en, this message translates to:
  /// **'Projected interest'**
  String get onboardingExtraPreviewProjectedInterest;

  /// Label for saved vs minimum
  ///
  /// In en, this message translates to:
  /// **'Saved vs minimum'**
  String get onboardingExtraPreviewSavedVsMinimum;

  /// Empty state text for aha moment
  ///
  /// In en, this message translates to:
  /// **'You have no debts in your plan yet.'**
  String get onboardingAhaEmpty;

  /// Text when aha moment is recasting
  ///
  /// In en, this message translates to:
  /// **'Your plan is recasting.'**
  String get onboardingAhaRecasting;

  /// Text showing debt-free date in aha moment
  ///
  /// In en, this message translates to:
  /// **'You can be debt-free by {date}.'**
  String onboardingAhaDebtFree(String date);

  /// Empty state subtitle for aha moment
  ///
  /// In en, this message translates to:
  /// **'Please go back to the previous step and add at least one debt.'**
  String get onboardingAhaEmptySubtitle;

  /// Ready subtitle for aha moment
  ///
  /// In en, this message translates to:
  /// **'Plan has been recast. Your monthly checklist is ready.'**
  String get onboardingAhaReadySubtitle;

  /// Title for aha moment summary
  ///
  /// In en, this message translates to:
  /// **'Current Summary'**
  String get onboardingAhaSummaryTitle;

  /// Label for total balance
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get onboardingAhaTotalBalance;

  /// Label for tracked count
  ///
  /// In en, this message translates to:
  /// **'Tracked Debts'**
  String get onboardingAhaTrackedCount;

  /// Compact text for local data
  ///
  /// In en, this message translates to:
  /// **'Data saved locally. No account needed.'**
  String get onboardingAhaDataCompact;

  /// Full text for local data
  ///
  /// In en, this message translates to:
  /// **'Your data is saved locally on your device. From here you can open the Monthly Action View to check off actual payments and watch the timeline recast instantly.'**
  String get onboardingAhaDataFull;

  /// Action to go back and add debt
  ///
  /// In en, this message translates to:
  /// **'Go back to add debt'**
  String get onboardingAhaBackToAdd;

  /// Action to open monthly view
  ///
  /// In en, this message translates to:
  /// **'Open Monthly Action View'**
  String get onboardingAhaOpenMonthly;

  /// Short text for recasting
  ///
  /// In en, this message translates to:
  /// **'Recasting'**
  String get onboardingAhaRecastingShort;

  /// Label for debt-free date in aha moment
  ///
  /// In en, this message translates to:
  /// **'Debt-free date'**
  String get onboardingAhaDebtFreeDate;

  /// Label for extra monthly amount in aha moment
  ///
  /// In en, this message translates to:
  /// **'Extra / month'**
  String get onboardingAhaExtraMonthly;

  /// Label for projected interest in aha moment
  ///
  /// In en, this message translates to:
  /// **'Projected interest'**
  String get onboardingAhaProjectedInterest;

  /// Label for saved vs minimum in aha moment
  ///
  /// In en, this message translates to:
  /// **'Saved vs minimum'**
  String get onboardingAhaSavedVsMinimum;

  /// Generic cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic confirm action.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Label for the total debt amount.
  ///
  /// In en, this message translates to:
  /// **'Total Debt'**
  String get commonTotalDebt;

  /// Label for notes input field.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// App bar title on the debt detail page.
  ///
  /// In en, this message translates to:
  /// **'Debt Details'**
  String get debtDetailTitle;

  /// Label for the initial principal.
  ///
  /// In en, this message translates to:
  /// **'Initial Principal'**
  String get debtDetailInitialPrincipal;

  /// Label for APR.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get debtDetailApr;

  /// Label for due date.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get debtDetailDueDate;

  /// Label for minimum payment.
  ///
  /// In en, this message translates to:
  /// **'Minimum payment'**
  String get debtDetailMinimumPayment;

  /// Label for interest calculation type.
  ///
  /// In en, this message translates to:
  /// **'Interest Calculation'**
  String get debtDetailInterestCalc;

  /// Button to log a payment.
  ///
  /// In en, this message translates to:
  /// **'Log payment'**
  String get debtDetailLogPayment;

  /// Button to view payment history.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get debtDetailViewHistory;

  /// Title for the archive confirmation.
  ///
  /// In en, this message translates to:
  /// **'Archive Debt?'**
  String get debtDetailArchiveTitle;

  /// Snackbar message after archiving a debt.
  ///
  /// In en, this message translates to:
  /// **'Debt archived.'**
  String get debtDetailArchivedMsg;

  /// Snackbar message after restoring an archived debt.
  ///
  /// In en, this message translates to:
  /// **'Debt restored to paid list.'**
  String get debtDetailUnarchivedMsg;

  /// Title for the delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete Debt?'**
  String get debtDetailDeleteTitle;

  /// Snackbar message after deleting a debt.
  ///
  /// In en, this message translates to:
  /// **'Debt deleted.'**
  String get debtDetailDeletedMsg;

  /// App bar title on the debts list page.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debtsListTitle;

  /// Filter tab for all debts.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get debtsListFilterAll;

  /// Filter tab for active debts.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get debtsListFilterActive;

  /// Filter tab for paid debts.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get debtsListFilterPaid;

  /// Filter tab for archived debts.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get debtsListFilterArchived;

  /// Error when debt is not found in log payment.
  ///
  /// In en, this message translates to:
  /// **'This debt no longer exists or has been deleted.'**
  String get logPaymentNotFound;

  /// App bar title on payment history page.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistoryTitle;

  /// Empty state when no payments match.
  ///
  /// In en, this message translates to:
  /// **'No payments for this filter'**
  String get paymentHistoryNoPayments;

  /// Option
  ///
  /// In en, this message translates to:
  /// **'Edit debt'**
  String get debtOptionsEdit;

  /// Option to pause debt payments
  ///
  /// In en, this message translates to:
  /// **'Pause payments'**
  String get debtOptionsPause;

  /// Subtitle for pause option
  ///
  /// In en, this message translates to:
  /// **'Temporarily stop payments'**
  String get debtOptionsPauseSubtitle;

  /// Option to resume paused debt
  ///
  /// In en, this message translates to:
  /// **'Resume payments'**
  String get debtOptionsResume;

  /// Subtitle for resume option with date
  ///
  /// In en, this message translates to:
  /// **'Auto-resumes on {date}'**
  String debtOptionsResumeSubtitle(Object date);

  /// Label for pause duration dropdown
  ///
  /// In en, this message translates to:
  /// **'Select pause duration'**
  String get debtPauseSelectDuration;

  /// Pause duration option
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get debtPause1Month;

  /// Pause duration option
  ///
  /// In en, this message translates to:
  /// **'2 months'**
  String get debtPause2Months;

  /// Pause duration option
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get debtPause3Months;

  /// Pause duration option
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get debtPause6Months;

  /// Snackbar message when debt is paused
  ///
  /// In en, this message translates to:
  /// **'Paused until {date}'**
  String debtPausedMsg(Object date);

  /// Snackbar message when debt is resumed
  ///
  /// In en, this message translates to:
  /// **'Resumed payments'**
  String get debtResumedMsg;

  /// Section header for paused debts
  ///
  /// In en, this message translates to:
  /// **'Paused ({count})'**
  String debtsListPausedSection(Object count);

  /// Subtitle for paused debt card
  ///
  /// In en, this message translates to:
  /// **'Paused until {date}'**
  String debtPausedUntil(Object date);

  /// Subtitle for paused debt without resume date
  ///
  /// In en, this message translates to:
  /// **'Paused indefinitely'**
  String get debtPausedIndefinitely;

  /// Button to resume paused debt
  ///
  /// In en, this message translates to:
  /// **'Resume now'**
  String get debtResumeNow;

  /// Button to view interest rate history
  ///
  /// In en, this message translates to:
  /// **'Interest rates'**
  String get debtDetailRateHistory;

  /// App bar title for rate history page
  ///
  /// In en, this message translates to:
  /// **'Interest Rate History'**
  String get rateHistoryTitle;

  /// Empty state when no rate history entries
  ///
  /// In en, this message translates to:
  /// **'No rate history'**
  String get rateHistoryEmpty;

  /// Subtitle for empty rate history
  ///
  /// In en, this message translates to:
  /// **'Interest rate will appear here when changed'**
  String get rateHistoryEmptySubtitle;

  /// Badge for currently active rate
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get rateHistoryCurrent;

  /// Badge for a future interest rate change
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get rateHistoryUpcoming;

  /// Dialog title for adding rate
  ///
  /// In en, this message translates to:
  /// **'Add Rate Change'**
  String get rateHistoryAddTitle;

  /// Dialog title for editing rate
  ///
  /// In en, this message translates to:
  /// **'Edit Rate Change'**
  String get rateHistoryEditTitle;

  /// Label for APR input
  ///
  /// In en, this message translates to:
  /// **'APR (%)'**
  String get rateHistoryAprLabel;

  /// Hint for APR input
  ///
  /// In en, this message translates to:
  /// **'e.g., 18.99'**
  String get rateHistoryAprHint;

  /// Validation error for APR
  ///
  /// In en, this message translates to:
  /// **'Enter a valid APR (0-100%)'**
  String get rateHistoryAprInvalid;

  /// Label for effective from date
  ///
  /// In en, this message translates to:
  /// **'Effective from'**
  String get rateHistoryEffectiveFrom;

  /// Label for effective to date
  ///
  /// In en, this message translates to:
  /// **'Effective to (optional)'**
  String get rateHistoryEffectiveTo;

  /// Period display for rate with only from date
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String rateHistoryEffectiveFromOnly(Object date);

  /// Period display for rate with from and to dates
  ///
  /// In en, this message translates to:
  /// **'{from} — {to}'**
  String rateHistoryEffectiveToPeriod(Object from, Object to);

  /// Label for reason field
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get rateHistoryReason;

  /// Hint for reason field
  ///
  /// In en, this message translates to:
  /// **'e.g., Promo expired, Refinanced'**
  String get rateHistoryReasonHint;

  /// Dialog title for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete rate?'**
  String get rateHistoryDeleteTitle;

  /// Dialog message for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this rate history entry.'**
  String get rateHistoryDeleteMessage;

  /// Snackbar message after deleting rate
  ///
  /// In en, this message translates to:
  /// **'Rate history deleted'**
  String get rateHistoryDeletedMsg;

  /// Checkbox label for open-ended interest rate with no expiry
  ///
  /// In en, this message translates to:
  /// **'No end date (current rate)'**
  String get rateHistoryOpenEnded;

  /// Generic delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Generic edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Generic add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Validation error for required field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// Generic error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// Option
  ///
  /// In en, this message translates to:
  /// **'Delete debt'**
  String get debtOptionsDelete;

  /// Subtitle
  ///
  /// In en, this message translates to:
  /// **'You can restore it right after deleting.'**
  String get debtOptionsDeleteSubtitle;

  /// App bar title on the edit debt page.
  ///
  /// In en, this message translates to:
  /// **'Edit Debt'**
  String get editDebtTitle;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get monthlyActionThisMonth;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'No checklist for this month'**
  String get monthlyActionNoChecklist;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'What you need to pay this month'**
  String get monthlyActionNeedToPay;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Total this month'**
  String get monthlyActionTotalThisMonth;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get monthlyActionCompleted;

  /// App bar title on the progress page.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// Empty state for the progress page.
  ///
  /// In en, this message translates to:
  /// **'No progress to show yet'**
  String get progressNoProgress;

  /// Title for the progress by debt section.
  ///
  /// In en, this message translates to:
  /// **'Progress by debt'**
  String get progressByDebt;

  /// Title for the plan summary section.
  ///
  /// In en, this message translates to:
  /// **'Plan summary'**
  String get progressPlanSummary;

  /// Label for debt free date.
  ///
  /// In en, this message translates to:
  /// **'Debt-free date'**
  String get progressDebtFreeDate;

  /// Label for projected interest.
  ///
  /// In en, this message translates to:
  /// **'Projected interest'**
  String get progressProjectedInterest;

  /// Label for saved vs minimum interest.
  ///
  /// In en, this message translates to:
  /// **'Saved vs minimum'**
  String get progressSavedVsMinimum;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Debt Info'**
  String get debtDetailInfo;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Data Warnings'**
  String get debtDetailWarnings;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Payment Tracking'**
  String get debtDetailTracking;

  /// Helper text.
  ///
  /// In en, this message translates to:
  /// **'Log real payments to reduce current balance, create an audit trail, and instantly recast your timeline.'**
  String get debtDetailTrackingHelper;

  /// Button to log a new charge.
  ///
  /// In en, this message translates to:
  /// **'Add Charge'**
  String get debtDetailAddCharge;

  /// Title of the new charge dialog.
  ///
  /// In en, this message translates to:
  /// **'Log New Charge'**
  String get newChargeDialogTitle;

  /// Label for the charge amount input.
  ///
  /// In en, this message translates to:
  /// **'Charge Amount'**
  String get newChargeAmountLabel;

  /// Label for the charge note input.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get newChargeNoteLabel;

  /// Button to save a new charge.
  ///
  /// In en, this message translates to:
  /// **'Save Charge'**
  String get newChargeSave;

  /// Success message when charge is added.
  ///
  /// In en, this message translates to:
  /// **'New charge added.'**
  String get newChargeSuccess;

  /// Error message for invalid charge amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get newChargeErrorInvalid;

  /// Message in archive dialog.
  ///
  /// In en, this message translates to:
  /// **'This paid-off debt will be moved to the archive.'**
  String get debtDetailArchiveMessage;

  /// Confirm button.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get debtDetailArchiveConfirm;

  /// Message in delete dialog.
  ///
  /// In en, this message translates to:
  /// **'This debt will be hidden, but you can recover it right after deleting.'**
  String get debtDetailDeleteMessage;

  /// Confirm button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get debtDetailDeleteConfirm;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'All debts'**
  String get debtsListSectionAll;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Active debts'**
  String get debtsListSectionActive;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Paid-off debts'**
  String get debtsListSectionPaidOff;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Archived debts'**
  String get debtsListSectionArchived;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'You have no debts. Add your first one.'**
  String get debtsListEmptyAll;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'You have no active debts being tracked.'**
  String get debtsListEmptyActive;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'You have no paid-off debts.'**
  String get debtsListEmptyPaidOff;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'You have no archived debts.'**
  String get debtsListEmptyArchived;

  /// Helper text.
  ///
  /// In en, this message translates to:
  /// **'Amount reduces current balance directly (balance-first model).'**
  String get logPaymentHelperAmount;

  /// Helper text.
  ///
  /// In en, this message translates to:
  /// **'This payment will create an audit trail with balance before/after and recast timeline immediately after saving.'**
  String get logPaymentAuditHelper;

  /// Error message.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0.'**
  String get logPaymentErrorInvalidAmount;

  /// Subtitle
  ///
  /// In en, this message translates to:
  /// **'All your tracked debts are paid off or paused. Timeline is still recast from latest data.'**
  String get monthlyActionNoChecklistSubtitle;

  /// Helper text
  ///
  /// In en, this message translates to:
  /// **'This checklist is computed directly from your strategy, timeline cache, and payment history.'**
  String get monthlyActionChecklistHelper;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Recasting...'**
  String get monthlyActionRecasting;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'In {monthYear}'**
  String monthlyActionInMonth(String monthYear);

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get monthlyActionLogged;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Check off'**
  String get monthlyActionCheckOff;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first debt so the app can start tracking your completion.'**
  String get progressEmptySubtitle;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Paid so far'**
  String get progressPaidSoFar;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount}'**
  String progressRemainingAmount(String amount);

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get progressOverall;

  /// Helper text
  ///
  /// In en, this message translates to:
  /// **'Progress here combines actual balance and recast plan summary. The previous overview from Home has been moved to this tab.'**
  String get progressTabHelper;

  /// Helper text
  ///
  /// In en, this message translates to:
  /// **'Based on current balance versus original principal for each debt.'**
  String get progressByDebtHelper;

  /// Payment streak label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} =1{1 month streak} other{{count} month streak}}'**
  String progressStreakMonths(int count);

  /// Label for interest saved vs minimum-only plan
  ///
  /// In en, this message translates to:
  /// **'Interest saved'**
  String get progressInterestSaved;

  /// Section title for earned milestones
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get progressAchievements;

  /// Celebration text for first payment milestone
  ///
  /// In en, this message translates to:
  /// **'First payment made!'**
  String get milestoneCelebrationFirstPayment;

  /// Celebration text for debt paid off milestone
  ///
  /// In en, this message translates to:
  /// **'Debt paid off!'**
  String get milestoneCelebrationDebtPaidOff;

  /// Celebration text for all-debt-free milestone
  ///
  /// In en, this message translates to:
  /// **'All debt-free!'**
  String get milestoneCelebrationAllDebtFree;

  /// Celebration text for 25% progress milestone
  ///
  /// In en, this message translates to:
  /// **'25% there!'**
  String get milestoneCelebrationProgress25;

  /// Celebration text for 50% progress milestone
  ///
  /// In en, this message translates to:
  /// **'Halfway there!'**
  String get milestoneCelebrationProgress50;

  /// Celebration text for 75% progress milestone
  ///
  /// In en, this message translates to:
  /// **'75% complete!'**
  String get milestoneCelebrationProgress75;

  /// Celebration text for 3-month streak milestone
  ///
  /// In en, this message translates to:
  /// **'3-month streak!'**
  String get milestoneCelebrationStreak3;

  /// Celebration text for 6-month streak milestone
  ///
  /// In en, this message translates to:
  /// **'6-month streak!'**
  String get milestoneCelebrationStreak6;

  /// Celebration text for 12-month streak milestone
  ///
  /// In en, this message translates to:
  /// **'1 year streak!'**
  String get milestoneCelebrationStreak12;

  /// Status text
  ///
  /// In en, this message translates to:
  /// **'This debt is marked as paid off.'**
  String get progressDebtPaidOffStatus;

  /// Status text
  ///
  /// In en, this message translates to:
  /// **'This debt is paused.'**
  String get progressDebtPausedStatus;

  /// Status text
  ///
  /// In en, this message translates to:
  /// **'Remaining {current} out of {original} principal'**
  String progressDebtRemainingVsOriginal(String current, String original);

  /// Subtitle
  ///
  /// In en, this message translates to:
  /// **'{count} payments logged · Current balance {balance}'**
  String paymentHistorySubtitle(int count, String balance);

  /// Label
  ///
  /// In en, this message translates to:
  /// **'By month'**
  String get paymentHistoryByMonth;

  /// Subtitle
  ///
  /// In en, this message translates to:
  /// **'Log payments from debt details or Monthly Action View to see actual history.'**
  String get paymentHistoryNoPaymentsSubtitle;

  /// Payment type
  ///
  /// In en, this message translates to:
  /// **'Fee adjustment'**
  String get paymentTypeFeeLabel;

  /// Payment type
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get paymentTypeRefundLabel;

  /// Payment type
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get paymentTypeChargeLabel;

  /// Option
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get debtOptionsUnarchive;

  /// Option
  ///
  /// In en, this message translates to:
  /// **'Archive debt'**
  String get debtOptionsArchive;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebtTitle;

  /// Action label
  ///
  /// In en, this message translates to:
  /// **'Save debt'**
  String get addDebtSave;

  /// Action label
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get addDebtSaveChanges;

  /// Common word for month
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get commonMonth;

  /// Title for report summary section
  ///
  /// In en, this message translates to:
  /// **'Report Summary'**
  String get reportsPreviewReportSummary;

  /// Label for total paid in report
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get reportsPreviewTotalPaid;

  /// Label for total interest in report
  ///
  /// In en, this message translates to:
  /// **'Total Interest'**
  String get reportsPreviewTotalInterest;

  /// Label for debt free date in report
  ///
  /// In en, this message translates to:
  /// **'Debt Free Date'**
  String get reportsPreviewDebtFreeDate;

  /// Button state while generating report
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get reportsPreviewGenerating;

  /// Button label to export to PDF
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get reportsPreviewExportToPdf;

  /// Not available placeholder
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get reportsPreviewNotAvailable;

  /// App bar title for the reports preview page
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsPreviewPageTitle;

  /// Title above the report range chips
  ///
  /// In en, this message translates to:
  /// **'Report range'**
  String get reportsPreviewRangeTitle;

  /// Monthly report range label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reportsPreviewRangeMonthly;

  /// Yearly report range label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get reportsPreviewRangeYearly;

  /// Full history report range label
  ///
  /// In en, this message translates to:
  /// **'Full history'**
  String get reportsPreviewRangeFullHistory;

  /// Title above the report preview rows
  ///
  /// In en, this message translates to:
  /// **'Preview rows'**
  String get reportsPreviewTableTitle;

  /// Error snackbar shown when report generation fails
  ///
  /// In en, this message translates to:
  /// **'Could not generate the report: {message}'**
  String reportsPreviewGenerateFailed(String message);

  /// Title in PDF report
  ///
  /// In en, this message translates to:
  /// **'Debt Payoff Manager'**
  String get reportsPdfAppTitle;

  /// Secondary title in PDF report
  ///
  /// In en, this message translates to:
  /// **'Amortization report'**
  String get reportsPdfAmortizationTitle;

  /// Label preceding the generated timestamp in the PDF report
  ///
  /// In en, this message translates to:
  /// **'Generated on'**
  String get reportsPdfGeneratedOnLabel;

  /// Page number format in PDF
  ///
  /// In en, this message translates to:
  /// **'Page {pageNumber} of {pagesCount}'**
  String reportsPdfPageXOfY(int pageNumber, int pagesCount);

  /// Column header in PDF
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get reportsPdfColMonth;

  /// Column header in PDF
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get reportsPdfColPayment;

  /// Column header in PDF
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get reportsPdfColPrincipal;

  /// Column header in PDF
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get reportsPdfColInterest;

  /// Column header in PDF
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get reportsPdfColBalance;

  /// App bar title for scenarios page
  ///
  /// In en, this message translates to:
  /// **'What-If Scenarios'**
  String get scenariosTitle;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No scenarios yet'**
  String get scenariosEmptyTitle;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a scenario to explore different payoff strategies side by side.'**
  String get scenariosEmptySubtitle;

  /// Dialog title for adding a scenario
  ///
  /// In en, this message translates to:
  /// **'New scenario'**
  String get scenariosAddTitle;

  /// Dialog title for renaming a scenario
  ///
  /// In en, this message translates to:
  /// **'Edit scenario'**
  String get scenariosEditTitle;

  /// Text field hint for scenario name
  ///
  /// In en, this message translates to:
  /// **'Scenario name'**
  String get scenariosNameHint;

  /// Dialog title for duplicating a scenario
  ///
  /// In en, this message translates to:
  /// **'Duplicate scenario'**
  String get scenariosDuplicateTitle;

  /// Badge shown on the active scenario
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get scenariosActiveBadge;

  /// Badge shown on the main scenario
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get scenariosMainBadge;

  /// Confirm button in delete dialog
  ///
  /// In en, this message translates to:
  /// **'Delete scenario'**
  String get scenariosDeleteConfirm;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'This scenario and its debts will be deleted. Payments are not affected.'**
  String get scenariosDeleteMessage;

  /// App bar title for scenario comparison page
  ///
  /// In en, this message translates to:
  /// **'Compare Scenarios'**
  String get scenariosCompareTitle;

  /// Prompt shown when no scenario is selected for comparison
  ///
  /// In en, this message translates to:
  /// **'Select a scenario to compare'**
  String get scenariosComparePickPrompt;

  /// Label for the first scenario selector
  ///
  /// In en, this message translates to:
  /// **'Scenario A'**
  String get scenariosCompareSelectA;

  /// Label for the second scenario selector
  ///
  /// In en, this message translates to:
  /// **'Scenario B'**
  String get scenariosCompareSelectB;

  /// Label for debt-free date in comparison
  ///
  /// In en, this message translates to:
  /// **'Debt-free date'**
  String get scenariosCompareDebtFreeDate;

  /// Label for total balance in comparison
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get scenariosCompareTotalBalance;

  /// Label for projected interest in comparison
  ///
  /// In en, this message translates to:
  /// **'Projected interest'**
  String get scenariosCompareProjectedInterest;

  /// Label for savings vs minimum-only in comparison
  ///
  /// In en, this message translates to:
  /// **'Saved vs minimum'**
  String get scenariosCompareSavedVsMinimum;

  /// Label for debt count in comparison
  ///
  /// In en, this message translates to:
  /// **'Debts tracked'**
  String get scenariosCompareTotalDebts;

  /// Shown when a scenario has no plan data
  ///
  /// In en, this message translates to:
  /// **'No plan yet'**
  String get scenariosCompareNoPlan;

  /// Placeholder when data is not available
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get scenariosCompareNotAvailable;

  /// Badge shown on the scenario with an earlier payoff date
  ///
  /// In en, this message translates to:
  /// **'{months} mo faster'**
  String scenariosCompareFaster(int months);

  /// Badge shown on the scenario with lower projected interest
  ///
  /// In en, this message translates to:
  /// **'{amount} less interest'**
  String scenariosCompareCheaper(String amount);

  /// Button label to open comparison page
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get scenariosCompareAction;

  /// Button label to open the what-if scenario lab
  ///
  /// In en, this message translates to:
  /// **'Create What-if'**
  String get scenariosCreateWhatIfAction;

  /// Section title for scenario assumptions
  ///
  /// In en, this message translates to:
  /// **'Assumptions'**
  String get scenariosAssumptionsTitle;

  /// Label for monthly payment commitment in comparison
  ///
  /// In en, this message translates to:
  /// **'Monthly commitment'**
  String get scenariosCompareMonthlyCommitment;

  /// Label for first payoff target in comparison
  ///
  /// In en, this message translates to:
  /// **'First target'**
  String get scenariosCompareFirstTarget;

  /// App bar title for the what-if scenario lab
  ///
  /// In en, this message translates to:
  /// **'Create What-if'**
  String get scenarioLabTitle;

  /// Short subtitle for the what-if scenario lab
  ///
  /// In en, this message translates to:
  /// **'Preview a meaningful change before saving it as a scenario.'**
  String get scenarioLabSubtitle;

  /// Section title for scenario lab templates
  ///
  /// In en, this message translates to:
  /// **'Choose an assumption'**
  String get scenarioLabTemplatesTitle;

  /// Scenario lab template title for extra monthly payments
  ///
  /// In en, this message translates to:
  /// **'Pay extra monthly'**
  String get scenarioLabTemplateExtraMonthly;

  /// Scenario lab template subtitle for extra monthly payments
  ///
  /// In en, this message translates to:
  /// **'See how a higher monthly commitment changes payoff date and interest.'**
  String get scenarioLabTemplateExtraMonthlySubtitle;

  /// Scenario lab template title for strategy change
  ///
  /// In en, this message translates to:
  /// **'Change strategy'**
  String get scenarioLabTemplateStrategy;

  /// Scenario lab template subtitle for strategy change
  ///
  /// In en, this message translates to:
  /// **'Compare snowball and avalanche without changing your active plan.'**
  String get scenarioLabTemplateStrategySubtitle;

  /// Scenario lab template title for a future lump sum
  ///
  /// In en, this message translates to:
  /// **'One-time bonus'**
  String get scenarioLabTemplateBonus;

  /// Scenario lab template subtitle for a future lump sum
  ///
  /// In en, this message translates to:
  /// **'Model a bonus, tax refund, or gift in a future release.'**
  String get scenarioLabTemplateBonusSubtitle;

  /// Section title for scenario lab input form
  ///
  /// In en, this message translates to:
  /// **'Assumption details'**
  String get scenarioLabAssumptionTitle;

  /// Currency field label for extra monthly amount
  ///
  /// In en, this message translates to:
  /// **'Extra amount per month'**
  String get scenarioLabExtraAmountLabel;

  /// Optional scenario name field label
  ///
  /// In en, this message translates to:
  /// **'Scenario name'**
  String get scenarioLabScenarioNameLabel;

  /// Optional scenario name field hint
  ///
  /// In en, this message translates to:
  /// **'Optional. Defaults to the assumption summary.'**
  String get scenarioLabScenarioNameHint;

  /// Action to preview scenario impact
  ///
  /// In en, this message translates to:
  /// **'Preview impact'**
  String get scenarioLabPreviewAction;

  /// Title for scenario lab impact card
  ///
  /// In en, this message translates to:
  /// **'Preview impact'**
  String get scenarioLabPreviewTitle;

  /// Action to save the previewed scenario
  ///
  /// In en, this message translates to:
  /// **'Save scenario'**
  String get scenarioLabSaveAction;

  /// Success title after saving a scenario
  ///
  /// In en, this message translates to:
  /// **'Scenario saved'**
  String get scenarioLabSavedTitle;

  /// Success message after saving a scenario
  ///
  /// In en, this message translates to:
  /// **'{name} is ready to compare or make active.'**
  String scenarioLabSavedBody(String name);

  /// Action to compare after saving a scenario
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get scenarioLabCompareAction;

  /// Action to make the saved scenario active
  ///
  /// In en, this message translates to:
  /// **'Make active'**
  String get scenarioLabMakeActiveAction;

  /// Preview metric label for debt-free date
  ///
  /// In en, this message translates to:
  /// **'Debt-free date'**
  String get scenarioLabDebtFreeDate;

  /// Preview metric label for projected interest
  ///
  /// In en, this message translates to:
  /// **'Projected interest'**
  String get scenarioLabProjectedInterest;

  /// Preview metric label for monthly commitment
  ///
  /// In en, this message translates to:
  /// **'Monthly commitment'**
  String get scenarioLabMonthlyCommitment;

  /// Preview metric label for first target debt
  ///
  /// In en, this message translates to:
  /// **'First target'**
  String get scenarioLabFirstTarget;

  /// Preview metric label for months saved or added
  ///
  /// In en, this message translates to:
  /// **'Timing impact'**
  String get scenarioLabTimingImpact;

  /// Preview metric label for interest saved or added
  ///
  /// In en, this message translates to:
  /// **'Interest impact'**
  String get scenarioLabInterestImpact;

  /// Preview value for faster payoff
  ///
  /// In en, this message translates to:
  /// **'{months} months earlier'**
  String scenarioLabMonthsEarlier(int months);

  /// Preview value for slower payoff
  ///
  /// In en, this message translates to:
  /// **'{months} months later'**
  String scenarioLabMonthsLater(int months);

  /// Preview value for interest saved
  ///
  /// In en, this message translates to:
  /// **'{amount} saved'**
  String scenarioLabInterestSaved(String amount);

  /// Preview value for added interest
  ///
  /// In en, this message translates to:
  /// **'{amount} more'**
  String scenarioLabInterestAdded(String amount);

  /// Shown when no debt can be targeted
  ///
  /// In en, this message translates to:
  /// **'No target'**
  String get scenarioLabNoTargetDebt;

  /// Shown when payoff timing does not change
  ///
  /// In en, this message translates to:
  /// **'No timing change'**
  String get scenarioLabNoTimingChange;

  /// Shown when projected interest does not change
  ///
  /// In en, this message translates to:
  /// **'No interest change'**
  String get scenarioLabNoInterestChange;

  /// Dialog title for copying debts between scenarios
  ///
  /// In en, this message translates to:
  /// **'Copy debts to another scenario'**
  String get scenariosCopyDebtsTitle;

  /// Confirmation message for copying debts
  ///
  /// In en, this message translates to:
  /// **'Debts from \'{source}\' will be copied to \'{target}\'. Existing debts in the target are kept. Payments are not copied.'**
  String scenariosCopyDebtsMessage(String source, String target);

  /// Confirm button for copying debts
  ///
  /// In en, this message translates to:
  /// **'Copy debts'**
  String get scenariosCopyDebtsConfirm;

  /// Snackbar after copying debts
  ///
  /// In en, this message translates to:
  /// **'Debts copied successfully'**
  String get scenariosCopyDebtsSuccess;

  /// Snackbar shown when there is no target scenario for copying debts
  ///
  /// In en, this message translates to:
  /// **'No other scenarios available.'**
  String get scenariosNoOtherScenarios;

  /// Delta banner headline naming the winning scenario
  ///
  /// In en, this message translates to:
  /// **'{name} is the better choice'**
  String scenariosCompareDeltaTitle(String name);

  /// Months faster label in delta banner
  ///
  /// In en, this message translates to:
  /// **'Debt-free {months} months earlier'**
  String scenariosCompareDeltaMonths(int months);

  /// Interest savings label in delta banner
  ///
  /// In en, this message translates to:
  /// **'Saves {amount} in interest'**
  String scenariosCompareDeltaInterest(String amount);

  /// Banner text when no clear winner
  ///
  /// In en, this message translates to:
  /// **'Both scenarios are equivalent'**
  String get scenariosCompareTie;

  /// Title for the monthly summary page
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get monthlySummaryTitle;

  /// Label for total paid section
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get monthlySummaryTotalPaid;

  /// Label for principal portion
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get monthlySummaryPrincipal;

  /// Label for interest portion
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get monthlySummaryInterest;

  /// Label for new charges section
  ///
  /// In en, this message translates to:
  /// **'New Charges'**
  String get monthlySummaryCharges;

  /// Section header for per-debt breakdown
  ///
  /// In en, this message translates to:
  /// **'By Debt'**
  String get monthlySummaryPerDebt;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No payments recorded this month'**
  String get monthlySummaryNoActivity;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Log a payment to see your progress here.'**
  String get monthlySummaryNoActivitySub;

  /// Positive variance label
  ///
  /// In en, this message translates to:
  /// **'Paid {amount} more than planned'**
  String monthlySummaryPaidMore(String amount);

  /// Negative variance label
  ///
  /// In en, this message translates to:
  /// **'Paid {amount} less than planned'**
  String monthlySummaryPaidLess(String amount);

  /// Balance reduction label for a debt
  ///
  /// In en, this message translates to:
  /// **'Balance reduced by {amount}'**
  String monthlySummaryBalanceReduced(String amount);

  /// Compact principal and interest breakdown for a monthly summary debt row
  ///
  /// In en, this message translates to:
  /// **'P: {principal} · I: {interest}'**
  String monthlySummaryPrincipalInterestBreakdown(
    String principal,
    String interest,
  );

  /// Settings row title for partner sharing
  ///
  /// In en, this message translates to:
  /// **'Partner Sharing'**
  String get settingsPartnerSharingTitle;

  /// Settings row subtitle when cloud sync is enabled
  ///
  /// In en, this message translates to:
  /// **'Invite a partner to view or help log payments.'**
  String get settingsPartnerSharingSubtitleEnabled;

  /// Settings row subtitle when cloud sync is disabled
  ///
  /// In en, this message translates to:
  /// **'Turn on cloud backup before sharing.'**
  String get settingsPartnerSharingSubtitleDisabled;

  /// Settings row status when partner sharing is enabled
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsPartnerSharingOn;

  /// Settings row status when partner sharing is disabled
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsPartnerSharingOff;

  /// Partner sharing page app bar title
  ///
  /// In en, this message translates to:
  /// **'Partner Sharing'**
  String get partnerSharingPageTitle;

  /// Partner sharing page header title
  ///
  /// In en, this message translates to:
  /// **'Share your payoff plan'**
  String get partnerSharingHeaderTitle;

  /// Partner sharing page header body
  ///
  /// In en, this message translates to:
  /// **'Invite a partner to view progress, stay accountable, or log payments when collaborative mode is enabled.'**
  String get partnerSharingHeaderBody;

  /// Partner sharing sign-in card title
  ///
  /// In en, this message translates to:
  /// **'Cloud backup required'**
  String get partnerSharingCloudRequiredTitle;

  /// Partner sharing sign-in card body
  ///
  /// In en, this message translates to:
  /// **'Partner sharing uses your cloud account so access can be revoked at any time.'**
  String get partnerSharingCloudRequiredBody;

  /// Owner shared plan card title
  ///
  /// In en, this message translates to:
  /// **'Your shared plan'**
  String get partnerSharingYourSharedPlan;

  /// Shared plan active status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get partnerSharingStatusActive;

  /// Shared plan pending invite status label
  ///
  /// In en, this message translates to:
  /// **'Invite pending'**
  String get partnerSharingStatusInvitePending;

  /// Shared plan off status label
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get partnerSharingStatusOff;

  /// Owner shared plan body when a partner exists
  ///
  /// In en, this message translates to:
  /// **'Your partner can access this payoff plan.'**
  String get partnerSharingOwnerHasPartner;

  /// Owner shared plan body when an invite is pending
  ///
  /// In en, this message translates to:
  /// **'An invite is waiting for your partner to accept.'**
  String get partnerSharingOwnerHasPending;

  /// Owner shared plan body when sharing is off
  ///
  /// In en, this message translates to:
  /// **'No one else can access your plan.'**
  String get partnerSharingOwnerNoAccess;

  /// Shared plan permission row label
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get partnerSharingPermission;

  /// Pending invite row label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get partnerSharingPending;

  /// Button label for creating another invite
  ///
  /// In en, this message translates to:
  /// **'Create another invite'**
  String get partnerSharingCreateAnotherInvite;

  /// Button and sheet title for inviting a partner
  ///
  /// In en, this message translates to:
  /// **'Invite partner'**
  String get partnerSharingInvitePartner;

  /// Partner plans section title
  ///
  /// In en, this message translates to:
  /// **'Plans shared with you'**
  String get partnerSharingPlansSharedWithYou;

  /// Empty state for plans shared with the user
  ///
  /// In en, this message translates to:
  /// **'Accepted partner plans will appear here.'**
  String get partnerSharingPlansEmpty;

  /// Button label for opening a shared plan
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get partnerSharingOpenSharedPlan;

  /// Label showing the owner of a shared plan
  ///
  /// In en, this message translates to:
  /// **'Shared by {ownerUid}'**
  String partnerSharingSharedBy(String ownerUid);

  /// Invite partner email field label
  ///
  /// In en, this message translates to:
  /// **'Partner email'**
  String get partnerSharingEmailLabel;

  /// Read-only sharing permission label
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get partnerSharingModeReadOnly;

  /// Collaborative sharing permission label
  ///
  /// In en, this message translates to:
  /// **'Collaborative'**
  String get partnerSharingModeCollaborative;

  /// Create invite link button label
  ///
  /// In en, this message translates to:
  /// **'Create invite link'**
  String get partnerSharingCreateInviteLink;

  /// Validation message for empty partner email
  ///
  /// In en, this message translates to:
  /// **'Enter a partner email.'**
  String get partnerSharingEnterPartnerEmail;

  /// Invite created sheet title
  ///
  /// In en, this message translates to:
  /// **'Invite link ready'**
  String get partnerSharingInviteReady;

  /// Text shared through the platform share sheet
  ///
  /// In en, this message translates to:
  /// **'Join my debt payoff plan: {url}'**
  String partnerSharingInviteText(String url);

  /// Share invite button label
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get partnerSharingShareInvite;

  /// Copy invite link button label
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get partnerSharingCopyLink;

  /// Snackbar after copying invite link
  ///
  /// In en, this message translates to:
  /// **'Invite link copied.'**
  String get partnerSharingInviteCopied;

  /// Button label for revoking partner access
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get partnerSharingRevoke;

  /// Accept invite page app bar title
  ///
  /// In en, this message translates to:
  /// **'Accept Invite'**
  String get inviteAcceptTitle;

  /// Accept invite title when token exists
  ///
  /// In en, this message translates to:
  /// **'Join shared payoff plan'**
  String get inviteAcceptJoinTitle;

  /// Accept invite title when token is missing
  ///
  /// In en, this message translates to:
  /// **'Invite link missing'**
  String get inviteAcceptMissingTitle;

  /// Accept invite body when token exists
  ///
  /// In en, this message translates to:
  /// **'Sign in and accept to view the plan your partner shared.'**
  String get inviteAcceptJoinBody;

  /// Accept invite body when token is missing
  ///
  /// In en, this message translates to:
  /// **'Ask your partner to send a new invite link.'**
  String get inviteAcceptMissingBody;

  /// Accept invite button label
  ///
  /// In en, this message translates to:
  /// **'Accept invite'**
  String get inviteAcceptButton;

  /// Error when accepting invite without sign-in
  ///
  /// In en, this message translates to:
  /// **'Sign in before accepting this invite.'**
  String get inviteAcceptSignInRequired;

  /// Shared plan page app bar title
  ///
  /// In en, this message translates to:
  /// **'Shared Plan'**
  String get sharedPlanTitle;

  /// Shared plan missing auth title
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get sharedPlanSignInRequiredTitle;

  /// Shared plan missing auth body
  ///
  /// In en, this message translates to:
  /// **'Use the invite link again after signing in.'**
  String get sharedPlanSignInRequiredBody;

  /// Shared plan revoked access title
  ///
  /// In en, this message translates to:
  /// **'Access unavailable'**
  String get sharedPlanAccessUnavailableTitle;

  /// Shared plan revoked access body
  ///
  /// In en, this message translates to:
  /// **'This shared plan was revoked or is no longer available.'**
  String get sharedPlanAccessUnavailableBody;

  /// Shared plan banner body for collaborative mode
  ///
  /// In en, this message translates to:
  /// **'You can view progress and log payments.'**
  String get sharedPlanCollaborativeBody;

  /// Shared plan banner body for read-only mode
  ///
  /// In en, this message translates to:
  /// **'You can view progress, but editing is off.'**
  String get sharedPlanReadOnlyBody;

  /// Shared plan balance card title
  ///
  /// In en, this message translates to:
  /// **'Shared balance'**
  String get sharedPlanBalanceTitle;

  /// Shared plan visible debt count
  ///
  /// In en, this message translates to:
  /// **'{count} debts visible in this shared plan'**
  String sharedPlanDebtCount(int count);

  /// Shared debt APR label
  ///
  /// In en, this message translates to:
  /// **'APR {apr}'**
  String sharedPlanApr(String apr);

  /// Shared debt log payment button label
  ///
  /// In en, this message translates to:
  /// **'Log payment'**
  String get sharedPlanLogPayment;

  /// Shared payment sheet title
  ///
  /// In en, this message translates to:
  /// **'Log shared payment'**
  String get sharedPlanLogPaymentTitle;

  /// Shared payment amount field label
  ///
  /// In en, this message translates to:
  /// **'Payment amount'**
  String get sharedPlanPaymentAmount;

  /// Shared payment note field label
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get sharedPlanNote;

  /// Shared payment save button label
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get sharedPlanSavePayment;

  /// Validation message for invalid shared payment amount
  ///
  /// In en, this message translates to:
  /// **'Enter a positive payment amount.'**
  String get sharedPlanPositiveAmountRequired;

  /// Snackbar after logging a shared payment
  ///
  /// In en, this message translates to:
  /// **'Payment logged.'**
  String get sharedPlanPaymentLogged;

  /// No description provided for @debtTypeCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get debtTypeCreditCard;

  /// No description provided for @debtTypeStudentLoan.
  ///
  /// In en, this message translates to:
  /// **'Student loan'**
  String get debtTypeStudentLoan;

  /// No description provided for @debtTypeCarLoan.
  ///
  /// In en, this message translates to:
  /// **'Car loan'**
  String get debtTypeCarLoan;

  /// No description provided for @debtTypeMortgage.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get debtTypeMortgage;

  /// No description provided for @debtTypePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal loan'**
  String get debtTypePersonal;

  /// No description provided for @debtTypeMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical debt'**
  String get debtTypeMedical;

  /// No description provided for @debtTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other debt'**
  String get debtTypeOther;

  /// No description provided for @debtStatusTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get debtStatusTracking;

  /// No description provided for @debtStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get debtStatusOverdue;

  /// No description provided for @debtSubtitleOverdueOneDay.
  ///
  /// In en, this message translates to:
  /// **'Overdue 1 day'**
  String get debtSubtitleOverdueOneDay;

  /// No description provided for @debtSubtitleOverdueDays.
  ///
  /// In en, this message translates to:
  /// **'Overdue {days} days'**
  String debtSubtitleOverdueDays(int days);

  /// No description provided for @debtSubtitleWithDueDay.
  ///
  /// In en, this message translates to:
  /// **'{overdueLabel} · APR {apr} · Due day {day}'**
  String debtSubtitleWithDueDay(String overdueLabel, String apr, int day);

  /// No description provided for @debtSubtitleAprDue.
  ///
  /// In en, this message translates to:
  /// **'APR {apr} · Due day {day}'**
  String debtSubtitleAprDue(String apr, int day);

  /// No description provided for @debtSubtitlePausedUntil.
  ///
  /// In en, this message translates to:
  /// **'Paused until {date}'**
  String debtSubtitlePausedUntil(String date);

  /// No description provided for @debtDetailCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get debtDetailCurrentBalance;

  /// No description provided for @debtDetailOriginalPrincipalValue.
  ///
  /// In en, this message translates to:
  /// **'Original principal {amount}'**
  String debtDetailOriginalPrincipalValue(String amount);

  /// No description provided for @debtDetailProgressComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String debtDetailProgressComplete(int percent);

  /// No description provided for @debtFormProgressComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String debtFormProgressComplete(int percent);

  /// No description provided for @debtFeedbackAdded.
  ///
  /// In en, this message translates to:
  /// **'Added debt \"{name}\".'**
  String debtFeedbackAdded(String name);

  /// No description provided for @debtFeedbackUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated debt \"{name}\".'**
  String debtFeedbackUpdated(String name);

  /// No description provided for @debtFeedbackArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived debt \"{name}\".'**
  String debtFeedbackArchived(String name);

  /// No description provided for @debtFeedbackUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Unarchived debt \"{name}\".'**
  String debtFeedbackUnarchived(String name);

  /// No description provided for @debtFeedbackPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused debt \"{name}\".'**
  String debtFeedbackPaused(String name);

  /// No description provided for @debtFeedbackResumed.
  ///
  /// In en, this message translates to:
  /// **'Resumed debt \"{name}\".'**
  String debtFeedbackResumed(String name);

  /// No description provided for @debtFeedbackDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted debt \"{name}\".'**
  String debtFeedbackDeleted(String name);

  /// No description provided for @debtFeedbackRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored debt \"{name}\".'**
  String debtFeedbackRestored(String name);

  /// No description provided for @interestMethodSimpleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Simple monthly interest'**
  String get interestMethodSimpleMonthly;

  /// No description provided for @interestMethodCompoundDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily compound interest'**
  String get interestMethodCompoundDaily;

  /// No description provided for @interestMethodCompoundMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly compound interest'**
  String get interestMethodCompoundMonthly;

  /// No description provided for @minimumPaymentTypeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get minimumPaymentTypeFixed;

  /// No description provided for @minimumPaymentTypePercentOfBalance.
  ///
  /// In en, this message translates to:
  /// **'% of balance'**
  String get minimumPaymentTypePercentOfBalance;

  /// No description provided for @minimumPaymentTypeInterestPlusPercent.
  ///
  /// In en, this message translates to:
  /// **'Interest + % principal'**
  String get minimumPaymentTypeInterestPlusPercent;

  /// No description provided for @paymentCadenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paymentCadenceMonthly;

  /// No description provided for @paymentCadenceBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Bi-weekly'**
  String get paymentCadenceBiweekly;

  /// No description provided for @paymentCadenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get paymentCadenceWeekly;

  /// No description provided for @paymentCadenceSemimonthly.
  ///
  /// In en, this message translates to:
  /// **'Semi-monthly'**
  String get paymentCadenceSemimonthly;

  /// No description provided for @debtFormDebtTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Debt type'**
  String get debtFormDebtTypeLabel;

  /// No description provided for @debtFormDebtTypeSemantic.
  ///
  /// In en, this message translates to:
  /// **'Debt type {type}'**
  String debtFormDebtTypeSemantic(String type);

  /// No description provided for @debtFormSelectedHint.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get debtFormSelectedHint;

  /// No description provided for @debtFormSwitchTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Switch form to {type}'**
  String debtFormSwitchTypeHint(String type);

  /// No description provided for @debtFormNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Debt name'**
  String get debtFormNameLabel;

  /// No description provided for @debtFormInlineErrorSemantic.
  ///
  /// In en, this message translates to:
  /// **'Form error. {message}'**
  String debtFormInlineErrorSemantic(String message);

  /// No description provided for @debtFormAdvancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get debtFormAdvancedSettings;

  /// No description provided for @debtFormCollapseAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Collapse advanced options'**
  String get debtFormCollapseAdvanced;

  /// No description provided for @debtFormOpenAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Open advanced options'**
  String get debtFormOpenAdvanced;

  /// No description provided for @debtFormInterestMethodSection.
  ///
  /// In en, this message translates to:
  /// **'Interest calculation'**
  String get debtFormInterestMethodSection;

  /// No description provided for @debtFormMinimumPaymentMethodSection.
  ///
  /// In en, this message translates to:
  /// **'Minimum payment calculation'**
  String get debtFormMinimumPaymentMethodSection;

  /// No description provided for @debtFormMinimumPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum percentage'**
  String get debtFormMinimumPercentLabel;

  /// No description provided for @debtFormMinimumFloorLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum floor'**
  String get debtFormMinimumFloorLabel;

  /// No description provided for @debtFormPaymentCadenceSection.
  ///
  /// In en, this message translates to:
  /// **'Payment cadence'**
  String get debtFormPaymentCadenceSection;

  /// No description provided for @debtFormStatusSection.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get debtFormStatusSection;

  /// No description provided for @debtFormPausedNoDateSemantic.
  ///
  /// In en, this message translates to:
  /// **'Debt is paused and no end date is selected'**
  String get debtFormPausedNoDateSemantic;

  /// No description provided for @debtFormPausedUntilSemantic.
  ///
  /// In en, this message translates to:
  /// **'Debt is paused until {date}'**
  String debtFormPausedUntilSemantic(String date);

  /// No description provided for @debtFormPausedUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused until'**
  String get debtFormPausedUntilLabel;

  /// No description provided for @debtFormNoDateSelected.
  ///
  /// In en, this message translates to:
  /// **'No date selected'**
  String get debtFormNoDateSelected;

  /// No description provided for @debtFormChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get debtFormChooseDate;

  /// No description provided for @debtFormExcludeFromStrategyTitle.
  ///
  /// In en, this message translates to:
  /// **'Exclude from payoff strategy'**
  String get debtFormExcludeFromStrategyTitle;

  /// No description provided for @debtFormExcludeFromStrategySubtitle.
  ///
  /// In en, this message translates to:
  /// **'This debt is saved but will not be prioritized in the plan.'**
  String get debtFormExcludeFromStrategySubtitle;

  /// No description provided for @debtFormCurrentBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining balance'**
  String get debtFormCurrentBalanceLabel;

  /// No description provided for @debtFormAprLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest rate (APR)'**
  String get debtFormAprLabel;

  /// No description provided for @debtFormSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested defaults for {type}'**
  String debtFormSuggestionTitle(String type);

  /// No description provided for @debtFormDefaultInterest.
  ///
  /// In en, this message translates to:
  /// **'Default interest: {method}'**
  String debtFormDefaultInterest(String method);

  /// No description provided for @debtFormWarningSemantic.
  ///
  /// In en, this message translates to:
  /// **'Warning. {message}'**
  String debtFormWarningSemantic(String message);

  /// No description provided for @debtFormMinimumPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum payment'**
  String get debtFormMinimumPaymentLabel;

  /// No description provided for @debtFormMonthlyPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment'**
  String get debtFormMonthlyPaymentLabel;

  /// No description provided for @debtFormDueDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Due day'**
  String get debtFormDueDayLabel;

  /// No description provided for @debtFormRemainingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining balance'**
  String get debtFormRemainingBalanceLabel;

  /// No description provided for @debtFormRemainingPrincipalLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining principal'**
  String get debtFormRemainingPrincipalLabel;

  /// No description provided for @debtFormOriginalLoanAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Original loan amount'**
  String get debtFormOriginalLoanAmountLabel;

  /// No description provided for @debtFormOriginalLoanValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Original loan value'**
  String get debtFormOriginalLoanValueLabel;

  /// No description provided for @debtFormOriginalPrincipalLabel.
  ///
  /// In en, this message translates to:
  /// **'Original principal'**
  String get debtFormOriginalPrincipalLabel;

  /// No description provided for @debtFormMinimumObligationHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the minimum obligation for each period.'**
  String get debtFormMinimumObligationHelper;

  /// No description provided for @debtFormStatementPriorityChip.
  ///
  /// In en, this message translates to:
  /// **'Statement priority'**
  String get debtFormStatementPriorityChip;

  /// No description provided for @debtFormFixedPaymentChip.
  ///
  /// In en, this message translates to:
  /// **'Fixed payment'**
  String get debtFormFixedPaymentChip;

  /// No description provided for @debtFormMonthlyCadenceChip.
  ///
  /// In en, this message translates to:
  /// **'Usually monthly'**
  String get debtFormMonthlyCadenceChip;

  /// No description provided for @debtFormFlexibleCadenceChip.
  ///
  /// In en, this message translates to:
  /// **'Can be bi-weekly or monthly'**
  String get debtFormFlexibleCadenceChip;

  /// No description provided for @debtFormVariableCadenceChip.
  ///
  /// In en, this message translates to:
  /// **'Cadence can vary'**
  String get debtFormVariableCadenceChip;

  /// No description provided for @debtFormAgreementPaymentChip.
  ///
  /// In en, this message translates to:
  /// **'Usually per agreement'**
  String get debtFormAgreementPaymentChip;

  /// No description provided for @debtFormFlexiblePaymentChip.
  ///
  /// In en, this message translates to:
  /// **'Flexible by real terms'**
  String get debtFormFlexiblePaymentChip;

  /// No description provided for @debtFormTipLatestStatement.
  ///
  /// In en, this message translates to:
  /// **'Latest statement'**
  String get debtFormTipLatestStatement;

  /// No description provided for @debtFormTipAccurateApr.
  ///
  /// In en, this message translates to:
  /// **'Accurate APR'**
  String get debtFormTipAccurateApr;

  /// No description provided for @debtFormTipDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get debtFormTipDueDate;

  /// No description provided for @debtFormTipRemainingPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Remaining principal'**
  String get debtFormTipRemainingPrincipal;

  /// No description provided for @debtFormTipAutoDebit.
  ///
  /// In en, this message translates to:
  /// **'Auto-debit'**
  String get debtFormTipAutoDebit;

  /// No description provided for @debtFormTipDefermentPause.
  ///
  /// In en, this message translates to:
  /// **'Can pause for deferment'**
  String get debtFormTipDefermentPause;

  /// No description provided for @debtFormTipFixedApr.
  ///
  /// In en, this message translates to:
  /// **'Fixed APR'**
  String get debtFormTipFixedApr;

  /// No description provided for @debtFormTipPrincipalOnly.
  ///
  /// In en, this message translates to:
  /// **'Principal only'**
  String get debtFormTipPrincipalOnly;

  /// No description provided for @debtFormTipFirstDayCommon.
  ///
  /// In en, this message translates to:
  /// **'1st day is common'**
  String get debtFormTipFirstDayCommon;

  /// No description provided for @debtFormTipExtraLater.
  ///
  /// In en, this message translates to:
  /// **'Enter extra payments later'**
  String get debtFormTipExtraLater;

  /// No description provided for @debtFormTipFixedPayment.
  ///
  /// In en, this message translates to:
  /// **'Fixed payment'**
  String get debtFormTipFixedPayment;

  /// No description provided for @debtFormTipLenderApr.
  ///
  /// In en, this message translates to:
  /// **'Lender APR'**
  String get debtFormTipLenderApr;

  /// No description provided for @debtFormTipAprCanBeZero.
  ///
  /// In en, this message translates to:
  /// **'APR can be 0'**
  String get debtFormTipAprCanBeZero;

  /// No description provided for @debtFormTipPaymentPlan.
  ///
  /// In en, this message translates to:
  /// **'Payment plan'**
  String get debtFormTipPaymentPlan;

  /// No description provided for @debtFormTipNoFixedDate.
  ///
  /// In en, this message translates to:
  /// **'May have no fixed date'**
  String get debtFormTipNoFixedDate;

  /// No description provided for @debtFormTipFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get debtFormTipFlexible;

  /// No description provided for @debtFormTipStartAtZero.
  ///
  /// In en, this message translates to:
  /// **'Can start at 0%'**
  String get debtFormTipStartAtZero;

  /// No description provided for @debtFormTipAdjustLater.
  ///
  /// In en, this message translates to:
  /// **'Adjust later'**
  String get debtFormTipAdjustLater;

  /// No description provided for @debtFormCreditCardHeadline.
  ///
  /// In en, this message translates to:
  /// **'Follow the latest statement'**
  String get debtFormCreditCardHeadline;

  /// No description provided for @debtFormCreditCardSummary.
  ///
  /// In en, this message translates to:
  /// **'Prioritize the current statement balance, statement APR, and latest minimum payment.'**
  String get debtFormCreditCardSummary;

  /// No description provided for @debtFormCreditCardNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Chase Sapphire, Citi Double Cash'**
  String get debtFormCreditCardNameHint;

  /// No description provided for @debtFormCreditCardNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the issuer or card name so it is easy to recognize.'**
  String get debtFormCreditCardNameHelper;

  /// No description provided for @debtFormCreditCardBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Statement balance'**
  String get debtFormCreditCardBalanceLabel;

  /// No description provided for @debtFormCreditCardBalanceHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the balance you need to pay off right now.'**
  String get debtFormCreditCardBalanceHelper;

  /// No description provided for @debtFormCreditCardOriginalPrincipalLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance when tracking started'**
  String get debtFormCreditCardOriginalPrincipalLabel;

  /// No description provided for @debtFormCreditCardOriginalPrincipalHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional. Useful if you want the app to show progress from today.'**
  String get debtFormCreditCardOriginalPrincipalHelper;

  /// No description provided for @debtFormCreditCardDeferredPrincipalHint.
  ///
  /// In en, this message translates to:
  /// **'If you know the balance when tracking started, open Advanced to track progress more accurately.'**
  String get debtFormCreditCardDeferredPrincipalHint;

  /// No description provided for @debtFormCreditCardAprHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the APR shown on the statement or banking app.'**
  String get debtFormCreditCardAprHelper;

  /// No description provided for @debtFormCreditCardMinimumPaymentHelper.
  ///
  /// In en, this message translates to:
  /// **'Take this directly from the latest statement.'**
  String get debtFormCreditCardMinimumPaymentHelper;

  /// No description provided for @debtFormCreditCardDueDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Statement due day'**
  String get debtFormCreditCardDueDayLabel;

  /// No description provided for @debtFormCreditCardDueDayHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 15'**
  String get debtFormCreditCardDueDayHint;

  /// No description provided for @debtFormCreditCardDueDayHelper.
  ///
  /// In en, this message translates to:
  /// **'The day you need to pay the minimum to avoid fees and overdue status.'**
  String get debtFormCreditCardDueDayHelper;

  /// No description provided for @debtFormCreditCardAdvancedGuidance.
  ///
  /// In en, this message translates to:
  /// **'Credit cards usually use daily compound interest. The app suggests that as the default.'**
  String get debtFormCreditCardAdvancedGuidance;

  /// No description provided for @debtFormStudentLoanHeadline.
  ///
  /// In en, this message translates to:
  /// **'Long-term installment loan'**
  String get debtFormStudentLoanHeadline;

  /// No description provided for @debtFormStudentLoanSummary.
  ///
  /// In en, this message translates to:
  /// **'Focus on remaining balance, fixed minimum payment, and monthly auto-debit day.'**
  String get debtFormStudentLoanSummary;

  /// No description provided for @debtFormStudentLoanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Federal Loan, Sallie Mae'**
  String get debtFormStudentLoanNameHint;

  /// No description provided for @debtFormStudentLoanNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the servicer or loan name so you do not mix up loans.'**
  String get debtFormStudentLoanNameHelper;

  /// No description provided for @debtFormStudentLoanBalanceHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the remaining principal from the loan portal.'**
  String get debtFormStudentLoanBalanceHelper;

  /// No description provided for @debtFormStudentLoanOriginalPrincipalHelper.
  ///
  /// In en, this message translates to:
  /// **'Helps the app show payoff progress from disbursement.'**
  String get debtFormStudentLoanOriginalPrincipalHelper;

  /// No description provided for @debtFormStudentLoanAprHelper.
  ///
  /// In en, this message translates to:
  /// **'Many student loans use a fixed monthly APR.'**
  String get debtFormStudentLoanAprHelper;

  /// No description provided for @debtFormStudentLoanMinimumPaymentHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the current monthly repayment schedule.'**
  String get debtFormStudentLoanMinimumPaymentHelper;

  /// No description provided for @debtFormAutoDebitDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-debit day'**
  String get debtFormAutoDebitDayLabel;

  /// No description provided for @debtFormStudentLoanDueDayHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5'**
  String get debtFormStudentLoanDueDayHint;

  /// No description provided for @debtFormStudentLoanDueDayHelper.
  ///
  /// In en, this message translates to:
  /// **'The day the system usually drafts payment or marks it due.'**
  String get debtFormStudentLoanDueDayHelper;

  /// No description provided for @debtFormStudentLoanAdvancedGuidance.
  ///
  /// In en, this message translates to:
  /// **'Student loans often have stable terms; simple monthly is usually the right default.'**
  String get debtFormStudentLoanAdvancedGuidance;

  /// No description provided for @debtFormCarLoanHeadline.
  ///
  /// In en, this message translates to:
  /// **'Asset installment loan'**
  String get debtFormCarLoanHeadline;

  /// No description provided for @debtFormCarLoanSummary.
  ///
  /// In en, this message translates to:
  /// **'Prioritize remaining principal, fixed payment, and due day to avoid late periods.'**
  String get debtFormCarLoanSummary;

  /// No description provided for @debtFormCarLoanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Toyota Financial, Wells Fargo Auto'**
  String get debtFormCarLoanNameHint;

  /// No description provided for @debtFormCarLoanNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Tie it to the lender or car for easy matching.'**
  String get debtFormCarLoanNameHelper;

  /// No description provided for @debtFormCarLoanBalanceHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the remaining principal from the lender if available.'**
  String get debtFormCarLoanBalanceHelper;

  /// No description provided for @debtFormCarLoanOriginalPrincipalHelper.
  ///
  /// In en, this message translates to:
  /// **'Helps you see how much of the loan has been paid down.'**
  String get debtFormCarLoanOriginalPrincipalHelper;

  /// No description provided for @debtFormCarLoanAprHelper.
  ///
  /// In en, this message translates to:
  /// **'Car loans usually use fixed APR and monthly compounding.'**
  String get debtFormCarLoanAprHelper;

  /// No description provided for @debtFormCarLoanDueDayHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 12'**
  String get debtFormCarLoanDueDayHint;

  /// No description provided for @debtFormCarLoanDueDayHelper.
  ///
  /// In en, this message translates to:
  /// **'The day the lender marks the current period paid or late.'**
  String get debtFormCarLoanDueDayHelper;

  /// No description provided for @debtFormCarLoanAdvancedGuidance.
  ///
  /// In en, this message translates to:
  /// **'Car loans usually match monthly compounding and a fixed minimum payment.'**
  String get debtFormCarLoanAdvancedGuidance;

  /// No description provided for @debtFormMortgageHeadline.
  ///
  /// In en, this message translates to:
  /// **'Track principal, not home value'**
  String get debtFormMortgageHeadline;

  /// No description provided for @debtFormMortgageSummary.
  ///
  /// In en, this message translates to:
  /// **'Enter the principal still owed, minimum monthly payment, and mortgage due day.'**
  String get debtFormMortgageSummary;

  /// No description provided for @debtFormMortgageNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Primary Home Mortgage'**
  String get debtFormMortgageNameHint;

  /// No description provided for @debtFormMortgageNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the loan name or a shortened address.'**
  String get debtFormMortgageNameHelper;

  /// No description provided for @debtFormMortgageBalanceHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter only the principal balance, not the home value.'**
  String get debtFormMortgageBalanceHelper;

  /// No description provided for @debtFormMortgageOriginalPrincipalHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the original mortgage amount so the app can calculate paid-down progress.'**
  String get debtFormMortgageOriginalPrincipalHelper;

  /// No description provided for @debtFormMortgageAprHelper.
  ///
  /// In en, this message translates to:
  /// **'Standard mortgages usually use simple monthly interest.'**
  String get debtFormMortgageAprHelper;

  /// No description provided for @debtFormMortgageMinimumPaymentHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter only the minimum monthly obligation, excluding extra principal.'**
  String get debtFormMortgageMinimumPaymentHelper;

  /// No description provided for @debtFormMortgageDueDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Mortgage due day'**
  String get debtFormMortgageDueDayLabel;

  /// No description provided for @debtFormMortgageDueDayHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1'**
  String get debtFormMortgageDueDayHint;

  /// No description provided for @debtFormMortgageDueDayHelper.
  ///
  /// In en, this message translates to:
  /// **'Many mortgages are due at the start of the month.'**
  String get debtFormMortgageDueDayHelper;

  /// No description provided for @debtFormMortgageAdvancedGuidance.
  ///
  /// In en, this message translates to:
  /// **'For mortgages, simple monthly interest and a fixed minimum are usually closest to reality.'**
  String get debtFormMortgageAdvancedGuidance;

  /// No description provided for @debtFormPersonalLoanHeadline.
  ///
  /// In en, this message translates to:
  /// **'Unsecured installment loan'**
  String get debtFormPersonalLoanHeadline;

  /// No description provided for @debtFormPersonalLoanSummary.
  ///
  /// In en, this message translates to:
  /// **'Focus on remaining principal, current minimum payment, and the day the lender collects payment.'**
  String get debtFormPersonalLoanSummary;

  /// No description provided for @debtFormPersonalLoanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., SoFi Personal Loan, LendingClub'**
  String get debtFormPersonalLoanNameHint;

  /// No description provided for @debtFormPersonalLoanNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the lender name or loan purpose.'**
  String get debtFormPersonalLoanNameHelper;

  /// No description provided for @debtFormPersonalLoanBalanceHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the lender app or latest statement.'**
  String get debtFormPersonalLoanBalanceHelper;

  /// No description provided for @debtFormPersonalLoanOriginalPrincipalHelper.
  ///
  /// In en, this message translates to:
  /// **'Helps the app show progress for the personal loan.'**
  String get debtFormPersonalLoanOriginalPrincipalHelper;

  /// No description provided for @debtFormPersonalLoanAprHelper.
  ///
  /// In en, this message translates to:
  /// **'Personal loans usually use monthly compounding.'**
  String get debtFormPersonalLoanAprHelper;

  /// No description provided for @debtFormPersonalLoanMinimumPaymentHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the current payment obligation for each period.'**
  String get debtFormPersonalLoanMinimumPaymentHelper;

  /// No description provided for @debtFormPersonalLoanDueDayHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 18'**
  String get debtFormPersonalLoanDueDayHint;

  /// No description provided for @debtFormPersonalLoanDueDayHelper.
  ///
  /// In en, this message translates to:
  /// **'The day the lender marks you late if unpaid.'**
  String get debtFormPersonalLoanDueDayHelper;

  /// No description provided for @debtFormPersonalLoanAdvancedGuidance.
  ///
  /// In en, this message translates to:
  /// **'Personal loans usually follow standard amortization: monthly compounding and fixed payments.'**
  String get debtFormPersonalLoanAdvancedGuidance;

  /// No description provided for @debtFormMedicalHeadline.
  ///
  /// In en, this message translates to:
  /// **'Often a softer payment plan'**
  String get debtFormMedicalHeadline;

  /// No description provided for @debtFormMedicalSummary.
  ///
  /// In en, this message translates to:
  /// **'If the debt has no interest, enter APR as 0 and use the agreed payment amount.'**
  String get debtFormMedicalSummary;

  /// No description provided for @debtFormMedicalNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., City Hospital Billing'**
  String get debtFormMedicalNameHint;

  /// No description provided for @debtFormMedicalNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the hospital, clinic, or collection agency name.'**
  String get debtFormMedicalNameHelper;

  /// No description provided for @debtFormMedicalBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount still owed'**
  String get debtFormMedicalBalanceLabel;

  /// No description provided for @debtFormMedicalBalanceHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the remaining balance on the current payment plan.'**
  String get debtFormMedicalBalanceHelper;

  /// No description provided for @debtFormMedicalOriginalPrincipalLabel.
  ///
  /// In en, this message translates to:
  /// **'Original bill total'**
  String get debtFormMedicalOriginalPrincipalLabel;

  /// No description provided for @debtFormMedicalOriginalPrincipalHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional. Use this if you want to see how much of the bill has been paid.'**
  String get debtFormMedicalOriginalPrincipalHelper;

  /// No description provided for @debtFormMedicalDeferredPrincipalHint.
  ///
  /// In en, this message translates to:
  /// **'If you want to track the original bill total, open Advanced and enter the original amount.'**
  String get debtFormMedicalDeferredPrincipalHint;

  /// No description provided for @debtFormMedicalAprHelper.
  ///
  /// In en, this message translates to:
  /// **'Many medical debt plans are 0%, so enter 0 if that matches reality.'**
  String get debtFormMedicalAprHelper;

  /// No description provided for @debtFormMedicalMinimumPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current period payment'**
  String get debtFormMedicalMinimumPaymentLabel;

  /// No description provided for @debtFormMedicalMinimumPaymentHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount requested by the hospital or agency.'**
  String get debtFormMedicalMinimumPaymentHelper;

  /// No description provided for @debtFormMedicalDueDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment appointment day'**
  String get debtFormMedicalDueDayLabel;

  /// No description provided for @debtFormMedicalDueDayHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 20'**
  String get debtFormMedicalDueDayHint;

  /// No description provided for @debtFormMedicalDueDayHelper.
  ///
  /// In en, this message translates to:
  /// **'You can leave it blank and default to 15 if the schedule is unclear.'**
  String get debtFormMedicalDueDayHelper;

  /// No description provided for @debtFormMedicalAdvancedGuidance.
  ///
  /// In en, this message translates to:
  /// **'Medical debt is often simpler: fixed minimum, APR may be 0, and fewer settings are needed.'**
  String get debtFormMedicalAdvancedGuidance;

  /// No description provided for @debtFormOtherHeadline.
  ///
  /// In en, this message translates to:
  /// **'Flexible setup for real life'**
  String get debtFormOtherHeadline;

  /// No description provided for @debtFormOtherSummary.
  ///
  /// In en, this message translates to:
  /// **'Use this for debts that do not match a standard type. Enter balance, APR, minimum, then tune Advanced.'**
  String get debtFormOtherSummary;

  /// No description provided for @debtFormOtherNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Store Financing, Family Loan'**
  String get debtFormOtherNameHint;

  /// No description provided for @debtFormOtherNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Use a clear name so you remember what this debt is later.'**
  String get debtFormOtherNameHelper;

  /// No description provided for @debtFormOtherBalanceHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter what you currently owe.'**
  String get debtFormOtherBalanceHelper;

  /// No description provided for @debtFormOtherOriginalPrincipalHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional. Useful if you want the app to show better progress.'**
  String get debtFormOtherOriginalPrincipalHelper;

  /// No description provided for @debtFormOtherDeferredPrincipalHint.
  ///
  /// In en, this message translates to:
  /// **'You can add the original principal in Advanced if you want to track progress.'**
  String get debtFormOtherDeferredPrincipalHint;

  /// No description provided for @debtFormOtherAprHelper.
  ///
  /// In en, this message translates to:
  /// **'Not sure about APR? Start with 0 and update later.'**
  String get debtFormOtherAprHelper;

  /// No description provided for @debtFormOtherMinimumPaymentHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the minimum amount you must pay each period.'**
  String get debtFormOtherMinimumPaymentHelper;

  /// No description provided for @debtFormOtherDueDayHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 15'**
  String get debtFormOtherDueDayHint;

  /// No description provided for @debtFormOtherDueDayHelper.
  ///
  /// In en, this message translates to:
  /// **'If unsure, keep the default and adjust later.'**
  String get debtFormOtherDueDayHelper;

  /// No description provided for @debtFormOtherAdvancedGuidance.
  ///
  /// In en, this message translates to:
  /// **'This type is the most flexible. Keep the defaults first and tune them when details are clear.'**
  String get debtFormOtherAdvancedGuidance;
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
