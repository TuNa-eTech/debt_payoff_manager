import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/debt.dart';
import '../../../domain/enums/debt_status.dart';
import '../../../domain/repositories/debt_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'debts_state.dart';

/// Cubit managing the list of debts.
///
/// Feature 1.1: Nhập & quản lý khoản nợ
class DebtsCubit extends Cubit<DebtsState> {
  DebtsCubit({
    required DebtRepository debtRepository,
    SettingsRepository? settingsRepository,
  }) : _debtRepository = debtRepository,
       _settingsRepository = settingsRepository,
       super(const DebtsState());

  final DebtRepository _debtRepository;
  final SettingsRepository? _settingsRepository;
  StreamSubscription<List<Debt>>? _debtsSubscription;
  int _feedbackSequence = 0;

  /// Start listening to live debt updates.
  Future<void> start() async {
    await _debtsSubscription?.cancel();
    emit(state.copyWith(isLoading: true, clearInlineError: true));
    final debtStream = _settingsRepository == null
        ? _debtRepository.watchAllDebts()
        : _settingsRepository
              .watchSettings()
              .map((settings) => settings.activeScenarioId)
              .distinct()
              .switchMap(
                (scenarioId) =>
                    _debtRepository.watchAllDebts(scenarioId: scenarioId),
              );
    _debtsSubscription = debtStream.listen(
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
          state.copyWith(isLoading: false, inlineError: _humanizeError(error)),
        );
      },
    );
  }

  /// Add a new debt.
  Future<void> addDebt(Debt debt) async {
    try {
      await _debtRepository.addDebt(debt);
      _emitFeedback('Added debt "${debt.name}".');
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
      _emitFeedback('Updated debt "${debt.name}".');
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
      _emitFeedback('Archived debt "${debt.name}".');
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
      _emitFeedback('Unarchived debt "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  /// Pause a debt with a resume date.
  Future<void> pauseDebt(Debt debt, DateTime pausedUntil) async {
    try {
      await _debtRepository.updateDebt(
        debt.copyWith(
          status: DebtStatus.paused,
          pausedUntil: pausedUntil,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      _emitFeedback('Paused debt "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  /// Resume a paused debt.
  Future<void> resumeDebt(Debt debt) async {
    try {
      await _debtRepository.updateDebt(
        debt.copyWith(
          status: DebtStatus.active,
          pausedUntil: null,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      _emitFeedback('Resumed debt "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  /// Delete a debt.
  Future<void> deleteDebt(Debt debt) async {
    try {
      await _debtRepository.deleteDebt(debt.id);
      _emitFeedback('Deleted debt "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  Future<void> restoreDebt(Debt debt) async {
    try {
      await _debtRepository.restoreDebt(debt.id);
      _emitFeedback('Restored debt "${debt.name}".');
    } catch (error) {
      _emitInlineError(error);
    }
  }

  void setFilter(DebtsFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter, clearInlineError: true));
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
    emit(state.copyWith(inlineError: _humanizeError(error)));
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
