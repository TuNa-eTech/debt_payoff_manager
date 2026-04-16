import 'package:flutter/material.dart';

/// Debt detail page with edit capability and payment history.
class DebtDetailPage extends StatelessWidget {
  const DebtDetailPage({super.key, required this.debtId});

  final String debtId;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement debt detail with edit + payment history
    return Scaffold(
      body: Center(child: Text('Debt Detail: $debtId')),
    );
  }
}
