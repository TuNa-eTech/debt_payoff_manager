/// Extensions on [DateTime] for financial date operations.
extension DateExtensions on DateTime {
  /// Get the number of days in this date's month.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Get year-month string in "YYYY-MM" format.
  ///
  /// Used for [MonthProjection.yearMonth] per spec §3.5.
  String get yearMonth =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  /// Check if this date is in the same month and year as [other].
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// Add [months] to this date, handling end-of-month overflow.
  ///
  /// Example: Jan 31 + 1 month = Feb 28 (not March 3).
  DateTime addMonths(int months) {
    final newYear = year + (month + months - 1) ~/ 12;
    final newMonth = (month + months - 1) % 12 + 1;
    final maxDay = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = day > maxDay ? maxDay : day;
    return DateTime(newYear, newMonth, newDay);
  }

  /// Calculate the number of days between this date and [other].
  int daysBetween(DateTime other) => other.difference(this).inDays.abs();

  /// Start of month (first day, midnight).
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// End of month (last day, midnight).
  DateTime get endOfMonth => DateTime(year, month + 1, 0);
}
