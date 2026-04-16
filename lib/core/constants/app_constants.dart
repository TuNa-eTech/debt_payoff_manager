/// App-wide constants for Debt Payoff Manager.
class AppConstants {
  AppConstants._();

  static const String appName = 'Debt Payoff Manager';
  static const String appVersion = '1.0.0';

  /// Maximum number of months to simulate (50 years safety cap).
  static const int maxSimulationMonths = 600;

  /// Maximum length for debt name.
  static const int maxDebtNameLength = 60;

  /// Maximum length for payment note.
  static const int maxPaymentNoteLength = 200;

  /// Default days in year for interest calculation.
  static const int daysInYear = 365;

  /// Average days per month (365/12).
  static const double avgDaysPerMonth = 30.4167;
}
