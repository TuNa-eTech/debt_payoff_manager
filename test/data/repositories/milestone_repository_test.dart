import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/milestone_repository_impl.dart';
import 'package:debt_payoff_manager/domain/enums/milestone_type.dart';

import 'repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DebtRepositoryImpl debtRepo;
  late MilestoneRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    debtRepo = DebtRepositoryImpl(db: db);
    repo = MilestoneRepositoryImpl(db: db);
    await debtRepo.addDebt(makeRepoDebt());
  });

  tearDown(() async {
    await db.close();
  });

  group('MilestoneRepositoryImpl', () {
    test(
      'addMilestone inserts and returns unseen milestones ordered newest first',
      () async {
        await repo.addMilestone(
          makeRepoMilestone(
            id: 'older',
            debtId: 'debt-1',
            type: MilestoneType.percentComplete25,
            achievedAt: DateTime.utc(2026, 1, 10),
          ),
        );
        await repo.addMilestone(
          makeRepoMilestone(
            id: 'newer',
            debtId: 'debt-1',
            type: MilestoneType.percentComplete50,
            achievedAt: DateTime.utc(2026, 2, 10),
          ),
        );

        final unseen = await repo.getUnseenMilestones();

        expect(unseen.map((milestone) => milestone.id), ['newer', 'older']);
      },
    );

    test(
      'getMilestonesForDebt returns only matching debt milestones',
      () async {
        await debtRepo.addDebt(makeRepoDebt(id: 'debt-2'));
        await repo.addMilestone(
          makeRepoMilestone(
            id: 'for-debt-1',
            debtId: 'debt-1',
            type: MilestoneType.percentComplete25,
          ),
        );
        await repo.addMilestone(
          makeRepoMilestone(
            id: 'for-debt-2',
            debtId: 'debt-2',
            type: MilestoneType.percentComplete50,
          ),
        );

        final milestones = await repo.getMilestonesForDebt('debt-1');

        expect(milestones.map((milestone) => milestone.id), ['for-debt-1']);
      },
    );

    test('markSeen removes milestone from unseen list', () async {
      await repo.addMilestone(
        makeRepoMilestone(id: 'seen-me', debtId: 'debt-1'),
      );

      await repo.markSeen('seen-me');

      expect(await repo.getUnseenMilestones(), isEmpty);
    });

    test(
      'milestoneExists handles debt-specific and global milestones',
      () async {
        await repo.addMilestone(
          makeRepoMilestone(
            id: 'global',
            debtId: null,
            type: MilestoneType.allDebtFree,
          ),
        );
        await repo.addMilestone(
          makeRepoMilestone(
            id: 'debt-specific',
            debtId: 'debt-1',
            type: MilestoneType.firstPayment,
          ),
        );

        expect(await repo.milestoneExists(MilestoneType.allDebtFree), isTrue);
        expect(
          await repo.milestoneExists(
            MilestoneType.firstPayment,
            debtId: 'debt-1',
          ),
          isTrue,
        );
        expect(
          await repo.milestoneExists(
            MilestoneType.firstPayment,
            debtId: 'missing-debt',
          ),
          isFalse,
        );
      },
    );

    test('duplicate milestone type for the same debt is rejected', () async {
      await repo.addMilestone(
        makeRepoMilestone(
          id: 'first',
          debtId: 'debt-1',
          type: MilestoneType.firstPayment,
        ),
      );

      expect(
        () => repo.addMilestone(
          makeRepoMilestone(
            id: 'duplicate',
            debtId: 'debt-1',
            type: MilestoneType.firstPayment,
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('watchUnseenMilestones emits updates', () async {
      final stream = repo.watchUnseenMilestones();

      await expectLater(stream, emits(isEmpty));

      await repo.addMilestone(
        makeRepoMilestone(id: 'watched', debtId: 'debt-1'),
      );

      await expectLater(
        stream,
        emits(predicate<List<dynamic>>((milestones) => milestones.length == 1)),
      );
    });

    test('round-trip preserves metadata and seen flag', () async {
      final milestone = makeRepoMilestone(
        id: 'round-trip',
        debtId: 'debt-1',
        type: MilestoneType.interestSaved1000,
        metadata: '{"savedAmount": 100000, "months": 6}',
      );

      await repo.addMilestone(milestone);
      await repo.markSeen('round-trip');

      final raw = await (db.select(
        db.milestonesTable,
      )..where((row) => row.id.equals('round-trip'))).getSingle();

      expect(raw.metadata, milestone.metadata);
      expect(raw.seen, isTrue);
    });
  });
}
