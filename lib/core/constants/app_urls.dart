/// Central registry of external URLs used in the app.
///
/// Keeping these in one place makes it easy to update if the landing-page
/// domain ever changes, and avoids hard-coded strings scattered across UI.
class AppUrls {
  AppUrls._();

  /// Landing-page base URL (Firebase Hosting).
  static const _base = 'https://debt-payoff-manager-e6283.web.app';

  /// Privacy Policy — required in every subscription purchase flow (3.1.2c).
  static const privacyPolicy = '$_base/privacy';

  /// Terms of Service / EULA — required in every subscription purchase flow (3.1.2c).
  static const termsOfService = '$_base/terms';
}
