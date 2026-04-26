import 'dart:async';

import 'pull_listener.dart';
import 'push_queue.dart';

enum SyncEngineStatus { stopped, starting, running, stopping, failed }

class SyncEngineState {
  const SyncEngineState({
    required this.status,
    this.uid,
    this.lastSyncedAt,
    this.lastError,
  });

  final SyncEngineStatus status;
  final String? uid;
  final DateTime? lastSyncedAt;
  final Object? lastError;
}

class SyncEngine {
  SyncEngine({
    required SyncPushQueue pushQueue,
    required SyncPullListener pullListener,
    SyncRemoteWriter remoteWriter = const NoopSyncRemoteWriter(),
    SyncPullApplier pullApplier = const NoopSyncPullApplier(),
  }) : _pushQueue = pushQueue,
       _pullListener = pullListener,
       _remoteWriter = remoteWriter,
       _pullApplier = pullApplier;

  final SyncPushQueue _pushQueue;
  final SyncPullListener _pullListener;
  final SyncRemoteWriter _remoteWriter;
  final SyncPullApplier _pullApplier;
  StreamSubscription<PullChangeSet>? _pullSubscription;
  StreamSubscription<void>? _pushSubscription;
  Timer? _pushDebounceTimer;
  final _stateController = StreamController<SyncEngineState>.broadcast();

  SyncEngineState _state = const SyncEngineState(
    status: SyncEngineStatus.stopped,
  );

  SyncEngineState get state => _state;

  Stream<SyncEngineState> get states => _stateController.stream;

  Future<void> start({required String uid}) async {
    if (_state.status == SyncEngineStatus.running && _state.uid == uid) {
      return;
    }

    _setState(SyncEngineState(status: SyncEngineStatus.starting, uid: uid));

    try {
      // Perform initial push on startup
      await _performPush(uid);

      await _pullSubscription?.cancel();
      _pullSubscription = _pullListener
          .watchUserChanges(uid: uid)
          .listen(
            (changeSet) => unawaited(_handlePullChangeSet(changeSet)),
            onError: (Object error) {
              _setState(
                SyncEngineState(
                  status: SyncEngineStatus.failed,
                  uid: uid,
                  lastSyncedAt: _state.lastSyncedAt,
                  lastError: error,
                ),
              );
            },
          );

      // Start listening to local database changes for auto-push
      await _pushSubscription?.cancel();
      _pushSubscription = _pushQueue.watchPendingWrites().listen((_) {
        _schedulePush();
      });

      _setState(
        SyncEngineState(
          status: SyncEngineStatus.running,
          uid: uid,
          lastSyncedAt: _state
              .lastSyncedAt, // _performPush updates lastSyncedAt if successful
        ),
      );
    } catch (error) {
      _setState(
        SyncEngineState(
          status: SyncEngineStatus.failed,
          uid: uid,
          lastError: error,
        ),
      );
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_state.status == SyncEngineStatus.stopped) return;

    final previousSyncedAt = _state.lastSyncedAt;
    final uid = _state.uid;
    _setState(SyncEngineState(status: SyncEngineStatus.stopping, uid: uid));

    _pushDebounceTimer?.cancel();
    _pushDebounceTimer = null;

    await _pushSubscription?.cancel();
    _pushSubscription = null;

    await _pullSubscription?.cancel();
    _pullSubscription = null;

    await _pullListener.stop();
    _setState(
      SyncEngineState(
        status: SyncEngineStatus.stopped,
        uid: uid,
        lastSyncedAt: previousSyncedAt,
      ),
    );
  }

  void _schedulePush() {
    _pushDebounceTimer?.cancel();
    _pushDebounceTimer = Timer(const Duration(seconds: 2), () {
      if (_state.status == SyncEngineStatus.running && _state.uid != null) {
        unawaited(_performPush(_state.uid!));
      }
    });
  }

  Future<void> _performPush(String uid) async {
    try {
      final batch = await _pushQueue.collectPendingWrites(uid: uid);
      final syncedAt = DateTime.now().toUtc();

      if (!batch.isEmpty) {
        await _remoteWriter.pushBatch(batch);
        await _pushQueue.markPushed(batch: batch, pushedAt: syncedAt);
      }

      _setState(
        SyncEngineState(
          status: SyncEngineStatus.running,
          uid: uid,
          lastSyncedAt: syncedAt,
        ),
      );
    } catch (error) {
      _setState(
        SyncEngineState(
          status: SyncEngineStatus.failed,
          uid: uid,
          lastSyncedAt: _state.lastSyncedAt,
          lastError: error,
        ),
      );
    }
  }

  Future<void> _handlePullChangeSet(PullChangeSet changeSet) async {
    if (changeSet.isEmpty) return;

    try {
      await _pullApplier.applyChangeSet(changeSet);
      _setState(
        SyncEngineState(
          status: SyncEngineStatus.running,
          uid: _state.uid,
          lastSyncedAt: DateTime.now().toUtc(),
        ),
      );
    } catch (error) {
      _setState(
        SyncEngineState(
          status: SyncEngineStatus.failed,
          uid: _state.uid,
          lastSyncedAt: _state.lastSyncedAt,
          lastError: error,
        ),
      );
    }
  }

  void _setState(SyncEngineState state) {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }
}
