import 'package:flutter/material.dart';

/// Debts list page — shows all debts with summary.
///
/// Feature 1.1: Nhập & quản lý khoản nợ
class DebtsListPage extends StatelessWidget {
  const DebtsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement debts list with BlocBuilder<DebtsCubit, DebtsState>
    return const Scaffold(
      body: Center(child: Text('Debts List')),
    );
  }
}
