/// Payment cadence.
///
/// Reference: financial-engine-spec.md §3.1
enum PaymentCadence {
  monthly('Monthly'),
  biweekly('Bi-weekly'),
  weekly('Weekly'),
  semimonthly('Semi-monthly');

  const PaymentCadence(this.label);

  final String label;
}
