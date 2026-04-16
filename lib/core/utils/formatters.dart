import 'package:intl/intl.dart';

/// Formatters for display purposes only — NOT for calculations.
///
/// Reference: financial-engine-spec.md §2
/// "intl — chỉ dùng cho format/display, KHÔNG dùng cho tính toán"
class AppFormatters {
  AppFormatters._();

  static final _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final _percentFormat = NumberFormat.decimalPercentPattern(
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _shortMonthFormat = DateFormat('MMM yyyy');

  /// Format cents as currency string.
  ///
  /// Example: 123456 → "$1,234.56"
  static String formatCents(int cents) {
    return _currencyFormat.format(cents / 100);
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
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format month and year.
  ///
  /// Example: DateTime(2028, 7) → "July 2028"
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format short month and year.
  ///
  /// Example: DateTime(2028, 7) → "Jul 2028"
  static String formatShortMonthYear(DateTime date) {
    return _shortMonthFormat.format(date);
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
}
