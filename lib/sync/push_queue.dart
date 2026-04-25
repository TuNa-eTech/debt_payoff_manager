import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/local/database.dart';
import '../data/local/stores/sync_state_store.dart';
import 'firestore_models.dart';

class SyncQueueEntry {
  const SyncQueueEntry({
    required this.collection,
    required this.documentId,
    required this.data,
    this.isDelete = false,
  });

  final FirestoreSyncCollection collection;
  final String documentId;
  final FirestoreJson data;
  final bool isDelete;
}

class SyncPushBatch {
  const SyncPushBatch({required this.uid, required this.entries});

  final String uid;
  final List<SyncQueueEntry> entries;

  bool get isEmpty => entries.isEmpty;
}

abstract interface class SyncPushQueue {
  Future<SyncPushBatch> collectPendingWrites({required String uid});

  Future<void> markPushed({
    required SyncPushBatch batch,
    required DateTime pushedAt,
  });
}

abstract interface class SyncRemoteWriter {
  Future<void> pushBatch(SyncPushBatch batch);
}

class NoopSyncRemoteWriter implements SyncRemoteWriter {
  const NoopSyncRemoteWriter();

  @override
  Future<void> pushBatch(SyncPushBatch batch) async {}
}

class CloudFirestoreSyncRemoteWriter implements SyncRemoteWriter {
  CloudFirestoreSyncRemoteWriter({required FirebaseFirestore firestore})
    : _firestore = firestore;

  static const int _maxWritesPerBatch = 500;

  final FirebaseFirestore _firestore;

  @override
  Future<void> pushBatch(SyncPushBatch batch) async {
    if (batch.isEmpty) return;

    for (
      var offset = 0;
      offset < batch.entries.length;
      offset += _maxWritesPerBatch
    ) {
      final writeBatch = _firestore.batch();
      final chunk = batch.entries.skip(offset).take(_maxWritesPerBatch);

      for (final entry in chunk) {
        final docRef = _firestore.doc(
          FirestorePaths.documentPath(
            uid: batch.uid,
            collection: entry.collection,
            documentId: entry.documentId,
          ),
        );

        if (entry.isDelete) {
          writeBatch.delete(docRef);
        } else {
          writeBatch.set(docRef, entry.data);
        }
      }

      await writeBatch.commit();
    }
  }
}

class DriftSyncPushQueue implements SyncPushQueue {
  DriftSyncPushQueue({
    required AppDatabase db,
    required SyncStateStore syncStateStore,
    required String deviceId,
    int schemaVersion = 1,
  }) : _db = db,
       _syncStateStore = syncStateStore,
       _metadata = FirestoreSyncMetadata(
         deviceId: deviceId,
         schemaVersion: schemaVersion,
       );

  final AppDatabase _db;
  final SyncStateStore _syncStateStore;
  final FirestoreSyncMetadata _metadata;

  @override
  Future<SyncPushBatch> collectPendingWrites({required String uid}) async {
    final entries = <SyncQueueEntry>[
      ...await _collectDebts(),
      ...await _collectPayments(),
      ...await _collectPlans(),
      ...await _collectSettings(),
      ...await _collectMilestones(),
      ...await _collectInterestRateHistory(),
    ];

    return SyncPushBatch(uid: uid, entries: entries);
  }

  @override
  Future<void> markPushed({
    required SyncPushBatch batch,
    required DateTime pushedAt,
  }) async {
    for (final collection
        in batch.entries.map((entry) => entry.collection).toSet()) {
      await _syncStateStore.markPushed(collection.path, pushedAt: pushedAt);
    }
  }

  Future<List<SyncQueueEntry>> _collectDebts() async {
    final state = await _syncStateStore.getState(
      FirestoreSyncCollection.debts.path,
    );
    final rows = await _db.select(_db.debtsTable).get();
    return rows
        .where((row) => _shouldPush(state, row.updatedAt, row.deletedAt))
        .map(
          (row) => SyncQueueEntry(
            collection: FirestoreSyncCollection.debts,
            documentId: row.id,
            data: FirestoreDebtSerializer.toFirestoreJson(row, _metadata),
          ),
        )
        .toList();
  }

  Future<List<SyncQueueEntry>> _collectPayments() async {
    final state = await _syncStateStore.getState(
      FirestoreSyncCollection.payments.path,
    );
    final rows = await _db.select(_db.paymentsTable).get();
    return rows
        .where((row) => _shouldPush(state, row.updatedAt, row.deletedAt))
        .map(
          (row) => SyncQueueEntry(
            collection: FirestoreSyncCollection.payments,
            documentId: row.id,
            data: FirestorePaymentSerializer.toFirestoreJson(row, _metadata),
          ),
        )
        .toList();
  }

  Future<List<SyncQueueEntry>> _collectPlans() async {
    final state = await _syncStateStore.getState(
      FirestoreSyncCollection.plans.path,
    );
    final rows = await _db.select(_db.plansTable).get();
    return rows
        .where((row) => _shouldPush(state, row.updatedAt, row.deletedAt))
        .map(
          (row) => SyncQueueEntry(
            collection: FirestoreSyncCollection.plans,
            documentId: row.id,
            data: FirestorePlanSerializer.toFirestoreJson(row, _metadata),
          ),
        )
        .toList();
  }

  Future<List<SyncQueueEntry>> _collectSettings() async {
    final state = await _syncStateStore.getState(
      FirestoreSyncCollection.settings.path,
    );
    final rows = await _db.select(_db.userSettingsTable).get();
    return rows
        .where((row) => _shouldPush(state, row.updatedAt, null))
        .map(
          (row) => SyncQueueEntry(
            collection: FirestoreSyncCollection.settings,
            documentId: firestoreSettingsDocumentId,
            data: FirestoreSettingsSerializer.toFirestoreJson(row, _metadata),
          ),
        )
        .toList();
  }

  Future<List<SyncQueueEntry>> _collectMilestones() async {
    final state = await _syncStateStore.getState(
      FirestoreSyncCollection.milestones.path,
    );
    final rows = await _db.select(_db.milestonesTable).get();
    return rows
        .where((row) => _shouldPush(state, row.createdAt, row.deletedAt))
        .map(
          (row) => SyncQueueEntry(
            collection: FirestoreSyncCollection.milestones,
            documentId: row.id,
            data: FirestoreMilestoneSerializer.toFirestoreJson(row, _metadata),
          ),
        )
        .toList();
  }

  Future<List<SyncQueueEntry>> _collectInterestRateHistory() async {
    final state = await _syncStateStore.getState(
      FirestoreSyncCollection.interestRateHistory.path,
    );
    final rows = await _db.select(_db.interestRateHistoryTable).get();
    return rows
        .where((row) => _shouldPush(state, row.updatedAt, row.deletedAt))
        .map(
          (row) => SyncQueueEntry(
            collection: FirestoreSyncCollection.interestRateHistory,
            documentId: row.id,
            data: FirestoreInterestRateHistorySerializer.toFirestoreJson(
              row,
              _metadata,
            ),
          ),
        )
        .toList();
  }

  bool _shouldPush(
    SyncStateRow? state,
    DateTime updatedAt,
    DateTime? deletedAt,
  ) {
    if (state == null || state.pendingWrites > 0) return true;

    final lastPushedAt = state.lastPushedAt;
    if (lastPushedAt == null) return true;

    final clock = _effectiveClock(updatedAt: updatedAt, deletedAt: deletedAt);
    return clock.isAfter(lastPushedAt.toUtc());
  }

  DateTime _effectiveClock({
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) {
    if (deletedAt == null) return updatedAt.toUtc();
    final normalizedUpdatedAt = updatedAt.toUtc();
    final normalizedDeletedAt = deletedAt.toUtc();
    return normalizedDeletedAt.isAfter(normalizedUpdatedAt)
        ? normalizedDeletedAt
        : normalizedUpdatedAt;
  }
}
