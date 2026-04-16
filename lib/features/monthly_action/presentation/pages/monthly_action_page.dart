import 'package:flutter/material.dart';

/// Monthly action page — "This Month" tab.
///
/// Feature 1.5: Monthly Action View
/// "Tháng này bạn cần trả:" — primary home screen.
class MonthlyActionPage extends StatelessWidget {
  const MonthlyActionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement checklist with BlocBuilder
    return const Scaffold(
      body: Center(child: Text('This Month')),
    );
  }
}
