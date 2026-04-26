import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/tracked_settings_repository.dart';
import 'package:debt_payoff_manager/sync/firestore_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late SyncStateStore syncStateStore;
  late TrackedSettingsRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    syncStateStore = SyncStateStore(db: db);
    await db.seedFactoryDefaults();
    repo = TrackedSettingsRepository(
      base: SettingsRepositoryImpl(db: db),
      syncStateStore: syncStateStore,
    );
  });

  tearDown(() => db.close());

  test('updateSettings marks settings dirty', () async {
    final settings = makeRepoSettings();
    await repo.updateSettings(settings);

    final state = await syncStateStore.getState(
      FirestoreSyncCollection.settings.path,
    );
    expect(state?.pendingWrites, greaterThan(0));
  });

  test('getSettings delegates to base without marking dirty', () async {
    final settings = await repo.getSettings();
    expect(settings.id, 'singleton');

    final state = await syncStateStore.getState(
      FirestoreSyncCollection.settings.path,
    );
    expect(state?.pendingWrites ?? 0, 0);
  });

  test('watchSettings emits updated value after updateSettings', () async {
    final initial = await repo.getSettings();
    final updated = initial.copyWith(localeCode: 'vi-VN');

    // skip(1) skips the immediate current-value emission from Drift's watchSingle()
    final emitted = repo.watchSettings().skip(1).first;
    await repo.updateSettings(updated);

    expect((await emitted).localeCode, 'vi-VN');
  });
}
