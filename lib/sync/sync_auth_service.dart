import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SyncAuthAccount {
  const SyncAuthAccount({
    required this.uid,
    required this.providerId,
    this.email,
    this.displayName,
  });

  final String uid;
  final String providerId;
  final String? email;
  final String? displayName;
}

class SyncAuthCancelledException implements Exception {
  const SyncAuthCancelledException([this.message = 'Sign-in was cancelled.']);

  final String message;

  @override
  String toString() => message;
}

abstract interface class SyncAuthService {
  Future<SyncAuthAccount?> currentAccount();

  Future<SyncAuthAccount> signInWithGoogle();

  Future<SyncAuthAccount> signInWithApple();

  Future<void> signOut();
}

abstract interface class FirebaseSyncInitializer {
  Future<void> ensureReady();
}

class FirebaseSyncAuthService implements SyncAuthService {
  FirebaseSyncAuthService({
    required FirebaseAuth auth,
    required FirebaseSyncInitializer initializer,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth,
       _initializer = initializer,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseSyncInitializer _initializer;
  final GoogleSignIn _googleSignIn;

  Future<void>? _googleInitialization;

  @override
  Future<SyncAuthAccount?> currentAccount() async {
    await _initializer.ensureReady();
    final user = _auth.currentUser;
    if (user == null) return null;
    return _toAccount(user);
  }

  @override
  Future<SyncAuthAccount> signInWithGoogle() async {
    await _initializer.ensureReady();
    await _ensureGoogleInitialized();

    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError('Google sign-in is not available here.');
      }

      final googleUser = await _googleSignIn.authenticate(
        scopeHint: const <String>['email'],
      );
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google sign-in did not return an ID token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw StateError('Google sign-in did not return a Firebase user.');
      }
      return _toAccount(
        user,
        fallbackProviderId: GoogleAuthProvider.PROVIDER_ID,
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SyncAuthCancelledException();
      }
      rethrow;
    }
  }

  @override
  Future<SyncAuthAccount> signInWithApple() async {
    await _initializer.ensureReady();

    final rawNonce = _generateNonce();
    final hashedNonce = _sha256(rawNonce);
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = appleCredential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Apple sign-in did not return an identity token.');
      }

      final credential = AppleAuthProvider.credentialWithIDToken(
        idToken,
        rawNonce,
        AppleFullPersonName(
          givenName: appleCredential.givenName,
          familyName: appleCredential.familyName,
        ),
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw StateError('Apple sign-in did not return a Firebase user.');
      }
      return _toAccount(
        user,
        fallbackProviderId: AppleAuthProvider.PROVIDER_ID,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SyncAuthCancelledException();
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _initializer.ensureReady();
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } on Object {
      // Firebase sign-out is the source of truth for Firestore rules.
    }
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInitialization ??= _googleSignIn.initialize();
  }

  SyncAuthAccount _toAccount(User user, {String? fallbackProviderId}) {
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : fallbackProviderId ?? 'firebase';
    return SyncAuthAccount(
      uid: user.uid,
      providerId: providerId,
      email: user.email,
      displayName: user.displayName,
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
