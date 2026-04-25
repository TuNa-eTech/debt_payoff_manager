import 'package:drift/drift.dart';

import '../database.dart';

/// Local helper for sync_state bookkeeping.
class SyncStateStore {
  SyncStateStore({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Future<SyncStateRow?> getState(String tableName) {
    return (_db.select(
      _db.syncStateTable,
    )..where((row) => row.tableSyncName.equals(tableName))).getSingleOrNull();
  }

  Stream<List<SyncStateRow>> watchAllStates() {
    return (_db.select(
      _db.syncStateTable,
    )..orderBy([(row) => OrderingTerm.asc(row.tableSyncName)])).watch();
  }

  Future<void> markDirty(String tableName) async {
    final now = DateTime.now().toUtc();
    final current = await getState(tableName);

    if (current == null) {
      await _db
          .into(_db.syncStateTable)
          .insert(
            SyncStateTableCompanion.insert(
              tableSyncName: tableName,
              pendingWrites: const Value(1),
              updatedAt: now,
            ),
          );
      return;
    }

    await (_db.update(
      _db.syncStateTable,
    )..where((row) => row.tableSyncName.equals(tableName))).write(
      SyncStateTableCompanion(
        pendingWrites: Value(current.pendingWrites + 1),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markDirtyMany(Iterable<String> tableNames) async {
    for (final tableName in tableNames.toSet()) {
      await markDirty(tableName);
    }
  }

  Future<void> markPushed(String tableName, {required DateTime pushedAt}) {
    return _upsertState(
      tableName,
      SyncStateTableCompanion(
        lastPushedAt: Value(pushedAt.toUtc()),
        pendingWrites: const Value(0),
        lastSyncError: const Value(null),
      ),
    );
  }

  Future<void> markPulled(String tableName, {required DateTime pulledAt}) {
    return _upsertState(
      tableName,
      SyncStateTableCompanion(
        lastPulledAt: Value(pulledAt.toUtc()),
        lastSyncError: const Value(null),
      ),
    );
  }

  Future<void> markError(String tableName, Object error) {
    return _upsertState(
      tableName,
      SyncStateTableCompanion(lastSyncError: Value(error.toString())),
    );
  }

  Future<void> _upsertState(
    String tableName,
    SyncStateTableCompanion changes,
  ) async {
    final now = DateTime.now().toUtc();
    final current = await getState(tableName);

    if (current == null) {
      await _db
          .into(_db.syncStateTable)
          .insert(
            SyncStateTableCompanion.insert(
              tableSyncName: tableName,
              lastPulledAt: changes.lastPulledAt.present
                  ? Value(changes.lastPulledAt.value)
                  : const Value.absent(),
              lastPushedAt: changes.lastPushedAt.present
                  ? Value(changes.lastPushedAt.value)
                  : const Value.absent(),
              pendingWrites: changes.pendingWrites.present
                  ? Value(changes.pendingWrites.value)
                  : const Value(0),
              lastSyncError: changes.lastSyncError.present
                  ? Value(changes.lastSyncError.value)
                  : const Value.absent(),
              updatedAt: now,
            ),
          );
      return;
    }

    await (_db.update(_db.syncStateTable)
          ..where((row) => row.tableSyncName.equals(tableName)))
        .write(changes.copyWith(updatedAt: Value(now)));
  }
}
