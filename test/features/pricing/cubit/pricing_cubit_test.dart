import 'dart:async';

import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';

import '../../../data/repositories/repository_test_helpers.dart';
import 'package:debt_payoff_manager/features/pricing/cubit/pricing_cubit.dart';
import 'package:debt_payoff_manager/features/pricing/cubit/pricing_state.dart';
import 'package:debt_payoff_manager/features/pricing/domain/entitlement_service.dart';
import 'package:debt_payoff_manager/features/pricing/domain/premium_models.dart';
import 'package:debt_payoff_manager/features/pricing/domain/purchase_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakePurchaseService purchaseService;
  late _FakeEntitlementService entitlementService;
  late _FakeSettingsRepository settingsRepository;
  late PricingCubit cubit;

  setUp(() {
    purchaseService = _FakePurchaseService();
    entitlementService = _FakeEntitlementService();
    settingsRepository = _FakeSettingsRepository();
    cubit = PricingCubit(
      purchaseService: purchaseService,
      entitlementService: entitlementService,
      settingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    await cubit.close();
    await entitlementService.dispose();
  });

  group('load', () {
    test('emits loaded state with products and premium inactive', () async {
      await cubit.load();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isStoreAvailable, isTrue);
      expect(cubit.state.products, hasLength(2));
      expect(cubit.state.selectedProductId, PremiumProductId.yearly);
      expect(cubit.state.isPremiumActive, isFalse);
    });

    test('selects yearly product by default', () async {
      await cubit.load();

      expect(cubit.state.selectedProductId, PremiumProductId.yearly);
      expect(cubit.state.selectedProduct?.id, PremiumProductId.yearly);
    });

    test('emits unavailable state when store is not available', () async {
      purchaseService = _FakePurchaseService(isAvailable: false);
      cubit = PricingCubit(
        purchaseService: purchaseService,
        entitlementService: entitlementService,
        settingsRepository: settingsRepository,
      );

      await cubit.load();

      expect(cubit.state.isStoreAvailable, isFalse);
      expect(cubit.state.products, isEmpty);
      expect(cubit.state.selectedProduct, isNull);
    });

    test('reflects cached premium active from settings', () async {
      settingsRepository.settings = makeRepoSettings(isPremium: true);

      await cubit.load();

      expect(cubit.state.isPremiumActive, isTrue);
    });

    test('reflects cached premium expired from settings', () async {
      settingsRepository.settings = makeRepoSettings(
        isPremium: true,
        premiumExpiresAt: DateTime.now().toUtc().subtract(
          const Duration(days: 1),
        ),
      );

      await cubit.load();

      expect(cubit.state.isPremiumActive, isFalse);
    });

    test('triggers background entitlement refresh', () async {
      await cubit.load();

      expect(entitlementService.refreshCount, 1);
    });
  });

  group('selectProduct', () {
    test('updates selected product', () async {
      await cubit.load();

      cubit.selectProduct(PremiumProductId.monthly);

      expect(cubit.state.selectedProductId, PremiumProductId.monthly);
    });
  });

  group('buySelected', () {
    test('calls purchase service with selected product', () async {
      await cubit.load();

      await cubit.buySelected();

      expect(purchaseService.boughtProducts, [PremiumProductId.yearly]);
    });

    test('emits isPurchasing during buy', () async {
      await cubit.load();
      final states = <PricingState>[];
      final sub = cubit.stream.listen(states.add);

      purchaseService.buyDelay = const Duration(milliseconds: 50);
      final future = cubit.buySelected();
      await pumpAsync();
      expect(states.any((s) => s.isPurchasing), isTrue);

      await future;
      sub.cancel();
    });

    test('emits error when store not available', () async {
      purchaseService = _FakePurchaseService(isAvailable: false);
      cubit = PricingCubit(
        purchaseService: purchaseService,
        entitlementService: entitlementService,
        settingsRepository: settingsRepository,
      );
      await cubit.load();

      await cubit.buySelected();

      expect(cubit.state.errorMessage, isNotNull);
      expect(cubit.state.isPurchasing, isFalse);
    });
  });

  group('restorePurchases', () {
    test('calls purchase service restore', () async {
      await cubit.load();
      await cubit.restorePurchases();

      expect(purchaseService.restoreCount, 1);
    });
  });

  group('openSubscriptionManagement', () {
    test('calls purchase service subscription management', () async {
      await cubit.load();
      await cubit.openSubscriptionManagement();

      expect(purchaseService.manageSubscriptionCount, 1);
    });
  });

  group('debugClearPremiumCache', () {
    test('clears cached premium entitlement in debug mode', () async {
      settingsRepository.settings = makeRepoSettings(
        isPremium: true,
        premiumExpiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
      );
      await cubit.load();
      expect(cubit.state.isPremiumActive, isTrue);

      await cubit.debugClearPremiumCache();

      expect(settingsRepository.settings.isPremium, isFalse);
      expect(settingsRepository.settings.premiumExpiresAt, isNull);
      expect(cubit.state.isPremiumActive, isFalse);
      expect(cubit.state.premiumExpiresAt, isNull);
      expect(cubit.state.message, pricingDebugPremiumClearedMessage);
    });
  });

  group('entitlement events', () {
    test(
      'pending purchase sets isPurchasing without unlocking premium',
      () async {
        await cubit.load();

        entitlementService.addEvent(const PremiumEntitlementEvent.pending());
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.isPurchasing, isTrue);
        expect(cubit.state.isPremiumActive, isFalse);
      },
    );

    test('error event clears purchasing and sets error message', () async {
      await cubit.load();
      entitlementService.addEvent(const PremiumEntitlementEvent.pending());
      await Future<void>.delayed(Duration.zero);

      entitlementService.addEvent(
        const PremiumEntitlementEvent.error('Payment declined.'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isPurchasing, isFalse);
      expect(cubit.state.errorMessage, 'Payment declined.');
      expect(cubit.state.isPremiumActive, isFalse);
    });

    test('active snapshot unlocks premium and shows message', () async {
      await cubit.load();

      entitlementService.addEvent(
        PremiumEntitlementEvent.resolved(
          EntitlementSnapshot(
            status: EntitlementStatus.active,
            expiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isPremiumActive, isTrue);
      expect(cubit.state.isPurchasing, isFalse);
      expect(cubit.state.message, pricingPremiumActivatedMessage);
    });

    test('expired snapshot downgrades to free', () async {
      settingsRepository.settings = makeRepoSettings(isPremium: true);
      await cubit.load();
      expect(cubit.state.isPremiumActive, isTrue);

      entitlementService.addEvent(
        PremiumEntitlementEvent.resolved(
          EntitlementSnapshot(
            status: EntitlementStatus.expired,
            expiresAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isPremiumActive, isFalse);
    });

    test('free snapshot keeps premium inactive', () async {
      await cubit.load();

      entitlementService.addEvent(
        const PremiumEntitlementEvent.resolved(EntitlementSnapshot.free()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isPremiumActive, isFalse);
    });
  });
}

Future<void> pumpAsync() => Future<void>.delayed(Duration.zero);

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakePurchaseService implements PurchaseService {
  _FakePurchaseService({bool isAvailable = true}) : _isAvailable = isAvailable;

  final bool _isAvailable;
  final boughtProducts = <PremiumProductId>[];
  var restoreCount = 0;
  var manageSubscriptionCount = 0;
  Duration? buyDelay;

  @override
  Stream<PremiumPurchase> get purchaseStream =>
      const Stream<PremiumPurchase>.empty();

  @override
  Future<bool> isAvailable() async => _isAvailable;

  @override
  Future<List<PremiumProduct>> queryPremiumProducts() async {
    if (!_isAvailable) return [];
    return const [
      PremiumProduct(
        id: PremiumProductId.monthly,
        title: 'Premium Monthly',
        description: 'Monthly',
        price: '\$4.99',
        rawPrice: 4.99,
        currencyCode: 'USD',
      ),
      PremiumProduct(
        id: PremiumProductId.yearly,
        title: 'Premium Yearly',
        description: 'Yearly',
        price: '\$39.99',
        rawPrice: 39.99,
        currencyCode: 'USD',
      ),
    ];
  }

  @override
  Future<List<PremiumPurchase>> queryPastPurchases() async => const [];

  @override
  Future<void> buy(PremiumProduct product) async {
    if (buyDelay != null) await Future<void>.delayed(buyDelay!);
    boughtProducts.add(product.id);
  }

  @override
  Future<void> restorePurchases() async {
    restoreCount += 1;
  }

  @override
  Future<void> openSubscriptionManagement() async {
    manageSubscriptionCount += 1;
  }

  @override
  Future<void> completePurchase(PremiumPurchase purchase) async {}
}

class _FakeEntitlementService implements EntitlementService {
  final _controller = StreamController<PremiumEntitlementEvent>.broadcast();
  var refreshCount = 0;

  void addEvent(PremiumEntitlementEvent event) => _controller.add(event);

  @override
  Stream<PremiumEntitlementEvent> watchEvents() => _controller.stream;

  @override
  Future<void> init() async {}

  @override
  Future<EntitlementSnapshot> refreshEntitlement() async {
    refreshCount += 1;
    return const EntitlementSnapshot.free();
  }

  @override
  Future<EntitlementSnapshot> validatePurchase(
    PremiumPurchase purchase,
  ) async => const EntitlementSnapshot.free();

  @override
  bool isPremiumActive(UserSettings? settings) {
    if (settings == null || !settings.isPremium) return false;
    final expiry = settings.premiumExpiresAt;
    return expiry == null || expiry.isAfter(DateTime.now().toUtc());
  }

  @override
  Future<void> dispose() => _controller.close();
}

class _FakeSettingsRepository implements SettingsRepository {
  UserSettings settings = makeRepoSettings();

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> updateSettings(UserSettings s) async {
    settings = s;
  }

  @override
  Stream<UserSettings> watchSettings() => const Stream.empty();
}
