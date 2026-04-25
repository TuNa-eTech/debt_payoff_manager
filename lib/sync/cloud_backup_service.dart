import 'dart:async';

import '../domain/entities/user_settings.dart';
import '../domain/repositories/settings_repository.dart';
import 'cloud_backup_remote_store.dart';
import 'sync_auth_service.dart';
import 'sync_engine.dart';

enum CloudBackupOperation { idle, enabling, disabling }

class CloudBackupRuntimeState {
  const CloudBackupRuntimeState({
    this.operation = CloudBackupOperation.idle,
    this.account,
    this.lastSyncedAt,
    this.lastError,
  });

  final CloudBackupOperation operation;
  final SyncAuthAccount? account;
  final DateTime? lastSyncedAt;
  final Object? lastError;

  bool get isBusy => operation != CloudBackupOperation.idle;

  CloudBackupRuntimeState copyWith({
    CloudBackupOperation? operation,
    SyncAuthAccount? account,
    bool clearAccount = false,
    DateTime? lastSyncedAt,
    Object? lastError,
    bool clearLastError = false,
  }) {
    return CloudBackupRuntimeState(
      operation: operation ?? this.operation,
      account: clearAccount ? null : account ?? this.account,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: clearLastError ? null : lastError ?? this.lastError,
    );
  }
}

abstract interface class CloudBackupService {
  CloudBackupRuntimeState get currentState;

  Stream<CloudBackupRuntimeState> watchRuntimeState();

  Future<void> refresh();

  Future<void> enableWithGoogle();

  Future<void> enableWithApple();

  Future<void> disableAndDeleteCloudBackup();
}

class CloudBackupCoordinator implements CloudBackupService {
  CloudBackupCoordinator({
    required SettingsRepository settingsRepository,
    required SyncAuthService authService,
    required SyncEngine syncEngine,
    required CloudBackupRemoteStore remoteStore,
  }) : _settingsRepository = settingsRepository,
       _authService = authService,
       _syncEngine = syncEngine,
       _remoteStore = remoteStore {
    _engineSubscription = _syncEngine.states.listen(_handleEngineState);
  }

  final SettingsRepository _settingsRepository;
  final SyncAuthService _authService;
  final SyncEngine _syncEngine;
  final CloudBackupRemoteStore _remoteStore;
  late final StreamSubscription<SyncEngineState> _engineSubscription;

  final _stateController =
      StreamController<CloudBackupRuntimeState>.broadcast();
  CloudBackupRuntimeState _state = const CloudBackupRuntimeState();

  @override
  CloudBackupRuntimeState get currentState => _state;

  @override
  Stream<CloudBackupRuntimeState> watchRuntimeState() {
    return _stateController.stream;
  }

  @override
  Future<void> refresh() async {
    try {
      final account = await _authService.currentAccount();
      _emit(_state.copyWith(account: account, clearAccount: account == null));
    } catch (error) {
      _emit(_state.copyWith(lastError: error));
    }
  }

  @override
  Future<void> enableWithGoogle() {
    return _enable(_authService.signInWithGoogle);
  }

  @override
  Future<void> enableWithApple() {
    return _enable(_authService.signInWithApple);
  }

  @override
  Future<void> disableAndDeleteCloudBackup() async {
    if (_state.isBusy) return;

    final settings = await _settingsRepository.getSettings();
    final uid = settings.firebaseUid ?? _state.account?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('No cloud backup account is linked.');
    }

    _emit(
      _state.copyWith(
        operation: CloudBackupOperation.disabling,
        clearLastError: true,
      ),
    );

    try {
      await _syncEngine.stop();
      await _remoteStore.deleteUserMirrorData(uid);
      await _authService.signOut();
      await _settingsRepository.updateSettings(
        settings.copyWith(trustLevel: 0, clearFirebaseUid: true),
      );
      _emit(CloudBackupRuntimeState(lastSyncedAt: _state.lastSyncedAt));
    } catch (error) {
      _emit(
        _state.copyWith(operation: CloudBackupOperation.idle, lastError: error),
      );
      rethrow;
    }
  }

  Future<void> _enable(Future<SyncAuthAccount> Function() signIn) async {
    if (_state.isBusy) return;

    final previousSettings = await _settingsRepository.getSettings();
    _emit(
      _state.copyWith(
        operation: CloudBackupOperation.enabling,
        clearLastError: true,
      ),
    );

    SyncAuthAccount? account;
    try {
      account = await signIn();
      final upgradedSettings = previousSettings.copyWith(
        trustLevel: 1,
        firebaseUid: account.uid,
      );
      await _settingsRepository.updateSettings(upgradedSettings);
      await _syncEngine.start(uid: account.uid);
      _emit(
        _state.copyWith(
          operation: CloudBackupOperation.idle,
          account: account,
          lastSyncedAt: _syncEngine.state.lastSyncedAt,
          clearLastError: true,
        ),
      );
    } catch (error) {
      if (account != null) {
        await _rollbackUpgrade(previousSettings);
      }
      _emit(
        _state.copyWith(
          operation: CloudBackupOperation.idle,
          lastError: error,
          clearAccount: account != null,
        ),
      );
      rethrow;
    }
  }

  Future<void> _rollbackUpgrade(UserSettings previousSettings) async {
    try {
      await _syncEngine.stop();
      await _authService.signOut();
      await _settingsRepository.updateSettings(previousSettings);
    } on Object {
      // Preserve the original enable error for the caller/UI.
    }
  }

  void _handleEngineState(SyncEngineState engineState) {
    final operation = switch (engineState.status) {
      SyncEngineStatus.starting => CloudBackupOperation.enabling,
      SyncEngineStatus.stopping => CloudBackupOperation.disabling,
      _ => CloudBackupOperation.idle,
    };
    _emit(
      _state.copyWith(
        operation: operation,
        lastSyncedAt: engineState.lastSyncedAt,
        lastError: engineState.lastError,
        clearLastError: engineState.lastError == null,
      ),
    );
  }

  void _emit(CloudBackupRuntimeState state) {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  // Kept for test teardown if future callers need to own coordinator lifetime.
  Future<void> dispose() async {
    await _engineSubscription.cancel();
    await _stateController.close();
  }
}
