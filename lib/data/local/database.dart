// import 'package:drift/drift.dart'; // Uncomment after tables are defined

// TODO: Import generated part file after running build_runner
// part 'database.g.dart';

/// SQLite database setup using Drift.
///
/// Per financial-engine-spec.md §2 (Storage):
/// "SQLite: INTEGER cents — nhanh, exact, dễ sum"
/// "KHÔNG bao giờ lưu money dưới dạng REAL/DOUBLE."
///
/// Run `dart run build_runner build` to generate database code.
///
/// Tables are defined in separate files under `tables/`.
// @DriftDatabase(tables: [DebtsTable, PaymentsTable, PlansTable])
// class AppDatabase extends _$AppDatabase {
//   AppDatabase(QueryExecutor e) : super(e);
//
//   @override
//   int get schemaVersion => 1;
// }

/// Placeholder until build_runner generates the database.
/// Replace this with the @DriftDatabase annotated class above
/// after defining tables and running code generation.
class AppDatabase {
  // TODO: Replace with generated Drift database
}
