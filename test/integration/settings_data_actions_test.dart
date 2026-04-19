import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/models/backup_bundle_preview.dart';
import 'package:debt_payoff_manager/core/models/data_export_artifact.dart';
import 'package:debt_payoff_manager/core/models/picked_backup_bundle.dart';
import 'package:debt_payoff_manager/core/router/app_router.dart';
import 'package:debt_payoff_manager/core/services/backup_file_picker.dart';
import 'package:debt_payoff_manager/core/services/data_management_service.dart';
import 'package:debt_payoff_manager/core/services/share_launcher.dart';
import 'package:debt_payoff_manager/data/local/database_provider.dart';

import '../data/repositories/repository_test_helpers.dart';
import '../helpers/test_app_harness.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('Settings data actions', () {
    testWidgets('CSV export calls the data service and share launcher', (
      tester,
    ) async {
      final db = DatabaseProvider.openTestDatabase();
      final fakeService = _FakeDataManagementService(db: db);
      final fakeLauncher = _RecordingShareLauncher();
      final harness = await TestAppHarness.create(
        db: db,
        dataManagementService: fakeService,
        shareLauncher: fakeLauncher,
      );
      addTearDown(() => harness.disposeWidgetTest(tester));

      await harness.onboardingCubit.completeOnboarding();
      await harness.pumpApp(tester);
      await _pumpUntilLocation(tester, harness, AppRoutes.home);
      await _openSettings(tester, harness);

      final exportTile = find.byKey(AppTestKeys.settingsDataExportCsv);
      await tester.pumpUntilVisible(exportTile);
      await tester.ensureVisible(exportTile);
      await tester.tap(exportTile);
      await tester.pumpRouterIdle();

      expect(fakeService.generatedKinds, <DataExportArtifactKind>[
        DataExportArtifactKind.csvBundle,
      ]);
      expect(fakeLauncher.sharedArtifacts, hasLength(1));
      expect(
        fakeLauncher.sharedArtifacts.single.kind,
        DataExportArtifactKind.csvBundle,
      );
    });

    testWidgets(
      'local backup calls the data service and dismissed sharing does not show an error snackbar',
      (tester) async {
        final db = DatabaseProvider.openTestDatabase();
        final fakeService = _FakeDataManagementService(db: db);
        final fakeLauncher = _RecordingShareLauncher(dismissed: true);
        final harness = await TestAppHarness.create(
          db: db,
          dataManagementService: fakeService,
          shareLauncher: fakeLauncher,
        );
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.onboardingCubit.completeOnboarding();
        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);
        await _openSettings(tester, harness);

        final backupTile = find.byKey(AppTestKeys.settingsDataLocalBackup);
        await tester.pumpUntilVisible(backupTile);
        await tester.ensureVisible(backupTile);
        await tester.tap(backupTile);
        await tester.pumpRouterIdle();

        expect(fakeService.generatedKinds, <DataExportArtifactKind>[
          DataExportArtifactKind.localBackup,
        ]);
        expect(fakeLauncher.sharedArtifacts, hasLength(1));
        expect(
          fakeLauncher.sharedArtifacts.single.kind,
          DataExportArtifactKind.localBackup,
        );
        expect(fakeLauncher.dismissedKinds, <DataExportArtifactKind>[
          DataExportArtifactKind.localBackup,
        ]);
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'restore backup picks a ZIP, shows preview, and restores after confirmation',
      (tester) async {
        final db = DatabaseProvider.openTestDatabase();
        final fakeService = _FakeDataManagementService(db: db);
        final fakePicker = _FakeBackupFilePicker(
          result: const PickedBackupBundle(
            path: '/tmp/debt_payoff_backup_test.zip',
            fileName: 'debt_payoff_backup_test.zip',
          ),
        );
        final harness = await TestAppHarness.create(
          db: db,
          backupFilePicker: fakePicker,
          dataManagementService: fakeService,
          shareLauncher: _RecordingShareLauncher(),
        );
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.onboardingCubit.completeOnboarding();
        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);
        await _openSettings(tester, harness);

        final restoreTile = find.byKey(AppTestKeys.settingsDataRestoreBackup);
        await tester.pumpUntilVisible(restoreTile);
        await tester.ensureVisible(restoreTile);
        await tester.tap(restoreTile);
        await tester.pump();
        await tester.pumpUntilVisible(find.text('Khôi phục từ bản sao lưu?'));

        expect(fakePicker.pickCallCount, 1);
        expect(fakeService.inspectedBackupPaths, <String>[
          '/tmp/debt_payoff_backup_test.zip',
        ]);
        expect(find.text('Khôi phục từ bản sao lưu?'), findsOneWidget);
        expect(find.textContaining('debts: 3'), findsOneWidget);
        expect(find.textContaining('payments: 2'), findsOneWidget);

        await tester.tap(find.byKey(AppTestKeys.settingsDataRestoreConfirm));
        await tester.pumpRouterIdle();

        expect(fakeService.restoredBackupPaths, <String>[
          '/tmp/debt_payoff_backup_test.zip',
        ]);
      },
    );

    testWidgets(
      'clear-all requires two confirmations and resets the app back to welcome',
      (tester) async {
        final harness = await TestAppHarness.create();
        addTearDown(() => harness.disposeWidgetTest(tester));

        await harness.debtRepository.addDebt(
          makeRepoDebt(id: 'reset-me', name: 'Reset Me'),
        );
        await harness.onboardingCubit.completeOnboarding();

        await harness.pumpApp(tester);
        await _pumpUntilLocation(tester, harness, AppRoutes.home);
        await _openSettings(tester, harness);

        final clearAllTile = find.byKey(AppTestKeys.settingsDataClearAll);
        await tester.pumpUntilVisible(clearAllTile);
        await tester.ensureVisible(clearAllTile);
        await tester.tap(clearAllTile);
        await tester.pumpRouterIdle();

        await tester.tap(
          find.byKey(AppTestKeys.settingsDataClearAllConfirmOne),
        );
        await tester.pumpRouterIdle();
        await tester.tap(
          find.byKey(AppTestKeys.settingsDataClearAllConfirmTwo),
        );
        await tester.pumpRouterIdle();

        await _pumpUntilLocation(tester, harness, AppRoutes.welcome);

        expect(find.byKey(AppTestKeys.welcomeAddFirstDebt), findsOneWidget);
        expect(await harness.debtRepository.getAllDebts(), isEmpty);
        expect(
          (await harness.settingsRepository.getSettings()).onboardingCompleted,
          isFalse,
        );
      },
    );
  });
}

class _FakeDataManagementService extends DataManagementService {
  _FakeDataManagementService({required super.db});

  final List<DataExportArtifactKind> generatedKinds =
      <DataExportArtifactKind>[];
  final List<String> inspectedBackupPaths = <String>[];
  final List<String> restoredBackupPaths = <String>[];

  @override
  Future<DataExportArtifact> generateCsvExportBundle() async {
    generatedKinds.add(DataExportArtifactKind.csvBundle);
    return const DataExportArtifact(
      path: '/tmp/debt_payoff_csv_export_test.zip',
      fileName: 'debt_payoff_csv_export_test.zip',
      mimeType: 'application/zip',
      kind: DataExportArtifactKind.csvBundle,
    );
  }

  @override
  Future<DataExportArtifact> generateLocalBackupBundle() async {
    generatedKinds.add(DataExportArtifactKind.localBackup);
    return const DataExportArtifact(
      path: '/tmp/debt_payoff_backup_test.zip',
      fileName: 'debt_payoff_backup_test.zip',
      mimeType: 'application/zip',
      kind: DataExportArtifactKind.localBackup,
    );
  }

  @override
  Future<BackupBundlePreview> inspectLocalBackupBundle({
    required String filePath,
    String? fileName,
  }) async {
    inspectedBackupPaths.add(filePath);
    return BackupBundlePreview(
      path: filePath,
      fileName: fileName ?? 'debt_payoff_backup_test.zip',
      bundleVersion: 1,
      schemaVersion: 1,
      exportedAtUtc: DateTime.utc(2026, 4, 19, 5, 6, 7),
      tableRowCounts: const <String, int>{
        'debts': 3,
        'payments': 2,
        'plans': 2,
        'user_settings': 1,
        'milestones': 1,
        'interest_rate_history': 1,
      },
    );
  }

  @override
  Future<void> restoreFromLocalBackup({
    required String filePath,
    String? fileName,
  }) async {
    restoredBackupPaths.add(filePath);
  }

  @override
  Future<void> clearAllData() async {}
}

class _FakeBackupFilePicker implements BackupFilePicker {
  _FakeBackupFilePicker({this.result});

  final PickedBackupBundle? result;
  int pickCallCount = 0;

  @override
  Future<PickedBackupBundle?> pickBackupBundle() async {
    pickCallCount += 1;
    return result;
  }
}

class _RecordingShareLauncher implements ShareLauncher {
  _RecordingShareLauncher({this.dismissed = false});

  final bool dismissed;
  final List<DataExportArtifact> sharedArtifacts = <DataExportArtifact>[];
  final List<DataExportArtifactKind> dismissedKinds =
      <DataExportArtifactKind>[];

  @override
  Future<void> shareArtifact(DataExportArtifact artifact) async {
    sharedArtifacts.add(artifact);
    if (dismissed) {
      dismissedKinds.add(artifact.kind);
    }
  }
}

Future<void> _openSettings(WidgetTester tester, TestAppHarness harness) async {
  harness.router.go(AppRoutes.settings);
  await _pumpUntilLocation(tester, harness, AppRoutes.settings);
}

Future<void> _pumpUntilLocation(
  WidgetTester tester,
  TestAppHarness harness,
  String expectedLocation,
) async {
  for (var i = 0; i < 120; i++) {
    if (harness.currentLocation == expectedLocation) {
      return;
    }
    await tester.pumpRouterIdle();
  }

  fail('Expected location $expectedLocation, got ${harness.currentLocation}');
}
