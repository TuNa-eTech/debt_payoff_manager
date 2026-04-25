import 'dart:async';

import 'package:debt_payoff_manager/sync/firestore_models.dart';
import 'package:debt_payoff_manager/sync/pull_listener.dart';
import 'package:debt_payoff_manager/sync/push_queue.dart';
import 'package:debt_payoff_manager/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('start pushes pending batch before marking it pushed', () async {
    final entry = SyncQueueEntry(
      collection: FirestoreSyncCollection.debts,
      documentId: 'debt-1',
      data: const <String, Object?>{'id': 'debt-1'},
    );
    final pushQueue = _FakePushQueue(
      batch: SyncPushBatch(uid: 'alice', entries: [entry]),
    );
    final remoteWriter = _RecordingRemoteWriter();
    final pullListener = _FakePullListener();
    final engine = SyncEngine(
      pushQueue: pushQueue,
      pullListener: pullListener,
      remoteWriter: remoteWriter,
    );

    await engine.start(uid: 'alice');

    expect(remoteWriter.pushedBatches, hasLength(1));
    expect(
      remoteWriter.pushedBatches.single.entries.single.documentId,
      'debt-1',
    );
    expect(pushQueue.markedBatch, same(remoteWriter.pushedBatches.single));
    expect(engine.state.status, SyncEngineStatus.running);

    await engine.stop();
  });

  test('pull listener changes are applied through the pull applier', () async {
    final pushQueue = _FakePushQueue(
      batch: const SyncPushBatch(uid: 'alice', entries: []),
    );
    final pullListener = _FakePullListener();
    final pullApplier = _RecordingPullApplier();
    final engine = SyncEngine(
      pushQueue: pushQueue,
      pullListener: pullListener,
      pullApplier: pullApplier,
    );

    await engine.start(uid: 'alice');

    final changeSet = PullChangeSet(
      uid: 'alice',
      changes: [
        PullChange(
          collection: FirestoreSyncCollection.debts,
          documentId: 'debt-1',
          type: PullChangeType.modified,
          data: const <String, Object?>{'id': 'debt-1'},
        ),
      ],
    );
    pullListener.add(changeSet);

    final applied = await pullApplier.nextApplied;
    expect(applied, same(changeSet));
    expect(engine.state.lastSyncedAt, isNotNull);

    await engine.stop();
    expect(pullListener.stopped, isTrue);
  });
}

class _FakePushQueue implements SyncPushQueue {
  _FakePushQueue({required this.batch});

  final SyncPushBatch batch;
  SyncPushBatch? markedBatch;
  final _pendingWritesController = StreamController<void>.broadcast();

  @override
  Stream<void> watchPendingWrites() => _pendingWritesController.stream;

  @override
  Future<SyncPushBatch> collectPendingWrites({required String uid}) async {
    return SyncPushBatch(uid: uid, entries: batch.entries);
  }

  @override
  Future<void> markPushed({
    required SyncPushBatch batch,
    required DateTime pushedAt,
  }) async {
    markedBatch = batch;
  }
}

class _RecordingRemoteWriter implements SyncRemoteWriter {
  final pushedBatches = <SyncPushBatch>[];

  @override
  Future<void> pushBatch(SyncPushBatch batch) async {
    pushedBatches.add(batch);
  }
}

class _FakePullListener implements SyncPullListener {
  final _controller = StreamController<PullChangeSet>.broadcast();
  bool stopped = false;

  @override
  Stream<PullChangeSet> watchUserChanges({required String uid}) {
    return _controller.stream;
  }

  void add(PullChangeSet changeSet) {
    _controller.add(changeSet);
  }

  @override
  Future<void> stop() async {
    stopped = true;
    await _controller.close();
  }
}

class _RecordingPullApplier implements SyncPullApplier {
  final _applied = StreamController<PullChangeSet>.broadcast();

  Future<PullChangeSet> get nextApplied => _applied.stream.first;

  @override
  Future<void> applyChangeSet(PullChangeSet changeSet) async {
    _applied.add(changeSet);
  }
}
