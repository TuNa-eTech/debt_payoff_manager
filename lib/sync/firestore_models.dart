import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../data/local/database.dart';
import '../domain/enums/debt_status.dart';
import '../domain/enums/debt_type.dart';
import '../domain/enums/interest_method.dart';
import '../domain/enums/milestone_type.dart';
import '../domain/enums/min_payment_type.dart';
import '../domain/enums/payment_cadence.dart';
import '../domain/enums/payment_type.dart';
import '../domain/enums/strategy.dart';

typedef FirestoreJson = Map<String, Object?>;

const String firestoreDefaultScenarioId = 'main';
const String firestoreSettingsDocumentId = 'singleton';

enum FirestoreSyncCollection {
  debts('debts'),
  payments('payments'),
  plans('plans'),
  interestRateHistory('interestRateHistory'),
  milestones('milestones'),
  settings('settings'),
  scenarios('scenarios');

  const FirestoreSyncCollection(this.path);

  final String path;
}

class FirestorePaths {
  const FirestorePaths._();

  static String userRoot(String uid) => 'users/$uid';

  static String collectionPath(String uid, FirestoreSyncCollection collection) {
    return '${userRoot(uid)}/${collection.path}';
  }

  static String documentPath({
    required String uid,
    required FirestoreSyncCollection collection,
    required String documentId,
  }) {
    return '${collectionPath(uid, collection)}/$documentId';
  }

  static String syncMetaPath(String uid, String documentId) {
    return '${userRoot(uid)}/syncMeta/$documentId';
  }
}

class FirestoreSyncMetadata {
  const FirestoreSyncMetadata({
    required this.deviceId,
    required this.schemaVersion,
  });

  factory FirestoreSyncMetadata.fromJson(FirestoreJson json) {
    return FirestoreSyncMetadata(
      deviceId: _requiredString(json, '_deviceId'),
      schemaVersion: _requiredInt(json, '_schemaVersion'),
    );
  }

  final String deviceId;
  final int schemaVersion;

  FirestoreJson toJson() {
    return <String, Object?>{
      '_deviceId': deviceId,
      '_schemaVersion': schemaVersion,
    };
  }
}

class FirestoreMirrorInput<T> {
  const FirestoreMirrorInput({
    required this.companion,
    required this.id,
    required this.scenarioId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.metadata,
  });

  final T companion;
  final String id;
  final String scenarioId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final FirestoreSyncMetadata metadata;
}

class FirestoreMirrorDocument {
  const FirestoreMirrorDocument({
    required this.id,
    required this.scenarioId,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.metadata,
  });

  final String id;
  final String scenarioId;
  final FirestoreJson data;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final FirestoreSyncMetadata metadata;

  FirestoreJson toJson() {
    return _withMirrorFields(
      id: id,
      scenarioId: scenarioId,
      data: data,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      metadata: metadata,
    );
  }
}

class FirestoreDebtSerializer {
  const FirestoreDebtSerializer._();

  static FirestoreJson toFirestoreJson(
    DebtRow row,
    FirestoreSyncMetadata metadata,
  ) {
    return _withMirrorFields(
      id: row.id,
      scenarioId: row.scenarioId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      metadata: metadata,
      data: <String, Object?>{
        'name': row.name,
        'type': row.type.name,
        'originalPrincipalCents': row.originalPrincipalCents,
        'currentBalanceCents': row.currentBalanceCents,
        'apr': row.apr.toString(),
        'interestMethod': row.interestMethod.name,
        'minimumPaymentCents': row.minimumPaymentCents,
        'minimumPaymentType': row.minimumPaymentType.name,
        'minimumPaymentPercent': row.minimumPaymentPercent?.toString(),
        'minimumPaymentFloorCents': row.minimumPaymentFloorCents,
        'paymentCadence': row.paymentCadence.name,
        'dueDayOfMonth': row.dueDayOfMonth,
        'firstDueDate': _localDateToWire(row.firstDueDate),
        'status': row.status.name,
        'pausedUntil': _nullableLocalDateToWire(row.pausedUntil),
        'priority': row.priority,
        'excludeFromStrategy': row.excludeFromStrategy,
        'paidOffAt': row.paidOffAt?.toUtc(),
      },
    );
  }

  static FirestoreMirrorInput<DebtsTableCompanion> fromFirestoreJson(
    FirestoreJson json,
  ) {
    final input = _mirrorInput(
      json,
      DebtsTableCompanion(
        id: Value(_requiredString(json, 'id')),
        scenarioId: Value(_requiredString(json, 'scenarioId')),
        name: Value(_requiredString(json, 'name')),
        type: Value(_requiredEnum(DebtType.values, json, 'type')),
        originalPrincipalCents: Value(
          _requiredInt(json, 'originalPrincipalCents'),
        ),
        currentBalanceCents: Value(_requiredInt(json, 'currentBalanceCents')),
        apr: Value(_requiredDecimal(json, 'apr')),
        interestMethod: Value(
          _requiredEnum(InterestMethod.values, json, 'interestMethod'),
        ),
        minimumPaymentCents: Value(_requiredInt(json, 'minimumPaymentCents')),
        minimumPaymentType: Value(
          _requiredEnum(MinPaymentType.values, json, 'minimumPaymentType'),
        ),
        minimumPaymentPercent: Value(
          _nullableDecimal(json, 'minimumPaymentPercent'),
        ),
        minimumPaymentFloorCents: Value(
          _nullableInt(json, 'minimumPaymentFloorCents'),
        ),
        paymentCadence: Value(
          _requiredEnum(PaymentCadence.values, json, 'paymentCadence'),
        ),
        dueDayOfMonth: Value(_requiredInt(json, 'dueDayOfMonth')),
        firstDueDate: Value(_requiredLocalDate(json, 'firstDueDate')),
        status: Value(_requiredEnum(DebtStatus.values, json, 'status')),
        pausedUntil: Value(_nullableLocalDate(json, 'pausedUntil')),
        priority: Value(_nullableInt(json, 'priority')),
        excludeFromStrategy: Value(_requiredBool(json, 'excludeFromStrategy')),
        createdAt: Value(_requiredUtcTimestamp(json, 'createdAt')),
        updatedAt: Value(_requiredUtcTimestamp(json, 'updatedAt')),
        paidOffAt: Value(_nullableUtcTimestamp(json, 'paidOffAt')),
        deletedAt: Value(_nullableUtcTimestamp(json, 'deletedAt')),
      ),
    );
    return input;
  }
}

class FirestorePaymentSerializer {
  const FirestorePaymentSerializer._();

  static FirestoreJson toFirestoreJson(
    PaymentRow row,
    FirestoreSyncMetadata metadata,
  ) {
    return _withMirrorFields(
      id: row.id,
      scenarioId: row.scenarioId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      metadata: metadata,
      data: <String, Object?>{
        'debtId': row.debtId,
        'amountCents': row.amountCents,
        'principalPortionCents': row.principalPortionCents,
        'interestPortionCents': row.interestPortionCents,
        'feePortionCents': row.feePortionCents,
        'date': _localDateToWire(row.date),
        'type': row.type.name,
        'source': row.source.name,
        'note': row.note,
        'status': row.status.name,
        'appliedBalanceBeforeCents': row.appliedBalanceBeforeCents,
        'appliedBalanceAfterCents': row.appliedBalanceAfterCents,
      },
    );
  }

  static FirestoreMirrorInput<PaymentsTableCompanion> fromFirestoreJson(
    FirestoreJson json,
  ) {
    return _mirrorInput(
      json,
      PaymentsTableCompanion(
        id: Value(_requiredString(json, 'id')),
        scenarioId: Value(_requiredString(json, 'scenarioId')),
        debtId: Value(_requiredString(json, 'debtId')),
        amountCents: Value(_requiredInt(json, 'amountCents')),
        principalPortionCents: Value(
          _requiredInt(json, 'principalPortionCents'),
        ),
        interestPortionCents: Value(_requiredInt(json, 'interestPortionCents')),
        feePortionCents: Value(_requiredInt(json, 'feePortionCents')),
        date: Value(_requiredLocalDate(json, 'date')),
        type: Value(_requiredEnum(PaymentType.values, json, 'type')),
        source: Value(_requiredEnum(PaymentSource.values, json, 'source')),
        note: Value(_nullableString(json, 'note')),
        status: Value(_requiredEnum(PaymentStatus.values, json, 'status')),
        appliedBalanceBeforeCents: Value(
          _requiredInt(json, 'appliedBalanceBeforeCents'),
        ),
        appliedBalanceAfterCents: Value(
          _requiredInt(json, 'appliedBalanceAfterCents'),
        ),
        createdAt: Value(_requiredUtcTimestamp(json, 'createdAt')),
        updatedAt: Value(_requiredUtcTimestamp(json, 'updatedAt')),
        deletedAt: Value(_nullableUtcTimestamp(json, 'deletedAt')),
      ),
    );
  }
}

class FirestorePlanSerializer {
  const FirestorePlanSerializer._();

  static FirestoreJson toFirestoreJson(
    PlanRow row,
    FirestoreSyncMetadata metadata,
  ) {
    return _withMirrorFields(
      id: row.id,
      scenarioId: row.scenarioId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      metadata: metadata,
      data: <String, Object?>{
        'strategy': row.strategy.name,
        'extraMonthlyAmountCents': row.extraMonthlyAmountCents,
        'extraPaymentCadence': row.extraPaymentCadence.name,
        'customOrderJson': row.customOrderJson,
        'lastRecastAt': row.lastRecastAt.toUtc(),
        'projectedDebtFreeDate': _nullableLocalDateToWire(
          row.projectedDebtFreeDate,
        ),
        'totalInterestProjectedCents': row.totalInterestProjectedCents,
        'totalInterestSavedCents': row.totalInterestSavedCents,
      },
    );
  }

  static FirestoreMirrorInput<PlansTableCompanion> fromFirestoreJson(
    FirestoreJson json,
  ) {
    return _mirrorInput(
      json,
      PlansTableCompanion(
        id: Value(_requiredString(json, 'id')),
        scenarioId: Value(_requiredString(json, 'scenarioId')),
        strategy: Value(_requiredEnum(Strategy.values, json, 'strategy')),
        extraMonthlyAmountCents: Value(
          _requiredInt(json, 'extraMonthlyAmountCents'),
        ),
        extraPaymentCadence: Value(
          _requiredEnum(PaymentCadence.values, json, 'extraPaymentCadence'),
        ),
        customOrderJson: Value(_nullableString(json, 'customOrderJson')),
        lastRecastAt: Value(_requiredUtcTimestamp(json, 'lastRecastAt')),
        projectedDebtFreeDate: Value(
          _nullableLocalDate(json, 'projectedDebtFreeDate'),
        ),
        totalInterestProjectedCents: Value(
          _nullableInt(json, 'totalInterestProjectedCents'),
        ),
        totalInterestSavedCents: Value(
          _nullableInt(json, 'totalInterestSavedCents'),
        ),
        createdAt: Value(_requiredUtcTimestamp(json, 'createdAt')),
        updatedAt: Value(_requiredUtcTimestamp(json, 'updatedAt')),
        deletedAt: Value(_nullableUtcTimestamp(json, 'deletedAt')),
      ),
    );
  }
}

class FirestoreSettingsSerializer {
  const FirestoreSettingsSerializer._();

  static FirestoreJson toFirestoreJson(
    UserSettingsRow row,
    FirestoreSyncMetadata metadata, {
    String scenarioId = firestoreDefaultScenarioId,
    DateTime? deletedAt,
  }) {
    return _withMirrorFields(
      id: row.id,
      scenarioId: scenarioId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: deletedAt,
      metadata: metadata,
      data: <String, Object?>{
        'trustLevel': row.trustLevel,
        'firebaseUid': row.firebaseUid,
        'currencyCode': row.currencyCode,
        'localeCode': row.localeCode,
        'dayCountConvention': row.dayCountConvention,
        'notifPaymentReminder': row.notifPaymentReminder,
        'notifPaymentReminderDaysBefore': row.notifPaymentReminderDaysBefore,
        'notifMilestone': row.notifMilestone,
        'notifMonthlyLog': row.notifMonthlyLog,
        'onboardingStep': row.onboardingStep,
        'onboardingCompleted': row.onboardingCompleted,
        'onboardingCompletedAt': row.onboardingCompletedAt?.toUtc(),
        'isPremium': row.isPremium,
        'premiumExpiresAt': row.premiumExpiresAt?.toUtc(),
        'activeScenarioId': row.activeScenarioId,
      },
    );
  }

  static FirestoreMirrorInput<UserSettingsTableCompanion> fromFirestoreJson(
    FirestoreJson json,
  ) {
    return _mirrorInput(
      json,
      UserSettingsTableCompanion(
        id: Value(_requiredString(json, 'id')),
        trustLevel: Value(_requiredInt(json, 'trustLevel')),
        firebaseUid: Value(_nullableString(json, 'firebaseUid')),
        currencyCode: Value(_requiredString(json, 'currencyCode')),
        localeCode: Value(_requiredString(json, 'localeCode')),
        dayCountConvention: Value(_requiredString(json, 'dayCountConvention')),
        notifPaymentReminder: Value(
          _requiredBool(json, 'notifPaymentReminder'),
        ),
        notifPaymentReminderDaysBefore: Value(
          _requiredInt(json, 'notifPaymentReminderDaysBefore'),
        ),
        notifMilestone: Value(_requiredBool(json, 'notifMilestone')),
        notifMonthlyLog: Value(_requiredBool(json, 'notifMonthlyLog')),
        onboardingStep: Value(_requiredInt(json, 'onboardingStep')),
        onboardingCompleted: Value(_requiredBool(json, 'onboardingCompleted')),
        onboardingCompletedAt: Value(
          _nullableUtcTimestamp(json, 'onboardingCompletedAt'),
        ),
        isPremium: Value(_requiredBool(json, 'isPremium')),
        premiumExpiresAt: Value(
          _nullableUtcTimestamp(json, 'premiumExpiresAt'),
        ),
        activeScenarioId: Value(
          _nullableString(json, 'activeScenarioId') ?? firestoreDefaultScenarioId,
        ),
        createdAt: Value(_requiredUtcTimestamp(json, 'createdAt')),
        updatedAt: Value(_requiredUtcTimestamp(json, 'updatedAt')),
      ),
    );
  }
}

class FirestoreMilestoneSerializer {
  const FirestoreMilestoneSerializer._();

  static FirestoreJson toFirestoreJson(
    MilestoneRow row,
    FirestoreSyncMetadata metadata, {
    DateTime? updatedAt,
  }) {
    return _withMirrorFields(
      id: row.id,
      scenarioId: row.scenarioId,
      createdAt: row.createdAt,
      updatedAt: updatedAt ?? row.createdAt,
      deletedAt: row.deletedAt,
      metadata: metadata,
      data: <String, Object?>{
        'type': row.type.name,
        'debtId': row.debtId,
        'achievedAt': row.achievedAt.toUtc(),
        'seen': row.seen,
        'metadata': row.metadata,
      },
    );
  }

  static FirestoreMirrorInput<MilestonesTableCompanion> fromFirestoreJson(
    FirestoreJson json,
  ) {
    return _mirrorInput(
      json,
      MilestonesTableCompanion(
        id: Value(_requiredString(json, 'id')),
        scenarioId: Value(_requiredString(json, 'scenarioId')),
        type: Value(_requiredEnum(MilestoneType.values, json, 'type')),
        debtId: Value(_nullableString(json, 'debtId')),
        achievedAt: Value(_requiredUtcTimestamp(json, 'achievedAt')),
        seen: Value(_requiredBool(json, 'seen')),
        metadata: Value(_nullableString(json, 'metadata')),
        createdAt: Value(_requiredUtcTimestamp(json, 'createdAt')),
        deletedAt: Value(_nullableUtcTimestamp(json, 'deletedAt')),
      ),
    );
  }
}

class FirestoreScenarioSerializer {
  const FirestoreScenarioSerializer._();

  static FirestoreJson toFirestoreJson(
    ScenarioRow row,
    FirestoreSyncMetadata metadata, {
    DateTime? updatedAt,
  }) {
    return _withMirrorFields(
      id: row.id,
      scenarioId: row.id, // Scenario's own ID is its scenario ID context
      createdAt: row.createdAt,
      updatedAt: updatedAt ?? row.createdAt,
      deletedAt: row.deletedAt,
      metadata: metadata,
      data: <String, Object?>{
        'name': row.name,
        'isMain': row.isMain,
      },
    );
  }

  static FirestoreMirrorInput<ScenariosTableCompanion> fromFirestoreJson(
    FirestoreJson json,
  ) {
    return _mirrorInput(
      json,
      ScenariosTableCompanion(
        id: Value(_requiredString(json, 'id')),
        name: Value(_requiredString(json, 'name')),
        isMain: Value(_requiredBool(json, 'isMain')),
        createdAt: Value(_requiredUtcTimestamp(json, 'createdAt')),
        deletedAt: Value(_nullableUtcTimestamp(json, 'deletedAt')),
      ),
    );
  }
}

class FirestoreInterestRateHistorySerializer {
  const FirestoreInterestRateHistorySerializer._();

  static FirestoreJson toFirestoreJson(
    InterestRateHistoryRow row,
    FirestoreSyncMetadata metadata, {
    String scenarioId = firestoreDefaultScenarioId,
  }) {
    return _withMirrorFields(
      id: row.id,
      scenarioId: scenarioId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      metadata: metadata,
      data: <String, Object?>{
        'debtId': row.debtId,
        'apr': row.apr.toString(),
        'effectiveFrom': _localDateToWire(row.effectiveFrom),
        'effectiveTo': _nullableLocalDateToWire(row.effectiveTo),
        'reason': row.reason,
      },
    );
  }

  static FirestoreMirrorInput<InterestRateHistoryTableCompanion>
  fromFirestoreJson(FirestoreJson json) {
    return _mirrorInput(
      json,
      InterestRateHistoryTableCompanion(
        id: Value(_requiredString(json, 'id')),
        debtId: Value(_requiredString(json, 'debtId')),
        apr: Value(_requiredDecimal(json, 'apr')),
        effectiveFrom: Value(_requiredLocalDate(json, 'effectiveFrom')),
        effectiveTo: Value(_nullableLocalDate(json, 'effectiveTo')),
        reason: Value(_nullableString(json, 'reason')),
        createdAt: Value(_requiredUtcTimestamp(json, 'createdAt')),
        updatedAt: Value(_requiredUtcTimestamp(json, 'updatedAt')),
        deletedAt: Value(_nullableUtcTimestamp(json, 'deletedAt')),
      ),
    );
  }
}

FirestoreJson _withMirrorFields({
  required String id,
  required String scenarioId,
  required FirestoreJson data,
  required DateTime createdAt,
  required DateTime updatedAt,
  required DateTime? deletedAt,
  required FirestoreSyncMetadata metadata,
}) {
  return <String, Object?>{
    'id': id,
    'scenarioId': scenarioId,
    ...data,
    'createdAt': createdAt.toUtc(),
    'updatedAt': updatedAt.toUtc(),
    'deletedAt': deletedAt?.toUtc(),
    ...metadata.toJson(),
  };
}

FirestoreMirrorInput<T> _mirrorInput<T>(FirestoreJson json, T companion) {
  return FirestoreMirrorInput<T>(
    companion: companion,
    id: _requiredString(json, 'id'),
    scenarioId: _requiredString(json, 'scenarioId'),
    createdAt: _requiredUtcTimestamp(json, 'createdAt'),
    updatedAt: _requiredUtcTimestamp(json, 'updatedAt'),
    deletedAt: _nullableUtcTimestamp(json, 'deletedAt'),
    metadata: FirestoreSyncMetadata.fromJson(json),
  );
}

String _localDateToWire(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String? _nullableLocalDateToWire(DateTime? value) {
  return value == null ? null : _localDateToWire(value);
}

DateTime _requiredUtcTimestamp(FirestoreJson json, String key) {
  final value = json[key];
  if (value is DateTime) return value.toUtc();
  if (value is String) return DateTime.parse(value).toUtc();
  throw FormatException('Expected $key to be a DateTime or ISO-8601 string.');
}

DateTime? _nullableUtcTimestamp(FirestoreJson json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is DateTime) return value.toUtc();
  if (value is String) return DateTime.parse(value).toUtc();
  throw FormatException('Expected $key to be null, DateTime, or ISO-8601.');
}

DateTime _requiredLocalDate(FirestoreJson json, String key) {
  return DateTime.parse(_requiredString(json, key));
}

DateTime? _nullableLocalDate(FirestoreJson json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return DateTime.parse(value);
  throw FormatException('Expected $key to be null or YYYY-MM-DD string.');
}

Decimal _requiredDecimal(FirestoreJson json, String key) {
  return Decimal.parse(_requiredString(json, key));
}

Decimal? _nullableDecimal(FirestoreJson json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return Decimal.parse(value);
  throw FormatException('Expected $key to be null or decimal string.');
}

T _requiredEnum<T extends Enum>(
  Iterable<T> values,
  FirestoreJson json,
  String key,
) {
  final name = _requiredString(json, key);
  try {
    return values.byName(name);
  } on ArgumentError catch (error) {
    throw FormatException('Unknown $key enum value: $name', error);
  }
}

String _requiredString(FirestoreJson json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('Expected $key to be a string.');
}

String? _nullableString(FirestoreJson json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Expected $key to be null or string.');
}

int _requiredInt(FirestoreJson json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw FormatException('Expected $key to be an int.');
}

int? _nullableInt(FirestoreJson json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is int) return value;
  throw FormatException('Expected $key to be null or int.');
}

bool _requiredBool(FirestoreJson json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw FormatException('Expected $key to be a bool.');
}
