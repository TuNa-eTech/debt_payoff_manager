import 'dart:async';
import 'dart:convert';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';
import 'package:debt_payoff_manager/features/pricing/data/storekit_entitlement_service.dart';
import 'package:debt_payoff_manager/features/pricing/domain/premium_models.dart';
import 'package:debt_payoff_manager/features/pricing/domain/purchase_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl settingsRepository;
  late _FakePurchaseService purchaseService;
  late StoreKitEntitlementService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    settingsRepository = SettingsRepositoryImpl(db: db);
    purchaseService = _FakePurchaseService();
    service = StoreKitEntitlementService(
      purchaseService: purchaseService,
      settingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    await service.dispose();
    await db.close();
  });

  group('StoreKitEntitlementService', () {
    test('activates premium from a StoreKit 2 verified transaction', () async {
      final expiresAt = _millisecondUtc(
        DateTime.now().toUtc().add(const Duration(days: 30)),
      );
      final snapshot = await service.validatePurchase(
        _purchase(expiresAt: expiresAt),
      );

      final settings = await settingsRepository.getSettings();

      expect(snapshot.isActive, isTrue);
      expect(settings.isPremium, isTrue);
      expect(settings.premiumExpiresAt, expiresAt);
    });

    test('marks expired StoreKit 2 transaction as expired', () async {
      final expiresAt = _millisecondUtc(
        DateTime.now().toUtc().subtract(const Duration(days: 1)),
      );
      final snapshot = await service.validatePurchase(
        _purchase(expiresAt: expiresAt),
      );

      final settings = await settingsRepository.getSettings();

      expect(snapshot.status, EntitlementStatus.expired);
      expect(settings.isPremium, isFalse);
      expect(settings.premiumExpiresAt, expiresAt);
    });

    test('refreshes from past StoreKit 2 purchases without Firebase', () async {
      final expiresAt = _millisecondUtc(
        DateTime.now().toUtc().add(const Duration(days: 365)),
      );
      purchaseService.pastPurchases = [_purchase(expiresAt: expiresAt)];

      final snapshot = await service.refreshEntitlement();

      expect(snapshot.isActive, isTrue);
      expect(purchaseService.queryPastPurchasesCalls, 1);
    });

    test('decodes JWS payload when local JSON is unavailable', () async {
      final expiresAt = _millisecondUtc(
        DateTime.now().toUtc().add(const Duration(days: 30)),
      );
      final snapshot = await service.validatePurchase(
        _purchase(
          includeLocalVerificationData: false,
          serverVerificationData: _jws(<String, Object?>{
            'productId': PremiumProductId.monthly.storeId,
            'expiresDate': expiresAt.millisecondsSinceEpoch,
          }),
        ),
      );

      expect(snapshot.isActive, isTrue);
      expect(snapshot.expiresAt, expiresAt);
    });
  });

  group('premiumEntitlementErrorMessage', () {
    test('maps local verification failure to restore guidance', () {
      final message = premiumEntitlementErrorMessage(
        StateError('Purchase could not be verified locally.'),
      );

      expect(
        message,
        'Purchase could not be verified. Please try Restore Purchases.',
      );
    });

    test('maps product mismatch distinctly', () {
      final message = premiumEntitlementErrorMessage(
        StateError('Purchase does not match this Premium product.'),
      );

      expect(
        message,
        'The App Store transaction does not match this Premium product.',
      );
    });
  });
}

PremiumPurchase _purchase({
  PremiumProductId productId = PremiumProductId.monthly,
  DateTime? expiresAt,
  bool includeLocalVerificationData = true,
  String? serverVerificationData,
}) {
  final data = includeLocalVerificationData
      ? jsonEncode(<String, Object?>{
          'productId': productId.storeId,
          'expiresDate': expiresAt!.millisecondsSinceEpoch,
        })
      : null;
  return PremiumPurchase(
    productId: productId,
    status: PremiumPurchaseStatus.purchased,
    pendingCompletePurchase: true,
    transactionId: 'test-transaction',
    localVerificationData: data,
    serverVerificationData: serverVerificationData,
    source: 'app_store',
  );
}

DateTime _millisecondUtc(DateTime value) {
  return DateTime.fromMillisecondsSinceEpoch(
    value.millisecondsSinceEpoch,
    isUtc: true,
  );
}

String _jws(Map<String, Object?> payload) {
  String encode(Object value) {
    return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  }

  return '${encode(<String, Object?>{'alg': 'ES256'})}.${encode(payload)}.sig';
}

class _FakePurchaseService implements PurchaseService {
  final _controller = StreamController<PremiumPurchase>.broadcast();

  List<PremiumPurchase> pastPurchases = const [];
  int queryPastPurchasesCalls = 0;

  @override
  Stream<PremiumPurchase> get purchaseStream => _controller.stream;

  @override
  Future<void> buy(PremiumProduct product) async {}

  @override
  Future<void> completePurchase(PremiumPurchase purchase) async {}

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<PremiumProduct>> queryPremiumProducts() async => const [];

  @override
  Future<List<PremiumPurchase>> queryPastPurchases() async {
    queryPastPurchasesCalls += 1;
    return pastPurchases;
  }

  @override
  Future<void> openSubscriptionManagement() async {}

  @override
  Future<void> restorePurchases() async {}
}
