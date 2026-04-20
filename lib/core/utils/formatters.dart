import 'package:intl/intl.dart';

import '../i18n/app_locale.dart';

/// Formatters for display purposes only — NOT for calculations.
///
/// Reference: financial-engine-spec.md §2
/// "intl — chỉ dùng cho format/display, KHÔNG dùng cho tính toán"
class AppFormatters {
  AppFormatters._();

  static final _percentFormat = NumberFormat.decimalPercentPattern(
    decimalDigits: 2,
  );

  /// Format cents as currency string.
  ///
  /// Example: 123456 → "$1,234.56"
  static String formatCents(
    int cents, {
    String currencyCode = 'USD',
    String localeCode = AppLocale.fallbackLocaleCode,
  }) {
    final locale = AppLocale.intlFormatTag(localeCode);
    final format = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: _currencySymbolFor(currencyCode),
      decimalDigits: currencyCode.toUpperCase() == 'VND' ? 0 : 2,
    );
    return format.format(cents / 100);
  }

  /// Format a decimal APR as percentage string.
  ///
  /// Example: 0.1899 → "18.99%"
  static String formatApr(double apr) {
    return _percentFormat.format(apr);
  }

  /// Format a date.
  ///
  /// Example: DateTime(2026, 4, 16) → "Apr 16, 2026"
  static String formatDate(
    DateTime date, {
    String localeCode = AppLocale.fallbackLocaleCode,
  }) {
    return DateFormat.yMMMd(AppLocale.intlFormatTag(localeCode)).format(date);
  }

  /// Format month and year.
  ///
  /// Example: DateTime(2028, 7) → "July 2028"
  static String formatMonthYear(
    DateTime date, {
    String localeCode = AppLocale.fallbackLocaleCode,
  }) {
    return DateFormat.yMMMM(AppLocale.intlFormatTag(localeCode)).format(date);
  }

  /// Format short month and year.
  ///
  /// Example: DateTime(2028, 7) → "Jul 2028"
  static String formatShortMonthYear(
    DateTime date, {
    String localeCode = AppLocale.fallbackLocaleCode,
  }) {
    return DateFormat.yMMM(AppLocale.intlFormatTag(localeCode)).format(date);
  }

  /// Format date and time for lightweight previews and settings surfaces.
  static String formatDateTime(
    DateTime date, {
    String localeCode = AppLocale.fallbackLocaleCode,
  }) {
    return DateFormat.yMd(
      AppLocale.intlFormatTag(localeCode),
    ).add_Hm().format(date);
  }

  /// Format months duration as human-readable string.
  ///
  /// Example: 29 → "2 years 5 months"
  static String formatMonthsDuration(int totalMonths) {
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;

    if (years == 0) return '$months month${months != 1 ? 's' : ''}';
    if (months == 0) return '$years year${years != 1 ? 's' : ''}';
    return '$years year${years != 1 ? 's' : ''} '
        '$months month${months != 1 ? 's' : ''}';
  }

  static String _currencySymbolFor(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return r'$';
      case 'VND':
        return '₫';
      default:
        return currencyCode;
    }
  }
}
