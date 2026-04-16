/// Types of debt supported by the app.
///
/// Reference: financial-engine-spec.md §3.1
enum DebtType {
  creditCard('Credit Card'),
  studentLoan('Student Loan'),
  carLoan('Car Loan'),
  mortgage('Mortgage'),
  personal('Personal Loan'),
  medical('Medical Debt'),
  other('Other');

  const DebtType(this.label);

  final String label;
}
