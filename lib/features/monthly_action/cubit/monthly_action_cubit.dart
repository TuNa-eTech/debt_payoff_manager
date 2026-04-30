import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/models/monthly_action_models.dart';
import '../../../../core/services/monthly_action_service.dart';
import '../../../../core/services/payment_logging_service.dart';
import '../../../../domain/enums/payment_type.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../domain/repositories/payment_repository.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../../domain/repositories/settings_repository.dart';
import 'monthly_action_state.dart';

/// Cubit managing the monthly action home view.
class MonthlyActionCubit extends Cubit<MonthlyActionState> {
  MonthlyActionCubit({
    required MonthlyActionService monthlyActionService,
    required PaymentLoggingService paymentLoggingService,
    required DebtRepository debtRepository,
    required PaymentRepository paymentRepository,
    required PlanRepository planRepository,
    SettingsRepository? settingsRepository,
  }) : _monthlyActionService = monthlyActionService,
       _paymentLoggingService = paymentLoggingService,
       _debtRepository = debtRepository,
       _paymentRepository = paymentRepository,
       _planRepository = planRepository,
       _settingsRepository = settingsRepository,
       super(const MonthlyActionState());

  final MonthlyActionService _monthlyActionService;
  final PaymentLoggingService _paymentLoggingService;
  final DebtRepository _debtRepository;
  final PaymentRepository _paymentRepository;
  final PlanRepository _planRepository;
  final SettingsRepository? _settingsRepository;
  StreamSubscription<Object?>? _subscription;
  String _activeScenarioId = 'main';

  Future<void> start() async {
    await _subscription?.cancel();
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    final settingsRepository = _settingsRepository;
    final initialScenarioId = settingsRepository == null
        ? 'main'
        : (await settingsRepository.getSettings()).activeScenarioId;
    final scenarioStream = settingsRepository == null
        ? Stream<String>.value('main')
        : settingsRepository
              .watchSettings()
              .map((settings) => settings.activeScenarioId)
              .distinct();
    _subscription = scenarioStream
        .switchMap(
          (scenarioId) => CombineLatestStream.list<Object?>([
            _debtRepository.watchAllDebts(scenarioId: scenarioId),
            _paymentRepository.watchAllPayments(scenarioId: scenarioId),
            _planRepository.watchCurrentPlan(scenarioId: scenarioId),
          ]).map((_) => scenarioId),
        )
        .listen(
          (scenarioId) {
            unawaited(loadMonthlyActions(scenarioId: scenarioId));
          },
          onError: (Object error, StackTrace stackTrace) {
            emit(
              state.copyWith(isLoading: false, errorMessage: error.toString()),
            );
          },
        );
    await loadMonthlyActions(scenarioId: initialScenarioId);
  }

  Future<void> loadMonthlyActions({
    Set<String>? submittingIds,
    String? scenarioId,
  }) async {
    try {
      final activeScenarioId = scenarioId ?? _activeScenarioId;
      _activeScenarioId = activeScenarioId;
      final snapshot = await _monthlyActionService.load(
        referenceDate: state.referenceDate,
        scenarioId: activeScenarioId,
      );
      emit(
        state.copyWith(
          isLoading: false,
          referenceDate: snapshot.referenceDate,
          plan: snapshot.plan,
          delta: snapshot.delta,
          sections: snapshot.sections,
          summary: snapshot.summary,
          submittingIds: submittingIds ?? state.submittingIds,
          hasTrackedDebts: snapshot.hasTrackedDebts,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          submittingIds: submittingIds ?? state.submittingIds,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<bool> checkOffPayment(MonthlyActionItem item) async {
    final nextSubmitting = {...state.submittingIds, item.id};
    emit(
      state.copyWith(submittingIds: nextSubmitting, clearErrorMessage: true),
    );

    try {
      await _paymentLoggingService.logPayment(
        debtId: item.debtId,
        amountCents: item.amountCents,
        type: item.paymentType,
        source: PaymentSource.checkOff,
        date: state.referenceDate,
        note: 'Checked off from Monthly Action View',
      );
      await loadMonthlyActions(submittingIds: nextSubmitting);
    } catch (error) {
      emit(
        state.copyWith(
          submittingIds: {...nextSubmitting}..remove(item.id),
          errorMessage: error.toString(),
        ),
      );
      return false;
    }

    emit(
      state.copyWith(submittingIds: {...state.submittingIds}..remove(item.id)),
    );
    return true;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
