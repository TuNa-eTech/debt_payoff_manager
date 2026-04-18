import 'package:drift/drift.dart';

import '../converters/datetime_converters.dart';

/// SyncState table — delta sync metadata.
///
/// Reference: data-schema.md §9
///
/// Local only, NOT synced to cloud. Tracks last sync timestamps
/// per table for delta sync with Firestore.
@DataClassName('SyncStateRow')
class SyncStateTable extends Table {
  @override
  String get tableName => 'sync_state';

  TextColumn get tableSyncName => text()();
  TextColumn get lastPulledAt =>
      text().nullable().map(const UtcDateTimeConverter())();
  TextColumn get lastPushedAt =>
      text().nullable().map(const UtcDateTimeConverter())();
  IntColumn get pendingWrites =>
      integer().withDefault(const Constant(0))();
  TextColumn get lastSyncError => text().nullable()();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {tableSyncName};
}
