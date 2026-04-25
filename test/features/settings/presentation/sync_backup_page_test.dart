import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/di/injection.dart';
import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/settings/presentation/pages/sync_backup_page.dart';
import 'package:debt_payoff_manager/l10n/app_localizations.dart';
import 'package:debt_payoff_manager/sync/cloud_backup_service.dart';
import 'package:debt_payoff_manager/sync/sync_auth_service.dart';

import '../../../data/repositories/repository_test_helpers.dart';

void main() {
  testWidgets('local-only backup page shows Google opt-in controls', (
    tester,
  ) async {
    final settingsRepository = _FakeSettingsRepository(makeRepoSettings());
    final cloudBackupService = _FakeCloudBackupService();
    addTearDown(() async {
      await settingsRepository.dispose();
      await cloudBackupService.dispose();
      await getIt.reset();
    });

    await _pumpPage(tester, settingsRepository, cloudBackupService);

    expect(find.byKey(AppTestKeys.syncBackupGoogle), findsOneWidget);
    expect(find.byKey(AppTestKeys.syncBackupDisable), findsNothing);
    expect(find.text('Turn on cloud backup'), findsOneWidget);
  });

  testWidgets('Google opt-in updates to enabled state', (tester) async {
    final settingsRepository = _FakeSettingsRepository(makeRepoSettings());
    final cloudBackupService = _FakeCloudBackupService(
      onEnableGoogle: () async {
        await settingsRepository.updateSettings(
          settingsRepository.current.copyWith(
            trustLevel: 1,
            firebaseUid: 'google-uid',
          ),
        );
      },
    );
    addTearDown(() async {
      await settingsRepository.dispose();
      await cloudBackupService.dispose();
      await getIt.reset();
    });

    await _pumpPage(tester, settingsRepository, cloudBackupService);

    await tester.tap(find.byKey(AppTestKeys.syncBackupGoogle));
    await tester.pumpAndSettle();

    expect(cloudBackupService.enableGoogleCalls, 1);
    expect(find.text('Cloud backup is on'), findsOneWidget);
    expect(find.byKey(AppTestKeys.syncBackupDisable), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  _FakeSettingsRepository settingsRepository,
  _FakeCloudBackupService cloudBackupService,
) async {
  await getIt.reset();
  getIt
    ..registerSingleton<SettingsRepository>(settingsRepository)
    ..registerSingleton<CloudBackupService>(cloudBackupService);

  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SyncBackupPage(),
    ),
  );
  settingsRepository.emit();
  await tester.pump();
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.current);

  UserSettings current;
  final _controller = StreamController<UserSettings>.broadcast();

  void emit() => _controller.add(current);

  @override
  Future<UserSettings> getSettings() async => current;

  @override
  Future<void> updateSettings(UserSettings settings) async {
    current = settings;
    emit();
  }

  @override
  Stream<UserSettings> watchSettings() => _controller.stream;

  Future<void> dispose() => _controller.close();
}

class _FakeCloudBackupService implements CloudBackupService {
  _FakeCloudBackupService({this.onEnableGoogle});

  final Future<void> Function()? onEnableGoogle;
  final _controller = StreamController<CloudBackupRuntimeState>.broadcast();
  CloudBackupRuntimeState _state = const CloudBackupRuntimeState();
  int enableGoogleCalls = 0;

  @override
  CloudBackupRuntimeState get currentState => _state;

  @override
  Future<void> disableAndDeleteCloudBackup() async {}

  @override
  Future<void> enableWithApple() async {}

  @override
  Future<void> enableWithGoogle() async {
    enableGoogleCalls += 1;
    await onEnableGoogle?.call();
    _state = const CloudBackupRuntimeState(
      account: SyncAuthAccount(
        uid: 'google-uid',
        providerId: 'google.com',
        email: 'user@example.com',
      ),
    );
    _controller.add(_state);
  }

  @override
  Future<void> refresh() async {}

  @override
  Stream<CloudBackupRuntimeState> watchRuntimeState() => _controller.stream;

  Future<void> dispose() => _controller.close();
}
