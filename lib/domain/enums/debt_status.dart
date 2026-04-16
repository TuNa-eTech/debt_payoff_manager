/// Lifecycle status of a debt.
///
/// Reference: financial-engine-spec.md §3.1
enum DebtStatus {
  active('Active'),
  paidOff('Paid Off'),
  archived('Archived'),
  paused('Paused');

  const DebtStatus(this.label);

  final String label;
}
