import 'package:drift/drift.dart';

import '../database.dart';

/// Local helper for sync_state bookkeeping.
class SyncStateStore {
  SyncStateStore({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Future<SyncStateRow?> getState(String tableName) {
    return (_db.select(_db.syncStateTable)
          ..where((row) => row.tableSyncName.equals(tableName)))
        .getSingleOrNull();
  }

  Stream<List<SyncStateRow>> watchAllStates() {
    return (_db.select(_db.syncStateTable)
          ..orderBy([(row) => OrderingTerm.asc(row.tableSyncName)]))
        .watch();
  }

  Future<void> markDirty(String tableName) async {
    final now = DateTime.now().toUtc();
    final current = await getState(tableName);

    if (current == null) {
      await _db.into(_db.syncStateTable).insert(
            SyncStateTableCompanion.insert(
              tableSyncName: tableName,
              pendingWrites: const Value(1),
              updatedAt: now,
            ),
          );
      return;
    }

    await (_db.update(_db.syncStateTable)
          ..where((row) => row.tableSyncName.equals(tableName)))
        .write(
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
}
