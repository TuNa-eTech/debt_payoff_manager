import 'package:flutter_bloc/flutter_bloc.dart';

import 'monthly_action_state.dart';

/// Cubit managing the monthly action view.
///
/// Feature 1.5: Monthly Action View
///
/// "Tháng này bạn cần trả:" — the primary engagement screen.
class MonthlyActionCubit extends Cubit<MonthlyActionState> {
  MonthlyActionCubit() : super(const MonthlyActionInitial());

  /// Load this month's payment actions.
  Future<void> loadMonthlyActions() async {
    emit(const MonthlyActionLoading());
    try {
      // TODO: Compute from active debts + plan for current month.
      // Each active debt gets an item with:
      //   - minimum + extra allocation from strategy engine
      //   - due date
      //   - completed status from payment logs
    } catch (e) {
      // Handle error
    }
  }

  /// Mark a payment as completed (check off).
  ///
  /// Per feature spec: "Check off từng payment khi đã thực hiện →
  /// tự log vào payment history"
  Future<void> checkOffPayment(String debtId) async {
    // TODO: Log payment + update state
  }
}
