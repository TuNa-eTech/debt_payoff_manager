/// Payment type classification.
///
/// Reference: data-schema.md §4
enum PaymentType {
  minimum('Minimum'),
  extra('Extra'),
  lumpSum('Lump Sum'),
  fee('Fee'),
  refund('Refund'),
  charge('Charge'); // balance increase on credit card

  const PaymentType(this.label);

  final String label;
}

/// Source of a payment.
///
/// Reference: data-schema.md §4
enum PaymentSource {
  scheduled('Scheduled'),
  manual('Manual'),
  windfall('Windfall'),
  checkOff('Check Off'),
  import_('Import'); // imported payment records

  const PaymentSource(this.label);

  final String label;
}

/// Status of a payment.
///
/// Reference: financial-engine-spec.md §3.2
enum PaymentStatus {
  planned('Planned'),
  completed('Completed'),
  missed('Missed');

  const PaymentStatus(this.label);

  final String label;
}
