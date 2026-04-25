import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_sync_config.dart';
import 'sync_auth_service.dart';

class DefaultFirebaseSyncInitializer implements FirebaseSyncInitializer {
  DefaultFirebaseSyncInitializer({
    required FirebaseSyncConfig config,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _config = config,
       _auth = auth,
       _firestore = firestore;

  final FirebaseSyncConfig _config;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  Future<void>? _initialization;

  @override
  Future<void> ensureReady() {
    return _initialization ??= _ensureReady();
  }

  Future<void> _ensureReady() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    if (!_config.useEmulators) return;

    (_firestore ?? FirebaseFirestore.instance).useFirestoreEmulator(
      _config.firestoreHost,
      _config.firestorePort,
    );
    await (_auth ?? FirebaseAuth.instance).useAuthEmulator(
      _config.authHost,
      _config.authPort,
    );
  }
}
