import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';

/// Concrete implementation of [DebtRepository] using Drift (SQLite).
///
/// TODO: Inject DebtDao after Drift code generation.
class DebtRepositoryImpl implements DebtRepository {
  // DebtRepositoryImpl({required DebtDao debtDao}) : _debtDao = debtDao;
  // final DebtDao _debtDao;

  @override
  Future<List<Debt>> getAllDebts({List<String>? statusFilter}) async {
    // TODO: Query via DebtDao, map to domain entities
    return [];
  }

  @override
  Future<Debt?> getDebtById(String id) async {
    // TODO: Implement
    return null;
  }

  @override
  Future<List<Debt>> getActiveDebts() async {
    return getAllDebts(statusFilter: ['active']);
  }

  @override
  Future<Debt> addDebt(Debt debt) async {
    // TODO: Map domain entity to table companion, insert via DAO
    return debt;
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    // TODO: Implement
  }

  @override
  Future<void> deleteDebt(String id) async {
    // TODO: Implement
  }

  @override
  Stream<List<Debt>> watchAllDebts() {
    // TODO: Return stream from DAO
    return const Stream.empty();
  }

  @override
  Stream<List<Debt>> watchActiveDebts() {
    // TODO: Implement
    return const Stream.empty();
  }
}
