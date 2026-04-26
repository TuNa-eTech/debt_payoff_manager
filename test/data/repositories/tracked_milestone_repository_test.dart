import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/data/repositories/milestone_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/tracked_milestone_repository.dart';
import 'package:debt_payoff_manager/sync/firestore_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late SyncStateStore syncStateStore;
  late TrackedMilestoneRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    syncStateStore = SyncStateStore(db: db);
    await db.seedFactoryDefaults();
    repo = TrackedMilestoneRepository(
      base: MilestoneRepositoryImpl(db: db),
      syncStateStore: syncStateStore,
    );
  });

  tearDown(() => db.close());

  test('addMilestone marks milestones dirty', () async {
    await repo.addMilestone(makeRepoMilestone());

    final state = await syncStateStore.getState(
      FirestoreSyncCollection.milestones.path,
    );
    expect(state?.pendingWrites, greaterThan(0));
  });

  test('read methods do not mark dirty', () async {
    await repo.getUnseenMilestones();
    await repo.getMilestonesForDebt('debt-1');

    final state = await syncStateStore.getState(
      FirestoreSyncCollection.milestones.path,
    );
    expect(state?.pendingWrites ?? 0, 0);
  });

  test('markSeen does not mark dirty (read-side bookkeeping only)', () async {
    final milestone = await repo.addMilestone(makeRepoMilestone());
    // Reset dirty count after add
    await syncStateStore.markPushed(
      FirestoreSyncCollection.milestones.path,
      pushedAt: DateTime.now().toUtc(),
    );

    await repo.markSeen(milestone.id);

    final state = await syncStateStore.getState(
      FirestoreSyncCollection.milestones.path,
    );
    expect(state?.pendingWrites ?? 0, 0);
  });
}
