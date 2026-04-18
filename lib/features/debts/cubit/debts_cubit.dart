import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/debt.dart';
import '../../../domain/enums/debt_status.dart';
import '../../../domain/repositories/debt_repository.dart';
import 'debts_state.dart';

/// Cubit managing the list of debts.
///
/// Feature 1.1: Nhập & quản lý khoản nợ
class DebtsCubit extends Cubit<DebtsState> {
  DebtsCubit({required DebtRepository debtRepository})
      : _debtRepository = debtRepository,
        super(const DebtsState());

  final DebtRepository _debtRepository;
  StreamSubscription<List<Debt>>? _debtsSubscription;
  int _feedbackSequence = 0;

  /// Start listening to live debt updates.
  Future<void> start() async {
    await _debtsSubscription?.cancel();
    emit(
      state.copyWith(
        isLoading: true,
        clearInlineError: true,
      ),
    );
    _debtsSubscription = _debtRepository.watchAllDebts().listen(
      (debts) {
        emit(
          state.copyWith(
            isLoading: false,
            debts: debts,
            clearInlineError: true,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            isLoading: false,
            inlineError: _humanizeError(error),
          ),
        );
      },
    );
  }

  /// Add a new debt.
  Future<void> addDebt(Debt debt) async {
    try {
      await _debtRepository.addDebt(debt);
      _emitFeedback('Đã thêm khoản nợ "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  /// Update an existing debt.
  ///
  /// Per feature spec: "Edit bất kỳ field nào, bất kỳ lúc nào — plan tự recast"
  Future<void> updateDebt(Debt debt) async {
    try {
      await _debtRepository.updateDebt(debt);
      _emitFeedback('Đã cập nhật khoản nợ "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  Future<void> archiveDebt(Debt debt) async {
    try {
      await _debtRepository.updateDebt(
        debt.copyWith(
          status: DebtStatus.archived,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      _emitFeedback('Đã lưu trữ khoản nợ "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  Future<void> unarchiveDebt(Debt debt) async {
    try {
      await _debtRepository.updateDebt(
        debt.copyWith(
          status: DebtStatus.paidOff,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      _emitFeedback('Đã bỏ lưu trữ khoản nợ "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  /// Delete a debt.
  Future<void> deleteDebt(Debt debt) async {
    try {
      await _debtRepository.deleteDebt(debt.id);
      _emitFeedback('Đã xóa khoản nợ "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  Future<void> restoreDebt(Debt debt) async {
    try {
      await _debtRepository.restoreDebt(debt.id);
      _emitFeedback('Đã khôi phục khoản nợ "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  void setFilter(DebtsFilter filter) {
    if (filter == state.filter) return;
    emit(
      state.copyWith(
        filter: filter,
        clearInlineError: true,
      ),
    );
  }

  void clearActionFeedback() {
    if (state.lastActionFeedback == null) return;
    emit(state.copyWith(clearLastActionFeedback: true));
  }

  void clearInlineError() {
    if (state.inlineError == null) return;
    emit(state.copyWith(clearInlineError: true));
  }

  void _emitFeedback(String message) {
    emit(
      state.copyWith(
        lastActionFeedback: DebtActionFeedback(
          message: message,
          sequence: ++_feedbackSequence,
        ),
      ),
    );
  }

  void _emitInlineError(Object error) {
    emit(
      state.copyWith(
        inlineError: _humanizeError(error),
      ),
    );
  }

  String _humanizeError(Object error) {
    if (error is ArgumentError && error.message is String) {
      return error.message as String;
    }
    return error.toString();
  }

  @override
  Future<void> close() async {
    await _debtsSubscription?.cancel();
    return super.close();
  }
}
