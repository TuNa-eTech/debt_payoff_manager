import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/models/data_export_artifact.dart';
import 'package:debt_payoff_manager/core/services/data_management_service.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/payment_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/plan_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/milestone_type.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';

import '../../data/repositories/repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepository;
  late PaymentRepositoryImpl paymentRepository;
  late PlanRepositoryImpl planRepository;
  late SettingsRepositoryImpl settingsRepository;
  late Directory tempDirectory;
  late DataManagementService service;

  final exportInstant = DateTime.utc(2026, 4, 19, 5, 6, 7, 89);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    debtRepository = DebtRepositoryImpl(db: db);
    paymentRepository = PaymentRepositoryImpl(db: db);
    planRepository = PlanRepositoryImpl(db: db);
    settingsRepository = SettingsRepositoryImpl(db: db);
    tempDirectory = await Directory.systemTemp.createTemp(
      'data-management-service-test',
    );
    service = DataManagementService(
      db: db,
      temporaryDirectoryProvider: () async => tempDirectory,
      nowProvider: () => exportInstant,
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
    await db.close();
  });

  test(
    'generateCsvExportBundle creates a deterministic multi-file ZIP and excludes soft-deleted rows',
    () async {
      await _seedRichDataset(
        db: db,
        debtRepository: debtRepository,
        paymentRepository: paymentRepository,
        planRepository: planRepository,
        settingsRepository: settingsRepository,
      );

      final artifact = await service.generateCsvExportBundle();
      final archive = await _readArchive(artifact.path);
      final manifest = _archiveJsonObject(archive, 'manifest.json');
      final counts = Map<String, dynamic>.from(
        manifest['table_row_counts'] as Map<dynamic, dynamic>,
      );

      expect(artifact.kind, DataExportArtifactKind.csvBundle);
      expect(artifact.mimeType, 'application/zip');
      expect(
        artifact.fileName,
        'debt_payoff_csv_export_20260419T050607089Z.zip',
      );
      expect(
        archive.files.map((file) => file.name),
        containsAll(<String>[
          'manifest.json',
          'debts.csv',
          'payments.csv',
          'plans.csv',
          'user_settings.csv',
          'milestones.csv',
          'interest_rate_history.csv',
        ]),
      );
      expect(manifest['bundle_type'], 'csv_export');
      expect(manifest['bundle_version'], 1);
      expect(manifest['schema_version'], db.schemaVersion);
      expect(manifest['exported_at_utc'], exportInstant.toIso8601String());
      expect(counts, <String, dynamic>{
        'debts': 3,
        'payments': 2,
        'plans': 2,
        'user_settings': 1,
        'milestones': 1,
        'interest_rate_history': 1,
      });

      final debtHeaders = _csvHeaders(_archiveText(archive, 'debts.csv'));
      final debtRows = _csvRows(_archiveText(archive, 'debts.csv'));
      expect(debtHeaders, <String>[
        'id',
        'scenario_id',
        'name',
        'type',
        'original_principal_cents',
        'current_balance_cents',
        'apr',
        'interest_method',
        'minimum_payment_cents',
        'minimum_payment_type',
        'minimum_payment_percent',
        'minimum_payment_floor_cents',
        'payment_cadence',
        'due_day_of_month',
        'first_due_date',
        'status',
        'paused_until',
        'priority',
        'exclude_from_strategy',
        'created_at',
        'updated_at',
        'paid_off_at',
        'deleted_at',
      ]);
      expect(debtRows.map((row) => row['id']), <String>[
        'debt-main-active',
        'debt-main-archived',
        'debt-whatif-paid',
      ]);
      expect(debtRows.map((row) => row['status']), <String>[
        'active',
        'archived',
        'paidOff',
      ]);
      expect(debtRows.map((row) => row['scenario_id']), <String>[
        'main',
        'main',
        'what-if',
      ]);
      expect(debtRows.any((row) => row['id'] == 'debt-deleted'), isFalse);

      final paymentRows = _csvRows(_archiveText(archive, 'payments.csv'));
      expect(paymentRows.map((row) => row['id']), <String>[
        'payment-main',
        'payment-whatif',
      ]);
      expect(paymentRows.map((row) => row['scenario_id']), <String>[
        'main',
        'what-if',
      ]);
      expect(paymentRows.any((row) => row['id'] == 'payment-deleted'), isFalse);

      final planRows = _csvRows(_archiveText(archive, 'plans.csv'));
      expect(planRows, hasLength(2));
      expect(planRows.map((row) => row['scenario_id']), <String>[
        'main',
        'what-if',
      ]);

      final settingsRows = _csvRows(_archiveText(archive, 'user_settings.csv'));
      expect(settingsRows, hasLength(1));
      expect(settingsRows.single['currency_code'], 'VND');
      expect(settingsRows.single['locale_code'], 'vi-VN');
    },
  );

  test(
    'generateLocalBackupBundle creates a JSON backup ZIP and excludes sync/cache tables',
    () async {
      await _seedRichDataset(
        db: db,
        debtRepository: debtRepository,
        paymentRepository: paymentRepository,
        planRepository: planRepository,
        settingsRepository: settingsRepository,
      );

      final artifact = await service.generateLocalBackupBundle();
      final archive = await _readArchive(artifact.path);
      final manifest = _archiveJsonObject(archive, 'manifest.json');
      final debtRows = _archiveJsonArray(archive, 'debts.json');
      final planRows = _archiveJsonArray(archive, 'plans.json');
      final interestRows = _archiveJsonArray(
        archive,
        'interest_rate_history.json',
      );

      expect(artifact.kind, DataExportArtifactKind.localBackup);
      expect(artifact.mimeType, 'application/zip');
      expect(artifact.fileName, 'debt_payoff_backup_20260419T050607089Z.zip');
      expect(
        archive.files.map((file) => file.name),
        isNot(containsAll(<String>['sync_state.json', 'timeline_cache.json'])),
      );
      expect(manifest['bundle_type'], 'local_backup');
      expect(
        Map<String, dynamic>.from(
          manifest['table_row_counts'] as Map<dynamic, dynamic>,
        ),
        <String, dynamic>{
          'debts': 3,
          'payments': 2,
          'plans': 2,
          'user_settings': 1,
          'milestones': 1,
          'interest_rate_history': 1,
        },
      );
      expect(debtRows.map((row) => row['id']), <String>[
        'debt-main-active',
        'debt-main-archived',
        'debt-whatif-paid',
      ]);
      expect(debtRows.any((row) => row['id'] == 'debt-deleted'), isFalse);
      expect(planRows.map((row) => row['scenario_id']), <String>[
        'main',
        'what-if',
      ]);
      expect(interestRows.single['apr'], '0.2499');
      expect(interestRows.single['effective_from'], '2026-01-01');
    },
  );

  test(
    'inspectLocalBackupBundle returns preview metadata and table counts',
    () async {
      await _seedRichDataset(
        db: db,
        debtRepository: debtRepository,
        paymentRepository: paymentRepository,
        planRepository: planRepository,
        settingsRepository: settingsRepository,
      );

      final artifact = await service.generateLocalBackupBundle();
      final preview = await service.inspectLocalBackupBundle(
        filePath: artifact.path,
        fileName: artifact.fileName,
      );

      expect(preview.path, artifact.path);
      expect(preview.fileName, artifact.fileName);
      expect(preview.bundleVersion, 1);
      expect(preview.schemaVersion, db.schemaVersion);
      expect(preview.exportedAtUtc, exportInstant);
      expect(preview.totalRows, 10);
      expect(preview.tableRowCounts, const <String, int>{
        'debts': 3,
        'payments': 2,
        'plans': 2,
        'user_settings': 1,
        'milestones': 1,
        'interest_rate_history': 1,
      });
    },
  );

  test(
    'fresh database still exports valid bundles with header-only CSV files and empty JSON arrays where appropriate',
    () async {
      final csvArtifact = await service.generateCsvExportBundle();
      final csvArchive = await _readArchive(csvArtifact.path);

      expect(_csvRows(_archiveText(csvArchive, 'debts.csv')), isEmpty);
      expect(_csvRows(_archiveText(csvArchive, 'payments.csv')), isEmpty);
      expect(_csvRows(_archiveText(csvArchive, 'milestones.csv')), isEmpty);
      expect(
        _csvRows(_archiveText(csvArchive, 'interest_rate_history.csv')),
        isEmpty,
      );
      expect(_csvRows(_archiveText(csvArchive, 'plans.csv')), hasLength(1));
      expect(
        _csvRows(_archiveText(csvArchive, 'user_settings.csv')),
        hasLength(1),
      );

      final backupArtifact = await service.generateLocalBackupBundle();
      final backupArchive = await _readArchive(backupArtifact.path);

      expect(_archiveJsonArray(backupArchive, 'debts.json'), isEmpty);
      expect(_archiveJsonArray(backupArchive, 'payments.json'), isEmpty);
      expect(_archiveJsonArray(backupArchive, 'milestones.json'), isEmpty);
      expect(
        _archiveJsonArray(backupArchive, 'interest_rate_history.json'),
        isEmpty,
      );
      expect(_archiveJsonArray(backupArchive, 'plans.json'), hasLength(1));
      expect(
        _archiveJsonArray(backupArchive, 'user_settings.json'),
        hasLength(1),
      );
    },
  );

  test(
    'restoreFromLocalBackup round-trips exported data and leaves cache tables empty',
    () async {
      await _seedRichDataset(
        db: db,
        debtRepository: debtRepository,
        paymentRepository: paymentRepository,
        planRepository: planRepository,
        settingsRepository: settingsRepository,
      );

      final artifact = await service.generateLocalBackupBundle();

      await service.clearAllData();
      expect(await _countRows(db, 'debts'), 0);
      expect(await _countRows(db, 'payments'), 0);
      expect(await _countRows(db, 'plans'), 1);
      expect(await _countRows(db, 'user_settings'), 1);

      await service.restoreFromLocalBackup(
        filePath: artifact.path,
        fileName: artifact.fileName,
      );

      final restoredSettings = await settingsRepository.getSettings();
      final restoredPlan = await planRepository.getCurrentPlan();
      final debtIds = await _readStringColumn(
        db,
        'SELECT id FROM debts ORDER BY scenario_id ASC, id ASC',
        'id',
      );
      final paymentIds = await _readStringColumn(
        db,
        'SELECT id FROM payments ORDER BY scenario_id ASC, id ASC',
        'id',
      );

      expect(restoredSettings.currencyCode, 'VND');
      expect(restoredSettings.localeCode, 'vi-VN');
      expect(restoredSettings.onboardingCompleted, isFalse);
      expect(restoredPlan, isNotNull);
      expect(restoredPlan!.strategy, Strategy.avalanche);
      expect(restoredPlan.extraMonthlyAmount, 7500);
      expect(await _countRows(db, 'debts'), 3);
      expect(await _countRows(db, 'payments'), 2);
      expect(await _countRows(db, 'plans'), 2);
      expect(await _countRows(db, 'user_settings'), 1);
      expect(await _countRows(db, 'milestones'), 1);
      expect(await _countRows(db, 'interest_rate_history'), 1);
      expect(await _countRows(db, 'sync_state'), 0);
      expect(await _countRows(db, 'timeline_cache'), 0);
      expect(debtIds, <String>[
        'debt-main-active',
        'debt-main-archived',
        'debt-whatif-paid',
      ]);
      expect(paymentIds, <String>['payment-main', 'payment-whatif']);
    },
  );

  test('inspectLocalBackupBundle rejects CSV export bundles', () async {
    final artifact = await service.generateCsvExportBundle();

    await expectLater(
      service.inspectLocalBackupBundle(
        filePath: artifact.path,
        fileName: artifact.fileName,
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'File ${artifact.fileName} không phải local backup bundle hợp lệ.',
        ),
      ),
    );
  });

  test(
    'clearAllData resets singleton settings and main plan while clearing debts, payments, milestones, rate history, sync state, and cache',
    () async {
      await _seedRichDataset(
        db: db,
        debtRepository: debtRepository,
        paymentRepository: paymentRepository,
        planRepository: planRepository,
        settingsRepository: settingsRepository,
      );

      final currentSettings = await settingsRepository.getSettings();
      await settingsRepository.updateSettings(
        currentSettings.copyWith(
          onboardingStep: 5,
          onboardingCompleted: true,
          onboardingCompletedAt: DateTime.utc(2026, 2, 1, 9),
          notifPaymentReminder: false,
          notifMonthlyLog: false,
        ),
      );

      final resetSettingsFuture = settingsRepository.watchSettings().firstWhere(
        (settings) =>
            settings.trustLevel == 0 &&
            settings.firebaseUid == null &&
            settings.onboardingStep == 0 &&
            !settings.onboardingCompleted,
      );
      final resetDebtsFuture = debtRepository.watchAllDebts().firstWhere(
        (debts) => debts.isEmpty,
      );

      await service.clearAllData();

      final resetSettings = await resetSettingsFuture;
      final resetDebts = await resetDebtsFuture;
      final resetPlan = await planRepository.getCurrentPlan();

      expect(resetDebts, isEmpty);
      expect(resetSettings.id, 'singleton');
      expect(resetSettings.trustLevel, 0);
      expect(resetSettings.firebaseUid, isNull);
      expect(resetSettings.onboardingStep, 0);
      expect(resetSettings.onboardingCompleted, isFalse);
      expect(resetSettings.onboardingCompletedAt, isNull);
      expect(resetPlan, isNotNull);
      expect(resetPlan!.scenarioId, 'main');
      expect(resetPlan.strategy, Strategy.snowball);
      expect(resetPlan.extraMonthlyAmount, 0);

      expect(await _countRows(db, 'debts'), 0);
      expect(await _countRows(db, 'payments'), 0);
      expect(await _countRows(db, 'milestones'), 0);
      expect(await _countRows(db, 'interest_rate_history'), 0);
      expect(await _countRows(db, 'sync_state'), 0);
      expect(await _countRows(db, 'timeline_cache'), 0);
      expect(await _countRows(db, 'user_settings'), 1);
      expect(await _countRows(db, 'plans'), 1);
    },
  );

  test(
    'clearAllData blocks factory reset when cloud backup is enabled',
    () async {
      await debtRepository.addDebt(
        makeRepoDebt(id: 'cloud-locked-debt', name: 'Cloud Locked'),
      );

      final settings = await settingsRepository.getSettings();
      await settingsRepository.updateSettings(
        settings.copyWith(trustLevel: 1, firebaseUid: 'firebase-user-1'),
      );

      await expectLater(
        service.clearAllData(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Hãy tắt Sao lưu đám mây trước khi xóa toàn bộ dữ liệu.',
          ),
        ),
      );

      expect(await debtRepository.getAllDebts(), hasLength(1));
      expect((await settingsRepository.getSettings()).trustLevel, 1);
    },
  );
}

Future<void> _seedRichDataset({
  required AppDatabase db,
  required DebtRepositoryImpl debtRepository,
  required PaymentRepositoryImpl paymentRepository,
  required PlanRepositoryImpl planRepository,
  required SettingsRepositoryImpl settingsRepository,
}) async {
  final baseTime = DateTime.utc(2026, 1, 1, 8);
  final mainActiveDebt = makeRepoDebt(
    id: 'debt-main-active',
    name: 'Visa Active',
  ).copyWith(createdAt: baseTime, updatedAt: baseTime);
  final mainArchivedDebt =
      makeRepoDebt(
        id: 'debt-main-archived',
        name: 'Store Card',
        status: DebtStatus.archived,
        currentBalance: 222000,
      ).copyWith(
        createdAt: baseTime.add(const Duration(days: 1)),
        updatedAt: baseTime.add(const Duration(days: 1)),
      );
  final whatIfPaidDebt =
      makeRepoDebt(
        id: 'debt-whatif-paid',
        scenarioId: 'what-if',
        name: 'Car Loan',
        currentBalance: 0,
        status: DebtStatus.paidOff,
      ).copyWith(
        createdAt: baseTime.add(const Duration(days: 2)),
        updatedAt: baseTime.add(const Duration(days: 2)),
        paidOffAt: DateTime.utc(2026, 1, 20, 12),
      );
  final deletedDebt = makeRepoDebt(id: 'debt-deleted', name: 'Deleted Debt')
      .copyWith(
        createdAt: baseTime.add(const Duration(days: 3)),
        updatedAt: baseTime.add(const Duration(days: 3)),
      );

  await debtRepository.addDebt(mainActiveDebt);
  await debtRepository.addDebt(mainArchivedDebt);
  await debtRepository.addDebt(whatIfPaidDebt);
  await debtRepository.addDebt(deletedDebt);

  await (db.update(
    db.debtsTable,
  )..where((row) => row.id.equals('debt-deleted'))).write(
    DebtsTableCompanion(
      deletedAt: Value(DateTime.utc(2026, 2, 1, 10)),
      updatedAt: Value(DateTime.utc(2026, 2, 1, 10)),
    ),
  );

  await paymentRepository.addPayment(
    makeRepoPayment(
      id: 'payment-main',
      debtId: 'debt-main-active',
      date: DateTime(2026, 1, 15),
    ).copyWith(
      createdAt: baseTime.add(const Duration(days: 4)),
      updatedAt: baseTime.add(const Duration(days: 4)),
    ),
  );
  await paymentRepository.addPayment(
    makeRepoPayment(
      id: 'payment-whatif',
      scenarioId: 'what-if',
      debtId: 'debt-whatif-paid',
      amount: 12000,
      principalPortion: 12000,
      interestPortion: 0,
      appliedBalanceBefore: 12000,
      appliedBalanceAfter: 0,
      date: DateTime(2026, 1, 20),
    ).copyWith(
      createdAt: baseTime.add(const Duration(days: 5)),
      updatedAt: baseTime.add(const Duration(days: 5)),
    ),
  );
  await paymentRepository.addPayment(
    makeRepoPayment(
      id: 'payment-deleted',
      debtId: 'debt-main-active',
      date: DateTime(2026, 1, 18),
    ).copyWith(
      createdAt: baseTime.add(const Duration(days: 6)),
      updatedAt: baseTime.add(const Duration(days: 6)),
    ),
  );
  await (db.update(
    db.paymentsTable,
  )..where((row) => row.id.equals('payment-deleted'))).write(
    PaymentsTableCompanion(
      deletedAt: Value(DateTime.utc(2026, 2, 1, 11)),
      updatedAt: Value(DateTime.utc(2026, 2, 1, 11)),
    ),
  );

  final mainPlan = await planRepository.getCurrentPlan();
  await planRepository.savePlan(
    mainPlan!.copyWith(strategy: Strategy.avalanche, extraMonthlyAmount: 7500),
  );
  await planRepository.savePlan(
    makeRepoPlan(
      id: 'plan-what-if',
      scenarioId: 'what-if',
      strategy: Strategy.avalanche,
      extraMonthlyAmount: 12500,
    ),
  );

  final settings = await settingsRepository.getSettings();
  await settingsRepository.updateSettings(
    settings.copyWith(
      currencyCode: 'VND',
      localeCode: 'vi-VN',
      notifPaymentReminder: false,
      notifMonthlyLog: false,
    ),
  );

  await db
      .into(db.milestonesTable)
      .insert(
        MilestonesTableCompanion.insert(
          id: const Value('milestone-visible'),
          type: MilestoneType.firstPayment,
          debtId: const Value('debt-main-active'),
          achievedAt: DateTime.utc(2026, 1, 16, 8),
          seen: const Value(true),
          metadata: const Value('{"saved_amount_cents":1200}'),
          createdAt: baseTime.add(const Duration(days: 7)),
        ),
      );
  await db
      .into(db.milestonesTable)
      .insert(
        MilestonesTableCompanion.insert(
          id: const Value('milestone-deleted'),
          type: MilestoneType.firstPayment,
          debtId: const Value('debt-main-active'),
          achievedAt: DateTime.utc(2026, 1, 18, 8),
          createdAt: baseTime.add(const Duration(days: 8)),
          deletedAt: Value(DateTime.utc(2026, 2, 1, 12)),
        ),
      );

  await db
      .into(db.interestRateHistoryTable)
      .insert(
        InterestRateHistoryTableCompanion.insert(
          id: const Value('rate-visible'),
          debtId: 'debt-main-active',
          apr: Decimal.parse('0.2499'),
          effectiveFrom: DateTime(2026, 1, 1),
          reason: const Value('promo-ended'),
          createdAt: baseTime.add(const Duration(days: 9)),
          updatedAt: baseTime.add(const Duration(days: 9)),
        ),
      );
  await db
      .into(db.interestRateHistoryTable)
      .insert(
        InterestRateHistoryTableCompanion.insert(
          id: const Value('rate-deleted'),
          debtId: 'debt-main-active',
          apr: Decimal.parse('0.1999'),
          effectiveFrom: DateTime(2025, 12, 1),
          createdAt: baseTime.add(const Duration(days: 10)),
          updatedAt: baseTime.add(const Duration(days: 10)),
          deletedAt: Value(DateTime.utc(2026, 2, 1, 13)),
        ),
      );

  await db
      .into(db.syncStateTable)
      .insert(
        SyncStateTableCompanion.insert(
          tableSyncName: 'debts',
          pendingWrites: const Value(2),
          updatedAt: baseTime.add(const Duration(days: 11)),
        ),
      );
  await db
      .into(db.timelineCacheTable)
      .insert(
        TimelineCacheTableCompanion.insert(
          planId: mainPlan.id,
          monthIndex: 0,
          yearMonth: '2026-01',
          entriesJson: '[]',
          totalPaymentCents: 5000,
          totalInterestCents: 1900,
          totalBalanceEndCents: 470000,
          generatedAt: baseTime.add(const Duration(days: 11)),
        ),
      );
}

Future<Archive> _readArchive(String filePath) async {
  final bytes = await File(filePath).readAsBytes();
  return ZipDecoder().decodeBytes(bytes);
}

String _archiveText(Archive archive, String fileName) {
  final file = archive.findFile(fileName);
  if (file == null) {
    throw StateError('Missing archive entry: $fileName');
  }
  return utf8.decode(file.content);
}

Map<String, dynamic> _archiveJsonObject(Archive archive, String fileName) {
  return Map<String, dynamic>.from(
    jsonDecode(_archiveText(archive, fileName)) as Map<dynamic, dynamic>,
  );
}

List<Map<String, dynamic>> _archiveJsonArray(Archive archive, String fileName) {
  return (jsonDecode(_archiveText(archive, fileName)) as List<dynamic>)
      .map((row) => Map<String, dynamic>.from(row as Map<dynamic, dynamic>))
      .toList(growable: false);
}

List<String> _csvHeaders(String text) {
  final rows = _parseCsv(text);
  return rows.first.cast<String>();
}

List<Map<String, String>> _csvRows(String text) {
  final rows = _parseCsv(text);
  if (rows.length == 1) {
    return const <Map<String, String>>[];
  }

  final headers = rows.first.cast<String>();
  return rows
      .skip(1)
      .map(
        (row) => <String, String>{
          for (var index = 0; index < headers.length; index++)
            headers[index]: index < row.length && row[index] != null
                ? row[index].toString()
                : '',
        },
      )
      .toList(growable: false);
}

List<List<dynamic>> _parseCsv(String text) {
  return const CsvToListConverter(
    eol: '\n',
    shouldParseNumbers: false,
  ).convert(text);
}

Future<int> _countRows(AppDatabase db, String tableName) async {
  final row = await db
      .customSelect('SELECT COUNT(*) AS row_count FROM $tableName')
      .getSingle();
  return row.read<int>('row_count');
}

Future<List<String>> _readStringColumn(
  AppDatabase db,
  String query,
  String columnName,
) async {
  final rows = await db.customSelect(query).get();
  return rows
      .map((row) => row.read<String>(columnName))
      .toList(growable: false);
}
