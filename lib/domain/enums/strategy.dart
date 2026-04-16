/// Payoff strategy selection.
///
/// Reference: financial-engine-spec.md §7
enum Strategy {
  /// Smallest balance first — psychological wins.
  snowball('Snowball'),

  /// Highest APR first — mathematically optimal.
  avalanche('Avalanche'),

  /// User-defined order.
  custom('Custom');

  const Strategy(this.label);

  final String label;
}
