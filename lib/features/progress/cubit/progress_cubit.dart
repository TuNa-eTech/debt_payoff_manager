import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/services/streak_service.dart';
import '../../../domain/enums/debt_status.dart';
import '../../../domain/repositories/debt_repository.dart';
import '../../../domain/repositories/milestone_repository.dart';
import '../../../domain/repositories/payment_repository.dart';
import '../../../domain/repositories/plan_repository.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    required DebtRepository debtRepository,
    required PlanRepository planRepository,
    required PaymentRepository paymentRepository,
    required MilestoneRepository milestoneRepository,
    required StreakService streakService,
  })  : _debtRepository = debtRepository,
        _planRepository = planRepository,
        _paymentRepository = paymentRepository,
        _milestoneRepository = milestoneRepository,
        _streakService = streakService,
        super(const ProgressState());

  final DebtRepository _debtRepository;
  final PlanRepository _planRepository;
  final PaymentRepository _paymentRepository;
  final MilestoneRepository _milestoneRepository;
  final StreakService _streakService;

  StreamSubscription<void>? _sub;

  void start() {
    _sub = CombineLatestStream.combine3(
      _debtRepository.watchAllDebts(),
      _planRepository.watchCurrentPlan(),
      _milestoneRepository.watchUnseenMilestones(),
      (debts, plan, milestones) => (debts, plan, milestones),
    ).listen((_) => _reload());
  }

  Future<void> _reload() async {
    final debts = (await _debtRepository.getAllDebts())
        .where((d) => d.status != DebtStatus.archived)
        .toList();
    final plan = await _planRepository.getCurrentPlan();
    final payments = await _paymentRepository.getAllPayments();
    final milestones = await _milestoneRepository.getUnseenMilestones();

    final totalOriginal = debts.fold(0, (s, d) => s + d.originalPrincipal);
    final totalRemaining = debts.fold(0, (s, d) => s + d.currentBalance);
    final totalPaid = (totalOriginal - totalRemaining).clamp(0, totalOriginal);
    final interestSaved = plan?.totalInterestSaved ?? 0;
    final streak = _streakService.computeCurrentStreak(payments, DateTime.now());

    emit(ProgressState(
      isLoading: false,
      totalPaidCents: totalPaid,
      totalOriginalCents: totalOriginal,
      totalRemainingCents: totalRemaining,
      interestSavedCents: interestSaved,
      streak: streak,
      unseenMilestones: milestones,
    ));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
