import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../data/repositories/settings_repository_impl.dart';
import '../../../sync/sync_auth_service.dart';
import '../domain/entitlement_service.dart';
import '../domain/premium_models.dart';
import '../domain/purchase_service.dart';
import 'in_app_purchase_service.dart';

class FirebaseEntitlementService implements EntitlementService {
  FirebaseEntitlementService({
    required PurchaseService purchaseService,
    required FirebaseFunctions functions,
    required FirebaseAuth auth,
    required FirebaseSyncInitializer initializer,
    required SettingsRepositoryImpl settingsRepository,
  }) : _purchaseService = purchaseService,
       _functions = functions,
       _auth = auth,
       _initializer = initializer,
       _settingsRepository = settingsRepository;

  final PurchaseService _purchaseService;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final FirebaseSyncInitializer _initializer;
  final SettingsRepositoryImpl _settingsRepository;
  final _events = StreamController<PremiumEntitlementEvent>.broadcast();

  StreamSubscription<PremiumPurchase>? _purchaseSub;

  @override
  Stream<PremiumEntitlementEvent> watchEvents() => _events.stream;

  @override
  Future<void> init() async {
    _purchaseSub ??= _purchaseService.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (Object error) {
        _events.add(PremiumEntitlementEvent.error(_cleanError(error)));
      },
    );
    unawaited(refreshEntitlement());
  }

  @override
  Future<EntitlementSnapshot> refreshEntitlement() async {
    try {
      await _ensureAuth();
      final callable = _functions.httpsCallable('refreshEntitlement');
      final response = await callable.call<Map<String, dynamic>>({});
      final snapshot = _snapshotFromData(response.data);
      await _cacheSnapshot(snapshot);
      _events.add(PremiumEntitlementEvent.resolved(snapshot));
      return snapshot;
    } catch (error) {
      final snapshot = await _localSnapshot();
      _events.add(PremiumEntitlementEvent.resolved(snapshot));
      return snapshot;
    }
  }

  @override
  Future<EntitlementSnapshot> validatePurchase(PremiumPurchase purchase) async {
    await _ensureAuth();
    final productId = purchase.productId;
    if (productId == null) {
      throw StateError('Unsupported Premium product.');
    }
    final callable = _functions.httpsCallable('verifyPurchase');
    final response = await callable.call<Map<String, dynamic>>({
      'platform': defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android',
      'productId': productId.storeId,
      'transactionId': purchase.transactionId,
      'verificationData': {
        'localVerificationData': purchase.localVerificationData,
        'serverVerificationData': purchase.serverVerificationData,
        'source': purchase.source,
      },
    });
    final snapshot = _snapshotFromData(response.data);
    await _cacheSnapshot(snapshot);
    _events.add(PremiumEntitlementEvent.resolved(snapshot));
    return snapshot;
  }

  @override
  bool isPremiumActive(settings) {
    if (settings == null || !settings.isPremium) return false;
    final expiry = settings.premiumExpiresAt;
    return expiry == null || expiry.isAfter(DateTime.now().toUtc());
  }

  @override
  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    await _events.close();
  }

  Future<void> _handlePurchaseUpdate(PremiumPurchase purchase) async {
    try {
      switch (purchase.status) {
        case PremiumPurchaseStatus.pending:
          _events.add(const PremiumEntitlementEvent.pending());
        case PremiumPurchaseStatus.error:
        case PremiumPurchaseStatus.canceled:
          _events.add(
            PremiumEntitlementEvent.error(
              purchase.errorMessage ?? 'Purchase was not completed.',
            ),
          );
        case PremiumPurchaseStatus.purchased:
        case PremiumPurchaseStatus.restored:
          await validatePurchase(purchase);
      }
    } catch (error) {
      _events.add(PremiumEntitlementEvent.error(_cleanError(error)));
    } finally {
      await _purchaseService.completeStorePurchase(purchase);
    }
  }

  Future<void> _ensureAuth() async {
    await _initializer.ensureReady();
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  EntitlementSnapshot _snapshotFromData(Map<String, dynamic> data) {
    final active = data['active'] == true;
    final expiresAt = _parseDate(data['expiresAt']);
    if (active) {
      return EntitlementSnapshot(
        status: EntitlementStatus.active,
        expiresAt: expiresAt,
      );
    }
    if (expiresAt != null && expiresAt.isBefore(DateTime.now().toUtc())) {
      return EntitlementSnapshot(
        status: EntitlementStatus.expired,
        expiresAt: expiresAt,
      );
    }
    return const EntitlementSnapshot.free();
  }

  Future<EntitlementSnapshot> _localSnapshot() async {
    final settings = await _settingsRepository.getSettings();
    if (isPremiumActive(settings)) {
      return EntitlementSnapshot(
        status: EntitlementStatus.active,
        expiresAt: settings.premiumExpiresAt,
      );
    }
    return settings.premiumExpiresAt == null
        ? const EntitlementSnapshot.free()
        : EntitlementSnapshot(
            status: EntitlementStatus.expired,
            expiresAt: settings.premiumExpiresAt,
          );
  }

  Future<void> _cacheSnapshot(EntitlementSnapshot snapshot) async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.updateSettings(
      settings.copyWith(
        isPremium: snapshot.isActive,
        premiumExpiresAt: snapshot.expiresAt,
        clearPremiumExpiresAt: snapshot.expiresAt == null,
      ),
    );
  }

  DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }

  String _cleanError(Object error) {
    final value = error.toString();
    const prefixes = ['Exception: ', 'Bad state: ', 'Invalid argument(s): '];
    for (final prefix in prefixes) {
      if (value.startsWith(prefix)) return value.substring(prefix.length);
    }
    return value;
  }
}
