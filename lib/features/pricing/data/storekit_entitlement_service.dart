import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/settings_repository_impl.dart';
import '../domain/entitlement_service.dart';
import '../domain/premium_models.dart';
import '../domain/purchase_service.dart';
import 'in_app_purchase_service.dart';

class StoreKitEntitlementService implements EntitlementService {
  StoreKitEntitlementService({
    required PurchaseService purchaseService,
    required SettingsRepositoryImpl settingsRepository,
  }) : _purchaseService = purchaseService,
       _settingsRepository = settingsRepository;

  final PurchaseService _purchaseService;
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
      final purchases = await _purchaseService.queryPastPurchases();
      final snapshot = _snapshotFromPurchases(purchases);
      await _cacheSnapshot(snapshot);
      _events.add(PremiumEntitlementEvent.resolved(snapshot));
      return snapshot;
    } catch (_) {
      final snapshot = await _localSnapshot();
      _events.add(PremiumEntitlementEvent.resolved(snapshot));
      return snapshot;
    }
  }

  @override
  Future<EntitlementSnapshot> validatePurchase(PremiumPurchase purchase) async {
    final snapshot = _snapshotFromPurchase(purchase);
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

  EntitlementSnapshot _snapshotFromPurchases(List<PremiumPurchase> purchases) {
    if (purchases.isEmpty) return const EntitlementSnapshot.free();

    final snapshots = <EntitlementSnapshot>[];
    for (final purchase in purchases) {
      if (purchase.status != PremiumPurchaseStatus.purchased &&
          purchase.status != PremiumPurchaseStatus.restored) {
        continue;
      }
      try {
        snapshots.add(_snapshotFromPurchase(purchase));
      } catch (_) {
        // Ignore malformed historical transactions; StoreKit will emit valid
        // current entitlements again through purchase updates/restore.
      }
    }

    if (snapshots.isEmpty) return const EntitlementSnapshot.free();

    final active = snapshots.where((snapshot) => snapshot.isActive).toList();
    if (active.isNotEmpty) {
      active.sort(_compareSnapshotsByExpiryDesc);
      return active.first;
    }

    final expired = snapshots
        .where((snapshot) => snapshot.status == EntitlementStatus.expired)
        .toList();
    if (expired.isEmpty) return const EntitlementSnapshot.free();
    expired.sort(_compareSnapshotsByExpiryDesc);
    return expired.first;
  }

  EntitlementSnapshot _snapshotFromPurchase(PremiumPurchase purchase) {
    final productId = purchase.productId;
    if (productId == null) {
      throw StateError('Unsupported Premium product.');
    }

    if (purchase.status != PremiumPurchaseStatus.purchased &&
        purchase.status != PremiumPurchaseStatus.restored) {
      return const EntitlementSnapshot.free();
    }

    final transaction = _decodeStoreKit2Transaction(purchase);
    final transactionProductId = _stringValue(transaction['productId']);
    if (transactionProductId != null &&
        transactionProductId != productId.storeId) {
      throw StateError('Purchase does not match this Premium product.');
    }

    final revocationDate = _dateValue(transaction['revocationDate']);
    if (revocationDate != null) {
      return EntitlementSnapshot(
        status: EntitlementStatus.expired,
        expiresAt: revocationDate,
      );
    }

    final expiresAt =
        _dateValue(transaction['expiresDate']) ??
        _dateValue(transaction['expirationDate']) ??
        _dateValue(transaction['expires_date_ms']);
    if (expiresAt == null) {
      throw StateError('Purchase could not be verified locally.');
    }

    return EntitlementSnapshot(
      status: expiresAt.isAfter(DateTime.now().toUtc())
          ? EntitlementStatus.active
          : EntitlementStatus.expired,
      expiresAt: expiresAt,
    );
  }

  Map<String, Object?> _decodeStoreKit2Transaction(PremiumPurchase purchase) {
    final local = purchase.localVerificationData;
    final decodedLocal = _decodeJsonObject(local);
    if (decodedLocal != null) return decodedLocal;

    final decodedJws = _decodeJwsPayload(purchase.serverVerificationData);
    if (decodedJws != null) return decodedJws;

    throw StateError('Purchase could not be verified locally.');
  }

  Map<String, Object?>? _decodeJsonObject(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, Object?>) return decoded;
      if (decoded is Map) return Map<String, Object?>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  Map<String, Object?>? _decodeJwsPayload(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      return _decodeJsonObject(payload);
    } catch (_) {
      return null;
    }
  }

  DateTime? _dateValue(Object? value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final millis = int.tryParse(trimmed);
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
      }
      return DateTime.tryParse(trimmed)?.toUtc();
    }
    return null;
  }

  String? _stringValue(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  int _compareSnapshotsByExpiryDesc(
    EntitlementSnapshot a,
    EntitlementSnapshot b,
  ) {
    final aExpiry = a.expiresAt;
    final bExpiry = b.expiresAt;
    if (aExpiry == null && bExpiry == null) return 0;
    if (aExpiry == null) return -1;
    if (bExpiry == null) return 1;
    return bExpiry.compareTo(aExpiry);
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

  String _cleanError(Object error) {
    return premiumEntitlementErrorMessage(error);
  }
}

@visibleForTesting
String premiumEntitlementErrorMessage(Object error) {
  final raw = error.toString();
  final lower = raw.toLowerCase();
  if (lower.contains('expired')) {
    return 'This subscription is expired.';
  }
  if (lower.contains('cancelled') || lower.contains('canceled')) {
    return 'This subscription was cancelled.';
  }
  if (lower.contains('does not match')) {
    return 'The App Store transaction does not match this Premium product.';
  }
  if (lower.contains('could not be verified locally') ||
      lower.contains('unsupported premium product')) {
    return 'Purchase could not be verified. Please try Restore Purchases.';
  }
  return _stripErrorPrefixes(raw);
}

String _stripErrorPrefixes(String value) {
  const prefixes = [
    'Exception: ',
    'Bad state: ',
    'Invalid argument(s): ',
    '[firebase_functions/permission-denied] ',
    '[firebase_functions/failed-precondition] ',
  ];
  var cleaned = value;
  var changed = true;
  while (changed) {
    changed = false;
    for (final prefix in prefixes) {
      if (cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length);
        changed = true;
      }
    }
  }
  return cleaned;
}
