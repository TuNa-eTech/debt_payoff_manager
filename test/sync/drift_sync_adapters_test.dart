import 'package:decimal/decimal.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/local/stores/sync_state_store.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/domain/enums/interest_method.dart';
import 'package:debt_payoff_manager/domain/enums/milestone_type.dart';
import 'package:debt_payoff_manager/domain/enums/min_payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/payment_cadence.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';
import 'package:debt_payoff_manager/sync/firestore_models.dart';
import 'package:debt_payoff_manager/sync/pull_listener.dart';
import 'package:debt_payoff_manager/sync/push_queue.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SyncStateStore syncStateStore;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    syncStateStore = SyncStateStore(db: db);
    await db.seedFactoryDefaults();
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftSyncPushQueue', () {
    test('serializes local mirror rows and clears pushed state', () async {
      await _insertDebt(
        db,
        id: 'debt-1',
        currentBalanceCents: 423045,
        updatedAt: DateTime.utc(2026, 4, 25),
      );

      final queue = DriftSyncPushQueue(
        db: db,
        syncStateStore: syncStateStore,
        deviceId: 'ios-simulator',
      );

      final batch = await queue.collectPendingWrites(uid: 'alice');
      final debtEntry = batch.entries.singleWhere(
        (entry) =>
            entry.collection == FirestoreSyncCollection.debts &&
            entry.documentId == 'debt-1',
      );

      expect(debtEntry.data['currentBalanceCents'], 423045);
      expect(debtEntry.data['apr'], '0.1899');
      expect(debtEntry.data['_deviceId'], 'ios-simulator');
      expect(debtEntry.data['_schemaVersion'], 1);

      await queue.markPushed(
        batch: batch,
        pushedAt: DateTime.now().toUtc().add(const Duration(days: 1)),
      );

      final afterMark = await queue.collectPendingWrites(uid: 'alice');
      expect(afterMark.entries, isEmpty);
      expect(
        (await syncStateStore.getState(
          FirestoreSyncCollection.debts.path,
        ))?.pendingWrites,
        0,
      );
    });

    test(
      'pushes dirty milestone rows even though the table has no updatedAt',
      () async {
        await db
            .into(db.milestonesTable)
            .insert(
              MilestonesTableCompanion.insert(
                id: const Value('milestone-1'),
                scenarioId: const Value('main'),
                type: MilestoneType.firstPayment,
                achievedAt: DateTime.utc(2026, 1),
                seen: const Value(false),
                createdAt: DateTime.utc(2026, 1),
              ),
            );
        await syncStateStore.markPushed(
          FirestoreSyncCollection.milestones.path,
          pushedAt: DateTime.utc(2026, 4, 25),
        );
        await syncStateStore.markDirty(FirestoreSyncCollection.milestones.path);

        final queue = DriftSyncPushQueue(
          db: db,
          syncStateStore: syncStateStore,
          deviceId: 'ios-simulator',
        );

        final batch = await queue.collectPendingWrites(uid: 'alice');

        expect(
          batch.entries.where(
            (entry) => entry.collection == FirestoreSyncCollection.milestones,
          ),
          hasLength(1),
        );
      },
    );
  });

  group('DriftSyncPullApplier', () {
    test('applies newer remote rows and keeps newer local rows', () async {
      await _insertDebt(
        db,
        id: 'debt-1',
        currentBalanceCents: 500000,
        updatedAt: DateTime.utc(2026, 4, 25),
      );
      final applier = DriftSyncPullApplier(
        db: db,
        syncStateStore: syncStateStore,
      );

      await applier.applyChangeSet(
        PullChangeSet(
          uid: 'alice',
          changes: [
            PullChange(
              collection: FirestoreSyncCollection.debts,
              documentId: 'debt-1',
              type: PullChangeType.modified,
              data: FirestoreDebtSerializer.toFirestoreJson(
                _debtRow(
                  id: 'debt-1',
                  currentBalanceCents: 400000,
                  updatedAt: DateTime.utc(2026, 4, 26),
                ),
                const FirestoreSyncMetadata(
                  deviceId: 'android-phone',
                  schemaVersion: 1,
                ),
              ),
            ),
          ],
        ),
      );

      expect((await _getDebt(db, 'debt-1')).currentBalanceCents, 400000);
      expect(
        (await syncStateStore.getState(
          FirestoreSyncCollection.debts.path,
        ))?.lastPulledAt,
        isNotNull,
      );

      await applier.applyChangeSet(
        PullChangeSet(
          uid: 'alice',
          changes: [
            PullChange(
              collection: FirestoreSyncCollection.debts,
              documentId: 'debt-1',
              type: PullChangeType.modified,
              data: FirestoreDebtSerializer.toFirestoreJson(
                _debtRow(
                  id: 'debt-1',
                  currentBalanceCents: 300000,
                  updatedAt: DateTime.utc(2026, 4, 24),
                ),
                const FirestoreSyncMetadata(
                  deviceId: 'android-phone',
                  schemaVersion: 1,
                ),
              ),
            ),
          ],
        ),
      );

      expect((await _getDebt(db, 'debt-1')).currentBalanceCents, 400000);
    });

    test(
      'orders dependent remote debt and payment changes before upsert',
      () async {
        final applier = DriftSyncPullApplier(
          db: db,
          syncStateStore: syncStateStore,
        );
        const metadata = FirestoreSyncMetadata(
          deviceId: 'android-phone',
          schemaVersion: 1,
        );

        await applier.applyChangeSet(
          PullChangeSet(
            uid: 'alice',
            changes: [
              PullChange(
                collection: FirestoreSyncCollection.payments,
                documentId: 'payment-1',
                type: PullChangeType.added,
                data: FirestorePaymentSerializer.toFirestoreJson(
                  PaymentRow(
                    id: 'payment-1',
                    scenarioId: 'main',
                    debtId: 'remote-debt',
                    amountCents: 12000,
                    principalPortionCents: 10000,
                    interestPortionCents: 2000,
                    feePortionCents: 0,
                    date: DateTime(2026, 4, 25),
                    type: PaymentType.extra,
                    source: PaymentSource.manual,
                    note: null,
                    status: PaymentStatus.completed,
                    appliedBalanceBeforeCents: 423045,
                    appliedBalanceAfterCents: 413045,
                    createdAt: DateTime.utc(2026, 4, 25),
                    updatedAt: DateTime.utc(2026, 4, 25),
                    deletedAt: null,
                  ),
                  metadata,
                ),
              ),
              PullChange(
                collection: FirestoreSyncCollection.debts,
                documentId: 'remote-debt',
                type: PullChangeType.added,
                data: FirestoreDebtSerializer.toFirestoreJson(
                  _debtRow(
                    id: 'remote-debt',
                    currentBalanceCents: 423045,
                    updatedAt: DateTime.utc(2026, 4, 25),
                  ),
                  metadata,
                ),
              ),
            ],
          ),
        );

        expect((await _getDebt(db, 'remote-debt')).id, 'remote-debt');
        final payment = await (db.select(
          db.paymentsTable,
        )..where((row) => row.id.equals('payment-1'))).getSingle();
        expect(payment.debtId, 'remote-debt');
      },
    );
  });
}

Future<DebtRow> _getDebt(AppDatabase db, String id) {
  return (db.select(
    db.debtsTable,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<void> _insertDebt(
  AppDatabase db, {
  required String id,
  required int currentBalanceCents,
  required DateTime updatedAt,
}) {
  return db
      .into(db.debtsTable)
      .insert(
        DebtsTableCompanion.insert(
          id: Value(id),
          scenarioId: const Value('main'),
          name: 'Chase Sapphire',
          type: DebtType.creditCard,
          originalPrincipalCents: 500000,
          currentBalanceCents: currentBalanceCents,
          apr: Decimal.parse('0.1899'),
          interestMethod: InterestMethod.compoundDaily,
          minimumPaymentCents: const Value(2500),
          minimumPaymentType: MinPaymentType.interestPlusPercent,
          minimumPaymentPercent: Value(Decimal.parse('0.01')),
          minimumPaymentFloorCents: const Value(2500),
          paymentCadence: PaymentCadence.monthly,
          dueDayOfMonth: 15,
          firstDueDate: DateTime(2026, 5, 15),
          status: DebtStatus.active,
          excludeFromStrategy: const Value(false),
          createdAt: DateTime.utc(2026, 4, 25),
          updatedAt: updatedAt,
        ),
      );
}

DebtRow _debtRow({
  required String id,
  required int currentBalanceCents,
  required DateTime updatedAt,
}) {
  return DebtRow(
    id: id,
    scenarioId: 'main',
    name: 'Chase Sapphire',
    type: DebtType.creditCard,
    originalPrincipalCents: 500000,
    currentBalanceCents: currentBalanceCents,
    apr: Decimal.parse('0.1899'),
    interestMethod: InterestMethod.compoundDaily,
    minimumPaymentCents: 2500,
    minimumPaymentType: MinPaymentType.interestPlusPercent,
    minimumPaymentPercent: Decimal.parse('0.01'),
    minimumPaymentFloorCents: 2500,
    paymentCadence: PaymentCadence.monthly,
    dueDayOfMonth: 15,
    firstDueDate: DateTime(2026, 5, 15),
    status: DebtStatus.active,
    pausedUntil: null,
    priority: null,
    excludeFromStrategy: false,
    createdAt: DateTime.utc(2026, 4, 25),
    updatedAt: updatedAt,
    paidOffAt: null,
    deletedAt: null,
  );
}
