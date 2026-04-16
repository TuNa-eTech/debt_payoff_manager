/// Debt DAO — Data Access Object for debts table.
///
/// TODO: Implement after running Drift code generation.
/// Will extend DatabaseAccessor<AppDatabase>.
///
/// Example methods:
/// ```dart
/// @DriftAccessor(tables: [DebtsTable])
/// class DebtDao extends DatabaseAccessor<AppDatabase> with _$DebtDaoMixin {
///   DebtDao(AppDatabase db) : super(db);
///
///   Future<List<DebtsTableData>> getAllDebts() => select(debtsTable).get();
///   Stream<List<DebtsTableData>> watchAllDebts() => select(debtsTable).watch();
///   Future<void> insertDebt(DebtsTableCompanion debt) => into(debtsTable).insert(debt);
///   Future<void> updateDebt(DebtsTableCompanion debt) => update(debtsTable).write(debt);
///   Future<void> deleteDebtById(String id) =>
///       (delete(debtsTable)..where((t) => t.id.equals(id))).go();
/// }
/// ```
class DebtDao {
  // TODO: Implement with Drift codegen
}
