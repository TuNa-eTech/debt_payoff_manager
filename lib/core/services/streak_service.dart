import '../../domain/entities/payment.dart';
import '../../domain/enums/payment_type.dart';
import '../extensions/date_extensions.dart';

/// Computes payment streak — consecutive months with at least one completed
/// payment, walking backwards from [asOf].
class StreakService {
  const StreakService();

  /// Returns the number of consecutive months (ending at [asOf]) in which
  /// at least one [PaymentStatus.completed] payment was logged.
  ///
  /// Months with only planned/missed payments do not count.
  int computeCurrentStreak(List<Payment> allPayments, DateTime asOf) {
    final completedMonths = allPayments
        .where((p) => p.deletedAt == null && p.status == PaymentStatus.completed)
        .map((p) => p.date.yearMonth)
        .toSet();

    if (completedMonths.isEmpty) return 0;

    int streak = 0;
    var cursor = DateTime(asOf.year, asOf.month, 1);

    while (true) {
      if (!completedMonths.contains(cursor.yearMonth)) break;
      streak++;
      cursor = cursor.addMonths(-1);
    }

    return streak;
  }
}
