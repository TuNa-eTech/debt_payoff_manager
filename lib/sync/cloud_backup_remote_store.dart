import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_models.dart';
import 'sync_auth_service.dart';

abstract interface class CloudBackupRemoteStore {
  Future<void> deleteUserMirrorData(String uid);
}

class FirestoreCloudBackupRemoteStore implements CloudBackupRemoteStore {
  FirestoreCloudBackupRemoteStore({
    required FirebaseFirestore firestore,
    required FirebaseSyncInitializer initializer,
  }) : _firestore = firestore,
       _initializer = initializer;

  static const int _maxDeletesPerBatch = 500;

  final FirebaseFirestore _firestore;
  final FirebaseSyncInitializer _initializer;

  @override
  Future<void> deleteUserMirrorData(String uid) async {
    await _initializer.ensureReady();
    await _deleteOwnedSharedPlans(uid);
    for (final collection in FirestoreSyncCollection.values) {
      await _deleteCollection(FirestorePaths.collectionPath(uid, collection));
    }
    await _deleteCollection('${FirestorePaths.userRoot(uid)}/syncMeta');
    await _firestore.doc(FirestorePaths.userRoot(uid)).delete();
  }

  Future<void> _deleteOwnedSharedPlans(String uid) async {
    while (true) {
      final snapshot = await _firestore
          .collection('sharedPlans')
          .where('ownerUid', isEqualTo: uid)
          .limit(_maxDeletesPerBatch)
          .get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < _maxDeletesPerBatch) return;
    }
  }

  Future<void> _deleteCollection(String path) async {
    while (true) {
      final snapshot = await _firestore
          .collection(path)
          .limit(_maxDeletesPerBatch)
          .get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < _maxDeletesPerBatch) return;
    }
  }
}
