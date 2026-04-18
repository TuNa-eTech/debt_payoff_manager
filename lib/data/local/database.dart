import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

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
@DriftDatabase(
  tables: [
    DebtsTable,
    PaymentsTable,
    PlansTable,
    UserSettingsTable,
    MilestonesTable,
    InterestRateHistoryTable,
    SyncStateTable,
    TimelineCacheTable,
  ],
)
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
      await _repairActivePlanSingletons();
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_plans_scenario '
        'ON plans (scenario_id) WHERE deleted_at IS NULL',
      );

      await _ensureSingletonSettingsSeeded();
      await _ensureMainPlanSeeded();
    },
  );

  Future<void> _repairActivePlanSingletons() async {
    final duplicateScenarios = await customSelect(
      'SELECT scenario_id '
      'FROM plans '
      'WHERE deleted_at IS NULL '
      'GROUP BY scenario_id '
      'HAVING COUNT(*) > 1',
    ).get();

    for (final row in duplicateScenarios) {
      final scenarioId = row.read<String>('scenario_id');
      final activePlans = await customSelect(
        'SELECT id '
        'FROM plans '
        'WHERE scenario_id = ? AND deleted_at IS NULL '
        'ORDER BY updated_at DESC, created_at DESC, id ASC',
        variables: [Variable.withString(scenarioId)],
      ).get();

      if (activePlans.length <= 1) continue;

      final now = DateTime.now().toUtc();
      for (final stale in activePlans.skip(1)) {
        await customStatement(
          'UPDATE plans '
          'SET deleted_at = ?, updated_at = ? '
          'WHERE id = ?',
          [
            now.toIso8601String(),
            now.toIso8601String(),
            stale.read<String>('id'),
          ],
        );
      }
    }
  }

  Future<void> _ensureSingletonSettingsSeeded() async {
    final existingSettings = await customSelect(
      'SELECT 1 FROM user_settings WHERE id = ? LIMIT 1',
      variables: [Variable.withString('singleton')],
    ).getSingleOrNull();

    if (existingSettings != null) return;

    final now = DateTime.now().toUtc();
    await into(
      userSettingsTable,
    ).insert(UserSettingsTableCompanion.insert(createdAt: now, updatedAt: now));
  }

  Future<void> _ensureMainPlanSeeded() async {
    final existingMainPlan =
        await (select(plansTable)
              ..where((p) => p.scenarioId.equals('main'))
              ..where((p) => p.deletedAt.isNull()))
            .getSingleOrNull();

    if (existingMainPlan != null) return;

    final now = DateTime.now().toUtc();
    await into(plansTable).insert(
      PlansTableCompanion.insert(
        strategy: Strategy.snowball,
        extraPaymentCadence: PaymentCadence.monthly,
        lastRecastAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
