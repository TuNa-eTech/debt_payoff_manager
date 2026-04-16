import 'package:flutter/material.dart';

/// Widget displaying a single debt as a card in the list.
class DebtCard extends StatelessWidget {
  const DebtCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement debt card with balance, APR, progress
    return const Card(
      child: ListTile(title: Text('Debt Card')),
    );
  }
}
