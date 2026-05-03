import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../data/local/database.dart';
import '../data/local/stores/sync_state_store.dart';
import 'conflict_resolver.dart';
import 'firestore_models.dart';

enum PullChangeType { added, modified, removed }

class PullChange {
  const PullChange({
    required this.collection,
    required this.documentId,
    required this.type,
    required this.data,
  });

  final FirestoreSyncCollection collection;
  final String documentId;
  final PullChangeType type;
  final FirestoreJson data;
}

class PullChangeSet {
  const PullChangeSet({required this.uid, required this.changes});

  final String uid;
  final List<PullChange> changes;

  bool get isEmpty => changes.isEmpty;
}

abstract interface class SyncPullListener {
  Stream<PullChangeSet> watchUserChanges({required String uid});

  Future<void> stop();
}

abstract interface class SyncPullApplier {
  Future<void> applyChangeSet(PullChangeSet changeSet);
}

class NoopSyncPullApplier implements SyncPullApplier {
  const NoopSyncPullApplier();

  @override
  Future<void> applyChangeSet(PullChangeSet changeSet) async {}
}

class CloudFirestoreSyncPullListener implements SyncPullListener {
  CloudFirestoreSyncPullListener({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _subscriptions = [];

  StreamController<PullChangeSet>? _controller;

  @override
  Stream<PullChangeSet> watchUserChanges({required String uid}) {
    unawaited(stop());

    final controller = StreamController<PullChangeSet>.broadcast(
      onCancel: () => stop(),
    );
    _controller = controller;

    for (final collection in FirestoreSyncCollection.values) {
      final subscription = _firestore
          .collection(FirestorePaths.collectionPath(uid, collection))
          .snapshots()
          .listen(
            (snapshot) {
              final changes = snapshot.docChanges
                  .map(
                    (change) => PullChange(
                      collection: collection,
                      documentId: change.doc.id,
                      type: _toPullChangeType(change.type),
                      data: _normalizeFirestoreData(change.doc.data()),
                    ),
                  )
                  .toList();

              if (changes.isNotEmpty && !controller.isClosed) {
                controller.add(PullChangeSet(uid: uid, changes: changes));
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!controller.isClosed) {
                controller.addError(error, stackTrace);
              }
            },
          );

      _subscriptions.add(subscription);
    }

    return controller.stream;
  }

  @override
  Future<void> stop() async {
    final subscriptions = List.of(_subscriptions);
    _subscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }

    final controller = _controller;
    _controller = null;
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
  }

  PullChangeType _toPullChangeType(DocumentChangeType type) {
    switch (type) {
      case DocumentChangeType.added:
        return PullChangeType.added;
      case DocumentChangeType.modified:
        return PullChangeType.modified;
      case DocumentChangeType.removed:
        return PullChangeType.removed;
    }
  }

  FirestoreJson _normalizeFirestoreData(Map<String, dynamic>? data) {
    if (data == null) return const <String, Object?>{};
    return data.map((key, value) => MapEntry(key, _normalizeValue(value)));
  }

  Object? _normalizeValue(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    return value;
  }
}

class DriftSyncPullApplier implements SyncPullApplier {
  DriftSyncPullApplier({
    required AppDatabase db,
    required SyncStateStore syncStateStore,
    LastWriteWinsConflictResolver conflictResolver =
        const LastWriteWinsConflictResolver(),
  }) : _db = db,
       _syncStateStore = syncStateStore,
       _conflictResolver = conflictResolver;

  final AppDatabase _db;
  final SyncStateStore _syncStateStore;
  final LastWriteWinsConflictResolver _conflictResolver;

  @override
  Future<void> applyChangeSet(PullChangeSet changeSet) async {
    if (changeSet.isEmpty) return;

    final touchedCollections = <FirestoreSyncCollection>{};
    await _db.transaction(() async {
      for (final change in _sortChanges(changeSet.changes)) {
        if (change.type == PullChangeType.removed) {
          continue;
        }

        final applied = await _applyChange(change);
        if (applied) {
          touchedCollections.add(change.collection);
        }
      }
    });

    final pulledAt = DateTime.now().toUtc();
    for (final collection in touchedCollections) {
      await _syncStateStore.markPulled(collection.path, pulledAt: pulledAt);
    }
  }

  List<PullChange> _sortChanges(List<PullChange> changes) {
    final sorted = List<PullChange>.of(changes);
    sorted.sort(
      (a, b) => _collectionOrder(
        a.collection,
      ).compareTo(_collectionOrder(b.collection)),
    );
    return sorted;
  }

  int _collectionOrder(FirestoreSyncCollection collection) {
    switch (collection) {
      case FirestoreSyncCollection.scenarios:
        return 0;
      case FirestoreSyncCollection.debts:
        return 1;
      case FirestoreSyncCollection.plans:
        return 2;
      case FirestoreSyncCollection.settings:
        return 3;
      case FirestoreSyncCollection.interestRateHistory:
        return 4;
      case FirestoreSyncCollection.payments:
        return 5;
      case FirestoreSyncCollection.milestones:
        return 6;
      case FirestoreSyncCollection.scenarioAssumptions:
        return 7;
    }
  }

  Future<bool> _applyChange(PullChange change) {
    switch (change.collection) {
      case FirestoreSyncCollection.scenarios:
        return _applyScenario(change.data);
      case FirestoreSyncCollection.debts:
        return _applyDebt(change.data);
      case FirestoreSyncCollection.payments:
        return _applyPayment(change.data);
      case FirestoreSyncCollection.plans:
        return _applyPlan(change.data);
      case FirestoreSyncCollection.settings:
        return _applySettings(change.data);
      case FirestoreSyncCollection.milestones:
        return _applyMilestone(change.data);
      case FirestoreSyncCollection.interestRateHistory:
        return _applyInterestRateHistory(change.data);
      case FirestoreSyncCollection.scenarioAssumptions:
        return _applyScenarioAssumption(change.data);
    }
  }

  Future<bool> _applyScenario(FirestoreJson json) async {
    final input = FirestoreScenarioSerializer.fromFirestoreJson(json);
    final local = await (_db.select(
      _db.scenariosTable,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();

    if (!_shouldApply(
      local
          ?.createdAt, // We don't have updatedAt for scenarios in the DB, so we use createdAt as approximation or just allow overwrite if it's newer based on other data
      input.updatedAt,
      local?.deletedAt,
      input.deletedAt,
    )) {
      return false;
    }

    await _db.into(_db.scenariosTable).insertOnConflictUpdate(input.companion);
    return true;
  }

  Future<bool> _applyDebt(FirestoreJson json) async {
    final input = FirestoreDebtSerializer.fromFirestoreJson(json);
    final local = await (_db.select(
      _db.debtsTable,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();

    if (!_shouldApply(
      local?.updatedAt,
      input.updatedAt,
      local?.deletedAt,
      input.deletedAt,
    )) {
      return false;
    }

    await _db.into(_db.debtsTable).insertOnConflictUpdate(input.companion);
    return true;
  }

  Future<bool> _applyPayment(FirestoreJson json) async {
    final input = FirestorePaymentSerializer.fromFirestoreJson(json);
    final local = await (_db.select(
      _db.paymentsTable,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();

    if (!_shouldApply(
      local?.updatedAt,
      input.updatedAt,
      local?.deletedAt,
      input.deletedAt,
    )) {
      return false;
    }

    await _db.into(_db.paymentsTable).insertOnConflictUpdate(input.companion);
    return true;
  }

  Future<bool> _applyPlan(FirestoreJson json) async {
    final input = FirestorePlanSerializer.fromFirestoreJson(json);
    final local = await (_db.select(
      _db.plansTable,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();

    if (!_shouldApply(
      local?.updatedAt,
      input.updatedAt,
      local?.deletedAt,
      input.deletedAt,
    )) {
      return false;
    }

    if (input.deletedAt == null) {
      await (_db.delete(_db.plansTable)
            ..where((row) => row.scenarioId.equals(input.scenarioId))
            ..where((row) => row.id.equals(input.id).not()))
          .go();
    }

    await _db.into(_db.plansTable).insertOnConflictUpdate(input.companion);
    return true;
  }

  Future<bool> _applySettings(FirestoreJson json) async {
    final input = FirestoreSettingsSerializer.fromFirestoreJson(json);
    final local = await (_db.select(
      _db.userSettingsTable,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();

    if (!_shouldApply(
      local?.updatedAt,
      input.updatedAt,
      null,
      input.deletedAt,
    )) {
      return false;
    }

    await _db
        .into(_db.userSettingsTable)
        .insertOnConflictUpdate(
          input.companion.copyWith(
            isPremium: Value(local?.isPremium ?? false),
            premiumExpiresAt: Value(local?.premiumExpiresAt),
          ),
        );
    return true;
  }

  Future<bool> _applyMilestone(FirestoreJson json) async {
    final input = FirestoreMilestoneSerializer.fromFirestoreJson(json);
    final local = await (_db.select(
      _db.milestonesTable,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();

    if (!_shouldApply(
      local?.createdAt,
      input.updatedAt,
      local?.deletedAt,
      input.deletedAt,
    )) {
      return false;
    }

    await _db.into(_db.milestonesTable).insertOnConflictUpdate(input.companion);
    return true;
  }

  Future<bool> _applyInterestRateHistory(FirestoreJson json) async {
    final input = FirestoreInterestRateHistorySerializer.fromFirestoreJson(
      json,
    );
    final local = await (_db.select(
      _db.interestRateHistoryTable,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();

    if (!_shouldApply(
      local?.updatedAt,
      input.updatedAt,
      local?.deletedAt,
      input.deletedAt,
    )) {
      return false;
    }

    await _db
        .into(_db.interestRateHistoryTable)
        .insertOnConflictUpdate(input.companion);
    return true;
  }

  Future<bool> _applyScenarioAssumption(FirestoreJson json) async {
    final input = FirestoreScenarioAssumptionSerializer.fromFirestoreJson(json);
    final local = await (_db.select(
      _db.scenarioAssumptionsTable,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();

    if (!_shouldApply(
      local?.updatedAt,
      input.updatedAt,
      local?.deletedAt,
      input.deletedAt,
    )) {
      return false;
    }

    await _db
        .into(_db.scenarioAssumptionsTable)
        .insertOnConflictUpdate(input.companion);
    return true;
  }

  bool _shouldApply(
    DateTime? localUpdatedAt,
    DateTime remoteUpdatedAt,
    DateTime? localDeletedAt,
    DateTime? remoteDeletedAt,
  ) {
    final decision = _conflictResolver.resolve(
      SyncConflictInput(
        localUpdatedAt: localUpdatedAt,
        remoteUpdatedAt: remoteUpdatedAt,
        localDeletedAt: localDeletedAt,
        remoteDeletedAt: remoteDeletedAt,
      ),
    );

    return decision == SyncConflictDecision.applyRemote;
  }
}
