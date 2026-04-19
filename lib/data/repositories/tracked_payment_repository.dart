import '../../core/services/plan_recast_service.dart';
import '../local/stores/sync_state_store.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payment_repository_impl.dart';

/// Decorates payment writes with sync bookkeeping and plan recasts.
class TrackedPaymentRepository implements PaymentRepository {
  TrackedPaymentRepository({
    required PaymentRepositoryImpl base,
    required SyncStateStore syncStateStore,
    required PlanRecastService planRecastService,
  }) : _base = base,
       _syncStateStore = syncStateStore,
       _planRecastService = planRecastService;

  final PaymentRepositoryImpl _base;
  final SyncStateStore _syncStateStore;
  final PlanRecastService _planRecastService;

  @override
  Future<Payment> addPayment(Payment payment) async {
    final added = await _base.addPayment(payment);
    await _syncStateStore.markDirty('payments');
    await _planRecastService.recast(scenarioId: payment.scenarioId);
    return added;
  }

  @override
  Future<void> deletePayment(String id) async {
    final current = await _base.getPaymentById(id);
    await _base.deletePayment(id);
    await _syncStateStore.markDirty('payments');
    await _planRecastService.recast(
      scenarioId: current?.scenarioId ?? 'main',
    );
  }

  @override
  Future<List<Payment>> getAllPayments({
    String scenarioId = 'main',
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _base.getAllPayments(
      scenarioId: scenarioId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  Future<Payment?> getPaymentById(String id) {
    return _base.getPaymentById(id);
  }

  @override
  Future<List<Payment>> getPaymentsForDebt(String debtId) {
    return _base.getPaymentsForDebt(debtId);
  }

  @override
  Future<List<Payment>> getPaymentsForMonth(
    String yearMonth, {
    String scenarioId = 'main',
  }) {
    return _base.getPaymentsForMonth(yearMonth, scenarioId: scenarioId);
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    await _base.updatePayment(payment);
    await _syncStateStore.markDirty('payments');
    await _planRecastService.recast(scenarioId: payment.scenarioId);
  }

  @override
  Stream<List<Payment>> watchAllPayments({String scenarioId = 'main'}) {
    return _base.watchAllPayments(scenarioId: scenarioId);
  }

  @override
  Stream<List<Payment>> watchPaymentsForDebt(String debtId) {
    return _base.watchPaymentsForDebt(debtId);
  }
}
