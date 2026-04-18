import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database.dart';

/// Provides database instances for production and testing.
///
/// Production: Uses `DriftDatabase` with file-based SQLite.
/// Tests: Uses in-memory database via [openTestDatabase].
class DatabaseProvider {
  DatabaseProvider._();

  /// Open the production database with file-based SQLite.
  ///
  /// The database file is stored in the app's documents directory
  /// as `debt_payoff.sqlite`.
  static AppDatabase openDatabase() {
    return AppDatabase(
      driftDatabase(name: 'debt_payoff'),
    );
  }

  /// Open an in-memory database for testing.
  ///
  /// Each call creates a fresh, isolated database instance.
  /// Per ADR-015: Drift NativeDatabase.memory() for unit tests.
  static AppDatabase openTestDatabase() {
    return AppDatabase(
      NativeDatabase.memory(),
    );
  }
}
