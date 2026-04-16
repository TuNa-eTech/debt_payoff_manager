/// Minimum payment calculation method.
///
/// Reference: financial-engine-spec.md §3.1, §6.1
enum MinPaymentType {
  /// Fixed dollar amount.
  fixed('Fixed Amount'),

  /// Percentage of balance with a floor.
  percentOfBalance('% of Balance'),

  /// Interest + percentage of principal with a floor.
  interestPlusPercent('Interest + % Principal');

  const MinPaymentType(this.label);

  final String label;
}
