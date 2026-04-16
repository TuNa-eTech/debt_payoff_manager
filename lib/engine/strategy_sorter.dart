import '../domain/entities/debt.dart';
import '../domain/enums/strategy.dart';

/// Sort debts by payoff strategy.
///
/// Reference: financial-engine-spec.md §7
class StrategySorter {
  StrategySorter._();

  /// Sort debts according to the selected strategy.
  ///
  /// Returns a new sorted list (does not modify input).
  static List<Debt> sort(List<Debt> debts, Strategy strategy,
      [List<String>? customOrder]) {
    final sorted = List<Debt>.from(debts);

    switch (strategy) {
      case Strategy.snowball:
        // §7.1: Sort by currentBalance ASC
        // Tiebreak: APR cao hơn trước
        sorted.sort((a, b) {
          final balanceCompare =
              a.currentBalance.compareTo(b.currentBalance);
          if (balanceCompare != 0) return balanceCompare;
          return b.apr.compareTo(a.apr); // higher APR first on tie
        });

      case Strategy.avalanche:
        // §7.2: Sort by APR DESC
        // Tiebreak: balance thấp hơn trước
        sorted.sort((a, b) {
          final aprCompare = b.apr.compareTo(a.apr);
          if (aprCompare != 0) return aprCompare;
          return a.currentBalance.compareTo(b.currentBalance);
        });

      case Strategy.custom:
        // §7.3: User-defined order
        if (customOrder != null && customOrder.isNotEmpty) {
          sorted.sort((a, b) {
            final indexA = customOrder.indexOf(a.id);
            final indexB = customOrder.indexOf(b.id);
            // Debts not in customOrder go to the end
            final effectiveA = indexA == -1 ? customOrder.length : indexA;
            final effectiveB = indexB == -1 ? customOrder.length : indexB;
            return effectiveA.compareTo(effectiveB);
          });
        }
    }

    return sorted;
  }
}
