/// Milestone types for progress tracking.
///
/// Reference: data-schema.md §8
enum MilestoneType {
  debtPaidOff('Debt Paid Off'),
  percentComplete25('25% Complete'),
  percentComplete50('50% Complete'),
  percentComplete75('75% Complete'),
  allDebtFree('All Debt Free!'),
  streakMonths3('3-Month Streak'),
  streakMonths6('6-Month Streak'),
  streakMonths12('12-Month Streak'),
  interestSaved1000('Saved \$1,000 Interest'),
  interestSaved5000('Saved \$5,000 Interest'),
  firstPayment('First Payment');

  const MilestoneType(this.label);

  final String label;
}
