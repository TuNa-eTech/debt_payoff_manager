/// Method used to calculate interest on a debt.
///
/// Reference: financial-engine-spec.md §3.1, §4.3
///
/// This is **mandatory** per spec — "hầu hết competitor app sai" because
/// they use a single interest method for all debt types.
enum InterestMethod {
  /// Simple monthly: balance × APR / 12.
  /// Used for: student loans, mortgages (standard).
  simpleMonthly('Simple Monthly'),

  /// Compound daily: balance × (APR / 365) compounded each day.
  /// Used for: credit cards (accurate), some car loans.
  compoundDaily('Compound Daily'),

  /// Compound monthly: standard amortization formula.
  /// Used for: fixed-payment installment loans.
  compoundMonthly('Compound Monthly');

  const InterestMethod(this.label);

  final String label;
}
