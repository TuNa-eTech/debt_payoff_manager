import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../sync/firebase_sync_config.dart';
import '../../../sync/sync_auth_service.dart';
import '../domain/sharing_models.dart';

abstract interface class SharingService {
  Future<SharingInviteResult> createInvite({
    required String scenarioId,
    required String partnerEmail,
    required SharingPermissionMode mode,
  });

  Future<AcceptSharingInviteResult> acceptInvite(String token);

  Future<void> revokePartner({
    required String shareId,
    required String partnerUid,
  });

  Future<void> leaveSharedPlan(String shareId);

  Future<void> logSharedPayment({
    required String shareId,
    required String debtId,
    required int amountCents,
    required DateTime date,
    String? note,
  });

  Stream<SharedPlan?> watchOwnerPlan({
    required String ownerUid,
    required String scenarioId,
  });

  Stream<List<SharedPlan>> watchPartnerPlans({required String partnerUid});

  Stream<SharedPlanSnapshot> watchSharedPlanSnapshot(SharedPlan plan);
}

class FirebaseSharingService implements SharingService {
  FirebaseSharingService({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
    required FirebaseSyncInitializer initializer,
    required FirebaseSyncConfig config,
  }) : _firestore = firestore,
       _functions = functions,
       _initializer = initializer,
       _config = config;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseSyncInitializer _initializer;
  final FirebaseSyncConfig _config;
  bool _functionsEmulatorConfigured = false;

  Future<void> _ensureReady() async {
    await _initializer.ensureReady();
    if (_config.useEmulators && !_functionsEmulatorConfigured) {
      _functions.useFunctionsEmulator(
        _config.functionsHost,
        _config.functionsPort,
      );
      _functionsEmulatorConfigured = true;
    }
  }

  @override
  Future<SharingInviteResult> createInvite({
    required String scenarioId,
    required String partnerEmail,
    required SharingPermissionMode mode,
  }) async {
    await _ensureReady();
    final result = await _functions.httpsCallable('createSharingInvite').call({
      'scenarioId': scenarioId,
      'partnerEmail': partnerEmail,
      'mode': mode.wireValue,
    });
    final data = _callableMap(result.data);
    return SharingInviteResult(
      shareId: _string(data, 'shareId'),
      inviteUrl: Uri.parse(_string(data, 'inviteUrl')),
      expiresAt: DateTime.parse(_string(data, 'expiresAt')).toUtc(),
    );
  }

  @override
  Future<AcceptSharingInviteResult> acceptInvite(String token) async {
    await _ensureReady();
    final result = await _functions.httpsCallable('acceptSharingInvite').call({
      'token': token,
    });
    final data = _callableMap(result.data);
    return AcceptSharingInviteResult(
      shareId: _string(data, 'shareId'),
      ownerUid: _string(data, 'ownerUid'),
      scenarioId: _string(data, 'scenarioId'),
      mode: SharingPermissionMode.fromWire(_string(data, 'mode')),
    );
  }

  @override
  Future<void> revokePartner({
    required String shareId,
    required String partnerUid,
  }) async {
    await _ensureReady();
    await _functions.httpsCallable('revokeSharingAccess').call({
      'shareId': shareId,
      'partnerUid': partnerUid,
    });
  }

  @override
  Future<void> leaveSharedPlan(String shareId) async {
    await _ensureReady();
    await _functions.httpsCallable('leaveSharedPlan').call({
      'shareId': shareId,
    });
  }

  @override
  Future<void> logSharedPayment({
    required String shareId,
    required String debtId,
    required int amountCents,
    required DateTime date,
    String? note,
  }) async {
    await _ensureReady();
    await _functions.httpsCallable('logSharedPayment').call({
      'shareId': shareId,
      'debtId': debtId,
      'amountCents': amountCents,
      'date': _dateToWire(date),
      'note': note,
    });
  }

  @override
  Stream<SharedPlan?> watchOwnerPlan({
    required String ownerUid,
    required String scenarioId,
  }) async* {
    await _ensureReady();
    final shareId = '${ownerUid}_$scenarioId';
    yield* _firestore.doc('sharedPlans/$shareId').snapshots().map((doc) {
      if (!doc.exists) return null;
      return _sharedPlanFromDoc(doc);
    });
  }

  @override
  Stream<List<SharedPlan>> watchPartnerPlans({
    required String partnerUid,
  }) async* {
    await _ensureReady();
    yield* _firestore
        .collection('sharedPlans')
        .where('partnerUids', arrayContains: partnerUid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(_sharedPlanFromDoc)
              .where((plan) => plan.isActive)
              .toList(),
        );
  }

  @override
  Stream<SharedPlanSnapshot> watchSharedPlanSnapshot(SharedPlan plan) async* {
    await _ensureReady();
    yield* _firestore
        .collection('users/${plan.ownerUid}/debts')
        .where('scenarioId', isEqualTo: plan.scenarioId)
        .snapshots()
        .map((snapshot) {
          final debts = snapshot.docs
              .map((doc) => _debtFromDoc(doc))
              .where((debt) => debt.status != 'archived')
              .toList();
          return SharedPlanSnapshot(sharedPlan: plan, debts: debts);
        });
  }

  SharedPlan _sharedPlanFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return SharedPlan(
      id: doc.id,
      ownerUid: _string(data, 'ownerUid'),
      scenarioId: _string(data, 'scenarioId'),
      mode: SharingPermissionMode.fromWire(_string(data, 'mode')),
      partnerUids: _stringList(data['partnerUids']),
      pendingInvites: _pendingInvites(data['pendingInvites']),
      createdAt: _timestamp(data['createdAt']),
      updatedAt: _timestamp(data['updatedAt']),
      revokedAt: _nullableTimestamp(data['revokedAt']),
    );
  }

  SharedDebtSnapshot _debtFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return SharedDebtSnapshot(
      id: doc.id,
      name: _string(data, 'name'),
      currentBalanceCents: _int(data, 'currentBalanceCents'),
      apr: _string(data, 'apr'),
      status: _string(data, 'status'),
    );
  }

  List<SharingInvite> _pendingInvites(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map((invite) {
          return SharingInvite(
            email: invite['email']?.toString() ?? '',
            createdAt: _timestamp(invite['createdAt']),
            expiresAt: _timestamp(invite['expiresAt']),
          );
        })
        .where((invite) => invite.email.isNotEmpty)
        .toList();
  }

  Map<String, Object?> _callableMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw StateError('Cloud Function returned an invalid payload.');
  }

  String _string(Map<dynamic, dynamic> data, String key) {
    final value = data[key];
    if (value is String) return value;
    throw StateError('Missing $key.');
  }

  int _int(Map<dynamic, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw StateError('Missing $key.');
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  DateTime _timestamp(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.parse(value).toUtc();
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  DateTime? _nullableTimestamp(Object? value) {
    if (value == null) return null;
    return _timestamp(value);
  }

  String _dateToWire(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }
}
