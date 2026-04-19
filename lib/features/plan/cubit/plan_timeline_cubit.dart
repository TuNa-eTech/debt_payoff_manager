import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/services/plan_recast_service.dart';
import '../../../../data/local/stores/timeline_cache_store.dart';
import '../../../../domain/entities/timeline_projection.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../domain/repositories/plan_repository.dart';
import 'plan_timeline_state.dart';

class PlanTimelineCubit extends Cubit<PlanTimelineState> {
  PlanTimelineCubit({
    required DebtRepository debtRepository,
    required PlanRepository planRepository,
    required TimelineCacheStore timelineCacheStore,
    required PlanRecastService planRecastService,
  }) : _debtRepository = debtRepository,
       _planRepository = planRepository,
       _timelineCacheStore = timelineCacheStore,
       _planRecastService = planRecastService,
       super(const PlanTimelineState());

  final DebtRepository _debtRepository;
  final PlanRepository _planRepository;
  final TimelineCacheStore _timelineCacheStore;
  final PlanRecastService _planRecastService;
  StreamSubscription<List<Object?>>? _subscription;

  Future<void> start() async {
    await _subscription?.cancel();
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    _subscription = CombineLatestStream.list<Object?>([
      _debtRepository.watchAllDebts(),
      _planRepository.watchCurrentPlan(),
    ]).listen(
      (_) {
        unawaited(load());
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          ),
        );
      },
    );
    await load();
  }

  Future<void> load() async {
    try {
      final debts = await _debtRepository.getAllDebts();
      final trackedDebts = debts
          .where((debt) => debt.status != DebtStatus.archived)
          .toList(growable: false);
      var plan = await _planRepository.getCurrentPlan();

      if (plan == null) {
        emit(
          state.copyWith(
            isLoading: false,
            debts: trackedDebts,
            plan: null,
            projection: null,
            delta: null,
            clearErrorMessage: true,
          ),
        );
        return;
      }

      TimelineProjection? projection = await _timelineCacheStore.getProjection(
        plan.id,
      );
      if (trackedDebts.isNotEmpty &&
          trackedDebts.any((debt) => debt.currentBalance > 0) &&
          (projection == null || plan.projectedDebtFreeDate == null)) {
        final recast = await _planRecastService.recast();
        plan = recast?.plan ?? plan;
        projection = recast?.projection ??
            await _timelineCacheStore.getProjection(plan.id);
      }

      emit(
        state.copyWith(
          isLoading: false,
          debts: trackedDebts,
          plan: plan,
          projection: projection,
          delta: _planRecastService.lastDeltaFor(plan.scenarioId),
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
