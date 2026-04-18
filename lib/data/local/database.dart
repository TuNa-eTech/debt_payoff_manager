import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/enums/debt_status.dart';
import '../../domain/enums/debt_type.dart';
import '../../domain/enums/interest_method.dart';
import '../../domain/enums/milestone_type.dart';
import '../../domain/enums/min_payment_type.dart';
import '../../domain/enums/payment_cadence.dart';
import '../../domain/enums/payment_type.dart';
import '../../domain/enums/strategy.dart';
import 'converters/datetime_converters.dart';
import 'converters/decimal_converter.dart';
import 'converters/enum_converters.dart';
import 'tables/debts_table.dart';
import 'tables/interest_rate_history_table.dart';
import 'tables/milestones_table.dart';
import 'tables/payments_table.dart';
import 'tables/plans_table.dart';
import 'tables/sync_state_table.dart';
import 'tables/timeline_cache_table.dart';
import 'tables/user_settings_table.dart';

part 'database.g.dart';

/// SQLite database setup using Drift.
///
/// Per data-schema.md — 8 tables, schema version 1.
/// Per ADR-002: Drift as local database.
/// Per ADR-004: INTEGER cents for money, never REAL/DOUBLE.
///
/// Run `dart run build_runner build` to generate database code.
@DriftDatabase(tables: [
  DebtsTable,
  PaymentsTable,
  PlansTable,
  UserSettingsTable,
  MilestonesTable,
  InterestRateHistoryTable,
  SyncStateTable,
  TimelineCacheTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations here
        },
        beforeOpen: (details) async {
          // Enable foreign keys
          await customStatement('PRAGMA foreign_keys = ON');

          if (details.wasCreated) {
            // Seed initial UserSettings singleton
            final now = DateTime.now().toUtc();
            await into(userSettingsTable).insert(
              UserSettingsTableCompanion.insert(
                createdAt: now,
                updatedAt: now,
              ),
            );
          }
        },
      );
}
