import 'dart:async';

import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/sync/cloud_backup_remote_store.dart';
import 'package:debt_payoff_manager/sync/cloud_backup_service.dart';
import 'package:debt_payoff_manager/sync/pull_listener.dart';
import 'package:debt_payoff_manager/sync/push_queue.dart';
import 'package:debt_payoff_manager/sync/sync_auth_service.dart';
import 'package:debt_payoff_manager/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/repositories/repository_test_helpers.dart';

void main() {
  test(
    'enableWithGoogle signs in, upgrades settings, and starts sync',
    () async {
      final settingsRepository = _FakeSettingsRepository(makeRepoSettings());
      final authService = _FakeSyncAuthService(
        googleAccount: const SyncAuthAccount(
          uid: 'google-uid',
          providerId: 'google.com',
          email: 'user@example.com',
        ),
      );
      final pushQueue = _FakePushQueue();
      final engine = SyncEngine(
        pushQueue: pushQueue,
        pullListener: _FakePullListener(),
      );
      final service = CloudBackupCoordinator(
        settingsRepository: settingsRepository,
        authService: authService,
        syncEngine: engine,
        remoteStore: _FakeRemoteStore(),
      );

      await service.enableWithGoogle();

      expect(settingsRepository.current.trustLevel, 1);
      expect(settingsRepository.current.firebaseUid, 'google-uid');
      expect(pushQueue.collectedUid, 'google-uid');
      expect(engine.state.status, SyncEngineStatus.running);
      expect(service.currentState.account?.email, 'user@example.com');

      await engine.stop();
      await service.dispose();
    },
  );

  test(
    'enableWithGoogle rolls back settings when initial sync fails',
    () async {
      final initialSettings = makeRepoSettings();
      final settingsRepository = _FakeSettingsRepository(initialSettings);
      final authService = _FakeSyncAuthService(
        googleAccount: const SyncAuthAccount(
          uid: 'google-uid',
          providerId: 'google.com',
        ),
      );
      final engine = SyncEngine(
        pushQueue: _ThrowingPushQueue(),
        pullListener: _FakePullListener(),
      );
      final service = CloudBackupCoordinator(
        settingsRepository: settingsRepository,
        authService: authService,
        syncEngine: engine,
        remoteStore: _FakeRemoteStore(),
      );

      await expectLater(service.enableWithGoogle(), throwsStateError);

      expect(settingsRepository.current, initialSettings);
      expect(authService.signOutCalls, 1);
      expect(engine.state.status, SyncEngineStatus.stopped);

      await service.dispose();
    },
  );

  test(
    'disableAndDeleteCloudBackup stops sync, deletes cloud, and localizes settings',
    () async {
      final settingsRepository = _FakeSettingsRepository(
        makeRepoSettings(trustLevel: 1, firebaseUid: 'cloud-uid'),
      );
      final authService = _FakeSyncAuthService(
        current: const SyncAuthAccount(
          uid: 'cloud-uid',
          providerId: 'google.com',
        ),
      );
      final pullListener = _FakePullListener();
      final engine = SyncEngine(
        pushQueue: _FakePushQueue(),
        pullListener: pullListener,
      );
      final remoteStore = _FakeRemoteStore();
      final service = CloudBackupCoordinator(
        settingsRepository: settingsRepository,
        authService: authService,
        syncEngine: engine,
        remoteStore: remoteStore,
      );
      await engine.start(uid: 'cloud-uid');
      // Let the coordinator process engine state transitions.
      await Future<void>.delayed(Duration.zero);

      await service.disableAndDeleteCloudBackup();

      expect(pullListener.stopped, isTrue);
      expect(remoteStore.deletedUid, 'cloud-uid');
      expect(authService.signOutCalls, 1);
      expect(settingsRepository.current.trustLevel, 0);
      expect(settingsRepository.current.firebaseUid, isNull);

      await service.dispose();
    },
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.current);

  UserSettings current;
  final _controller = StreamController<UserSettings>.broadcast();

  @override
  Future<UserSettings> getSettings() async => current;

  @override
  Future<void> updateSettings(UserSettings settings) async {
    current = settings;
    _controller.add(settings);
  }

  @override
  Stream<UserSettings> watchSettings() => _controller.stream;
}

class _FakeSyncAuthService implements SyncAuthService {
  _FakeSyncAuthService({this.current, this.googleAccount, this.appleAccount});

  SyncAuthAccount? current;
  SyncAuthAccount? googleAccount;
  SyncAuthAccount? appleAccount;
  int signOutCalls = 0;

  @override
  Future<SyncAuthAccount?> currentAccount() async => current;

  @override
  Future<SyncAuthAccount> signInWithApple() async {
    current = appleAccount;
    return appleAccount!;
  }

  @override
  Future<SyncAuthAccount> signInWithGoogle() async {
    current = googleAccount;
    return googleAccount!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    current = null;
  }
}

class _FakeRemoteStore implements CloudBackupRemoteStore {
  String? deletedUid;

  @override
  Future<void> deleteUserMirrorData(String uid) async {
    deletedUid = uid;
  }
}

class _FakePushQueue implements SyncPushQueue {
  String? collectedUid;

  @override
  Future<SyncPushBatch> collectPendingWrites({required String uid}) async {
    collectedUid = uid;
    return SyncPushBatch(uid: uid, entries: const []);
  }

  @override
  Future<void> markPushed({
    required SyncPushBatch batch,
    required DateTime pushedAt,
  }) async {}
}

class _ThrowingPushQueue implements SyncPushQueue {
  @override
  Future<SyncPushBatch> collectPendingWrites({required String uid}) {
    throw StateError('initial sync failed');
  }

  @override
  Future<void> markPushed({
    required SyncPushBatch batch,
    required DateTime pushedAt,
  }) async {}
}

class _FakePullListener implements SyncPullListener {
  final _controller = StreamController<PullChangeSet>.broadcast();
  bool stopped = false;

  @override
  Stream<PullChangeSet> watchUserChanges({required String uid}) {
    return _controller.stream;
  }

  @override
  Future<void> stop() async {
    stopped = true;
    await _controller.close();
  }
}
