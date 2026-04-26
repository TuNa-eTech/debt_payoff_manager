import 'package:decimal/decimal.dart';
import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/domain/enums/debt_status.dart';
import 'package:debt_payoff_manager/domain/enums/debt_type.dart';
import 'package:debt_payoff_manager/domain/enums/interest_method.dart';
import 'package:debt_payoff_manager/domain/enums/milestone_type.dart';
import 'package:debt_payoff_manager/domain/enums/min_payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/payment_cadence.dart';
import 'package:debt_payoff_manager/domain/enums/payment_type.dart';
import 'package:debt_payoff_manager/domain/enums/strategy.dart';
import 'package:debt_payoff_manager/sync/firestore_models.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const metadata = FirestoreSyncMetadata(
    deviceId: 'ios-simulator',
    schemaVersion: 1,
  );
  final createdAt = DateTime.utc(2026, 4, 25, 10);
  final updatedAt = DateTime.utc(2026, 4, 26, 11, 30);

  group('FirestorePaths', () {
    test('builds user-owned collection and document paths', () {
      expect(FirestorePaths.userRoot('alice'), 'users/alice');
      expect(
        FirestorePaths.collectionPath('alice', FirestoreSyncCollection.debts),
        'users/alice/debts',
      );
      expect(
        FirestorePaths.documentPath(
          uid: 'alice',
          collection: FirestoreSyncCollection.payments,
          documentId: 'payment-1',
        ),
        'users/alice/payments/payment-1',
      );
      expect(
        FirestorePaths.syncMetaPath('alice', 'lastKnownState'),
        'users/alice/syncMeta/lastKnownState',
      );
    });
  });

  group('FirestoreMirrorDocument', () {
    test('adds sync metadata and UTC audit fields to payloads', () {
      final document = FirestoreMirrorDocument(
        id: 'debt-1',
        scenarioId: 'main',
        data: const <String, Object?>{'name': 'Card'},
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
        metadata: metadata,
      );

      expect(document.toJson(), <String, Object?>{
        'id': 'debt-1',
        'scenarioId': 'main',
        'name': 'Card',
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deletedAt': null,
        '_deviceId': 'ios-simulator',
        '_schemaVersion': 1,
      });
    });
  });

  group('FirestoreDebtSerializer', () {
    test('writes the debt mirror shape without losing precision', () {
      final row = DebtRow(
        id: 'debt-1',
        scenarioId: 'main',
        name: 'Chase Sapphire',
        type: DebtType.creditCard,
        originalPrincipalCents: 500000,
        currentBalanceCents: 423045,
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
        priority: 2,
        excludeFromStrategy: false,
        createdAt: createdAt,
        updatedAt: updatedAt,
        paidOffAt: null,
        deletedAt: null,
      );

      final json = FirestoreDebtSerializer.toFirestoreJson(row, metadata);

      expect(json['apr'], isA<String>());
      expect(json, <String, Object?>{
        'id': 'debt-1',
        'scenarioId': 'main',
        'name': 'Chase Sapphire',
        'type': 'creditCard',
        'originalPrincipalCents': 500000,
        'currentBalanceCents': 423045,
        'apr': '0.1899',
        'interestMethod': 'compoundDaily',
        'minimumPaymentCents': 2500,
        'minimumPaymentType': 'interestPlusPercent',
        'minimumPaymentPercent': '0.01',
        'minimumPaymentFloorCents': 2500,
        'paymentCadence': 'monthly',
        'dueDayOfMonth': 15,
        'firstDueDate': '2026-05-15',
        'status': 'active',
        'pausedUntil': null,
        'priority': 2,
        'excludeFromStrategy': false,
        'paidOffAt': null,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deletedAt': null,
        '_deviceId': 'ios-simulator',
        '_schemaVersion': 1,
      });
    });

    test('reads Firestore JSON into a Drift companion', () {
      final input = FirestoreDebtSerializer.fromFirestoreJson(<String, Object?>{
        'id': 'debt-1',
        'scenarioId': 'main',
        'name': 'Chase Sapphire',
        'type': 'creditCard',
        'originalPrincipalCents': 500000,
        'currentBalanceCents': 423045,
        'apr': '0.1899',
        'interestMethod': 'compoundDaily',
        'minimumPaymentCents': 2500,
        'minimumPaymentType': 'interestPlusPercent',
        'minimumPaymentPercent': '0.01',
        'minimumPaymentFloorCents': 2500,
        'paymentCadence': 'monthly',
        'dueDayOfMonth': 15,
        'firstDueDate': '2026-05-15',
        'status': 'active',
        'pausedUntil': null,
        'priority': 2,
        'excludeFromStrategy': false,
        'paidOffAt': null,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deletedAt': null,
        '_deviceId': 'ios-simulator',
        '_schemaVersion': 1,
      });

      final companion = input.companion;
      expect(input.id, 'debt-1');
      expect(input.metadata.deviceId, 'ios-simulator');
      expect(_value(companion.currentBalanceCents), 423045);
      expect(_value(companion.apr).toString(), '0.1899');
      expect(_value(companion.firstDueDate), DateTime(2026, 5, 15));
      expect(_value(companion.type), DebtType.creditCard);
      expect(_value(companion.pausedUntil), isNull);
      expect(_value(companion.paidOffAt), isNull);
      expect(_value(companion.deletedAt), isNull);
    });
  });

  group('FirestorePaymentSerializer', () {
    test('round-trips payment cents, split, local date, and nullable note', () {
      final row = PaymentRow(
        id: 'payment-1',
        scenarioId: 'main',
        debtId: 'debt-1',
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
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );

      final json = FirestorePaymentSerializer.toFirestoreJson(row, metadata);
      expect(json['date'], '2026-04-25');
      expect(json['note'], isNull);
      expect(json['amountCents'], 12000);
      expect(json['principalPortionCents'], 10000);
      expect(json['interestPortionCents'], 2000);
      expect(json['feePortionCents'], 0);

      final companion = FirestorePaymentSerializer.fromFirestoreJson(
        json,
      ).companion;
      expect(_value(companion.date), DateTime(2026, 4, 25));
      expect(_value(companion.note), isNull);
      expect(_value(companion.type), PaymentType.extra);
      expect(_value(companion.status), PaymentStatus.completed);
      expect(_value(companion.amountCents), 12000);
    });
  });

  group('FirestorePlanSerializer', () {
    test('round-trips plan compute cache and nullable custom order', () {
      final row = PlanRow(
        id: 'plan-1',
        scenarioId: 'main',
        strategy: Strategy.avalanche,
        extraMonthlyAmountCents: 35000,
        extraPaymentCadence: PaymentCadence.monthly,
        customOrderJson: null,
        lastRecastAt: updatedAt,
        projectedDebtFreeDate: DateTime(2027, 12, 31),
        totalInterestProjectedCents: 85000,
        totalInterestSavedCents: 15000,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );

      final json = FirestorePlanSerializer.toFirestoreJson(row, metadata);
      expect(json['customOrderJson'], isNull);
      expect(json['lastRecastAt'], updatedAt);
      expect(json['projectedDebtFreeDate'], '2027-12-31');

      final companion = FirestorePlanSerializer.fromFirestoreJson(
        json,
      ).companion;
      expect(_value(companion.strategy), Strategy.avalanche);
      expect(_value(companion.extraMonthlyAmountCents), 35000);
      expect(_value(companion.customOrderJson), isNull);
      expect(_value(companion.projectedDebtFreeDate), DateTime(2027, 12, 31));
    });
  });

  group('FirestoreSettingsSerializer', () {
    test('round-trips singleton settings and nullable premium expiry', () {
      final row = UserSettingsRow(
        id: 'singleton',
        trustLevel: 1,
        firebaseUid: 'alice',
        currencyCode: 'USD',
        localeCode: 'en-US',
        dayCountConvention: 'actual365',
        notifPaymentReminder: true,
        notifPaymentReminderDaysBefore: 7,
        notifMilestone: false,
        notifMonthlyLog: true,
        onboardingStep: 5,
        onboardingCompleted: true,
        onboardingCompletedAt: updatedAt,
        activeScenarioId: 'main',
        isPremium: false,
        premiumExpiresAt: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final json = FirestoreSettingsSerializer.toFirestoreJson(row, metadata);
      expect(json['id'], firestoreSettingsDocumentId);
      expect(json['scenarioId'], firestoreDefaultScenarioId);
      expect(json['premiumExpiresAt'], isNull);
      expect(json['deletedAt'], isNull);

      final input = FirestoreSettingsSerializer.fromFirestoreJson(json);
      final companion = input.companion;
      expect(input.scenarioId, firestoreDefaultScenarioId);
      expect(_value(companion.id), firestoreSettingsDocumentId);
      expect(_value(companion.firebaseUid), 'alice');
      expect(_value(companion.notifPaymentReminderDaysBefore), 7);
      expect(_value(companion.onboardingCompletedAt), updatedAt);
      expect(_value(companion.premiumExpiresAt), isNull);
    });
  });

  group('FirestoreMilestoneSerializer', () {
    test('round-trips milestone metadata and derived updatedAt', () {
      final row = MilestoneRow(
        id: 'milestone-1',
        scenarioId: 'main',
        type: MilestoneType.firstPayment,
        debtId: null,
        achievedAt: updatedAt,
        seen: true,
        metadata: '{"savedAmountCents":1200}',
        createdAt: createdAt,
        deletedAt: null,
      );

      final json = FirestoreMilestoneSerializer.toFirestoreJson(row, metadata);
      expect(json['updatedAt'], createdAt);
      expect(json['debtId'], isNull);
      expect(json['metadata'], '{"savedAmountCents":1200}');

      final input = FirestoreMilestoneSerializer.fromFirestoreJson(json);
      final companion = input.companion;
      expect(input.updatedAt, createdAt);
      expect(_value(companion.type), MilestoneType.firstPayment);
      expect(_value(companion.debtId), isNull);
      expect(_value(companion.metadata), '{"savedAmountCents":1200}');
    });
  });

  group('FirestoreInterestRateHistorySerializer', () {
    test('round-trips APR as string and local effective dates', () {
      final row = InterestRateHistoryRow(
        id: 'rate-1',
        debtId: 'debt-1',
        apr: Decimal.parse('0.2499'),
        effectiveFrom: DateTime(2026, 1),
        effectiveTo: null,
        reason: 'promo-ended',
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );

      final json = FirestoreInterestRateHistorySerializer.toFirestoreJson(
        row,
        metadata,
      );
      expect(json['scenarioId'], firestoreDefaultScenarioId);
      expect(json['apr'], '0.2499');
      expect(json['apr'], isA<String>());
      expect(json['effectiveFrom'], '2026-01-01');
      expect(json['effectiveTo'], isNull);

      final input = FirestoreInterestRateHistorySerializer.fromFirestoreJson(
        json,
      );
      final companion = input.companion;
      expect(input.scenarioId, firestoreDefaultScenarioId);
      expect(_value(companion.apr).toString(), '0.2499');
      expect(_value(companion.effectiveFrom), DateTime(2026, 1));
      expect(_value(companion.effectiveTo), isNull);
      expect(_value(companion.reason), 'promo-ended');
    });
  });
}

T _value<T>(Value<T> value) {
  expect(value.present, isTrue);
  return value.value;
}
