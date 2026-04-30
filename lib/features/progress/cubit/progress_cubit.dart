import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/services/streak_service.dart';
import '../../../domain/enums/debt_status.dart';
import '../../../domain/repositories/debt_repository.dart';
import '../../../domain/repositories/milestone_repository.dart';
import '../../../domain/repositories/payment_repository.dart';
import '../../../domain/repositories/plan_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    required DebtRepository debtRepository,
    required PlanRepository planRepository,
    required PaymentRepository paymentRepository,
    required MilestoneRepository milestoneRepository,
    required StreakService streakService,
    SettingsRepository? settingsRepository,
  }) : _debtRepository = debtRepository,
       _planRepository = planRepository,
       _paymentRepository = paymentRepository,
       _milestoneRepository = milestoneRepository,
       _streakService = streakService,
       _settingsRepository = settingsRepository,
       super(const ProgressState());

  final DebtRepository _debtRepository;
  final PlanRepository _planRepository;
  final PaymentRepository _paymentRepository;
  final MilestoneRepository _milestoneRepository;
  final StreakService _streakService;
  final SettingsRepository? _settingsRepository;

  StreamSubscription<void>? _sub;

  void start() {
    final scenarioStream = _settingsRepository == null
        ? Stream<String>.value('main')
        : _settingsRepository
              .watchSettings()
              .map((settings) => settings.activeScenarioId)
              .distinct();
    _sub = scenarioStream
        .switchMap(
          (scenarioId) => CombineLatestStream.combine3(
            _debtRepository.watchAllDebts(scenarioId: scenarioId),
            _planRepository.watchCurrentPlan(scenarioId: scenarioId),
            _milestoneRepository.watchUnseenMilestones(scenarioId: scenarioId),
            (debts, plan, milestones) => scenarioId,
          ),
        )
        .listen((scenarioId) => _reload(scenarioId: scenarioId));
  }

  Future<void> _reload({String scenarioId = 'main'}) async {
    final debts = (await _debtRepository.getAllDebts(
      scenarioId: scenarioId,
    )).where((d) => d.status != DebtStatus.archived).toList();
    final plan = await _planRepository.getCurrentPlan(scenarioId: scenarioId);
    final payments = await _paymentRepository.getAllPayments(
      scenarioId: scenarioId,
    );
    final milestones = await _milestoneRepository.getUnseenMilestones(
      scenarioId: scenarioId,
    );

    final totalOriginal = debts.fold(0, (s, d) => s + d.originalPrincipal);
    final totalRemaining = debts.fold(0, (s, d) => s + d.currentBalance);
    final totalPaid = (totalOriginal - totalRemaining).clamp(0, totalOriginal);
    final interestSaved = plan?.totalInterestSaved ?? 0;
    final streak = _streakService.computeCurrentStreak(
      payments,
      DateTime.now(),
    );

    emit(
      ProgressState(
        isLoading: false,
        totalPaidCents: totalPaid,
        totalOriginalCents: totalOriginal,
        totalRemainingCents: totalRemaining,
        interestSavedCents: interestSaved,
        streak: streak,
        unseenMilestones: milestones,
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
