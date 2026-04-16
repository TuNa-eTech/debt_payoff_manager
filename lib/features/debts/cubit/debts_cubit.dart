import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/debt.dart';
import '../../../domain/repositories/debt_repository.dart';
import 'debts_state.dart';

/// Cubit managing the list of debts.
///
/// Feature 1.1: Nhập & quản lý khoản nợ
class DebtsCubit extends Cubit<DebtsState> {
  DebtsCubit({required DebtRepository debtRepository})
      : _debtRepository = debtRepository,
        super(const DebtsInitial());

  final DebtRepository _debtRepository;

  /// Load all debts from repository.
  Future<void> loadDebts() async {
    emit(const DebtsLoading());
    try {
      final debts = await _debtRepository.getAllDebts();
      emit(DebtsLoaded(debts: debts));
    } catch (e) {
      emit(DebtsError(message: e.toString()));
    }
  }

  /// Add a new debt.
  Future<void> addDebt(Debt debt) async {
    try {
      await _debtRepository.addDebt(debt);
      await loadDebts(); // Reload to reflect changes
    } catch (e) {
      emit(DebtsError(message: e.toString()));
    }
  }

  /// Update an existing debt.
  ///
  /// Per feature spec: "Edit bất kỳ field nào, bất kỳ lúc nào — plan tự recast"
  Future<void> updateDebt(Debt debt) async {
    try {
      await _debtRepository.updateDebt(debt);
      await loadDebts();
    } catch (e) {
      emit(DebtsError(message: e.toString()));
    }
  }

  /// Delete a debt.
  Future<void> deleteDebt(String id) async {
    try {
      await _debtRepository.deleteDebt(id);
      await loadDebts();
    } catch (e) {
      emit(DebtsError(message: e.toString()));
    }
  }
}
