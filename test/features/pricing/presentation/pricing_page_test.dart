import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/di/injection.dart';
import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/pricing/cubit/pricing_cubit.dart';
import 'package:debt_payoff_manager/features/pricing/domain/entitlement_service.dart';
import 'package:debt_payoff_manager/features/pricing/domain/premium_models.dart';
import 'package:debt_payoff_manager/features/pricing/domain/purchase_service.dart';
import 'package:debt_payoff_manager/features/pricing/presentation/pages/pricing_page.dart';
import 'package:debt_payoff_manager/l10n/app_localizations.dart';

import '../../../data/repositories/repository_test_helpers.dart';

void main() {
  group('PricingPage', () {
    testWidgets('renders store prices and starts selected purchase', (
      tester,
    ) async {
      final purchaseService = _FakePurchaseService();
      await _pumpPricingPage(tester, purchaseService: purchaseService);

      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('\$39.99'), 300);
      expect(find.text('\$4.99'), findsOneWidget);
      expect(find.text('\$39.99'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(AppTestKeys.pricingPurchasePremium),
        300,
      );
      await tester.tap(find.byKey(AppTestKeys.pricingPurchasePremium));
      await tester.pump();

      expect(purchaseService.boughtProducts, [PremiumProductId.yearly]);
    });

    testWidgets('restore button calls purchase restore', (tester) async {
      final purchaseService = _FakePurchaseService();
      await _pumpPricingPage(tester, purchaseService: purchaseService);

      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(AppTestKeys.pricingRestorePurchases),
        300,
      );
      await tester.tap(find.byKey(AppTestKeys.pricingRestorePurchases));
      await tester.pump();

      expect(purchaseService.restoreCount, 1);
    });

    testWidgets('store unavailable disables premium purchase', (tester) async {
      final purchaseService = _FakePurchaseService(isAvailable: false);
      await _pumpPricingPage(tester, purchaseService: purchaseService);

      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(AppTestKeys.pricingPurchasePremium),
        300,
      );

      final button = tester.widget<FilledButton>(
        find.descendant(
          of: find.byKey(AppTestKeys.pricingPurchasePremium),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
      expect(purchaseService.boughtProducts, isEmpty);
    });

    testWidgets('debug clear premium button resets cached premium', (
      tester,
    ) async {
      final purchaseService = _FakePurchaseService();
      final settingsRepository = _InMemorySettingsRepository(
        makeRepoSettings(
          isPremium: true,
          premiumExpiresAt: DateTime.now().toUtc().add(
            const Duration(days: 30),
          ),
        ),
      );
      await _pumpPricingPage(
        tester,
        purchaseService: purchaseService,
        settingsRepository: settingsRepository,
      );

      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(AppTestKeys.pricingDebugClearPremium),
        300,
      );
      expect(find.text('Debug: Clear local Premium'), findsOneWidget);
      await tester.tap(find.byKey(AppTestKeys.pricingDebugClearPremium));
      await tester.pump();

      expect(settingsRepository._settings.isPremium, isFalse);
      expect(settingsRepository._settings.premiumExpiresAt, isNull);
    });

    testWidgets('debug manage subscription button opens App Store sheet', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final purchaseService = _FakePurchaseService();
        await _pumpPricingPage(tester, purchaseService: purchaseService);

        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(AppTestKeys.pricingDebugManageSubscription),
          300,
        );
        await tester.ensureVisible(
          find.byKey(AppTestKeys.pricingDebugManageSubscription),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(AppTestKeys.pricingDebugManageSubscription),
        );
        await tester.pump();

        expect(purchaseService.manageSubscriptionCount, 1);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('shows success dialog when premium becomes active', (
      tester,
    ) async {
      final purchaseService = _FakePurchaseService();
      final entitlementService = _FakeEntitlementService();
      await _pumpPricingPage(
        tester,
        purchaseService: purchaseService,
        entitlementService: entitlementService,
      );

      await tester.pumpAndSettle();
      entitlementService.addEvent(
        PremiumEntitlementEvent.resolved(
          EntitlementSnapshot(
            status: EntitlementStatus.active,
            expiresAt: DateTime.utc(2030, 1, 15, 12),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Your purchase was verified. Premium is active until 2030-01-15.',
        ),
        findsOneWidget,
      );
      expect(find.text('Done'), findsOneWidget);
    });
  });
}

Future<void> _pumpPricingPage(
  WidgetTester tester, {
  required _FakePurchaseService purchaseService,
  _InMemorySettingsRepository? settingsRepository,
  _FakeEntitlementService? entitlementService,
}) async {
  await getIt.reset();
  final repository =
      settingsRepository ?? _InMemorySettingsRepository(makeRepoSettings());
  final entitlement = entitlementService ?? _FakeEntitlementService();
  getIt
    ..registerSingleton<PurchaseService>(purchaseService)
    ..registerSingleton<EntitlementService>(entitlement)
    ..registerSingleton<SettingsRepository>(repository)
    ..registerFactory<PricingCubit>(
      () => PricingCubit(
        purchaseService: getIt<PurchaseService>(),
        entitlementService: getIt<EntitlementService>(),
        settingsRepository: getIt<SettingsRepository>(),
      ),
    );
  addTearDown(() async {
    await getIt.reset();
    await repository.dispose();
    await entitlement.dispose();
  });

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PricingPage(),
    ),
  );
}

class _FakePurchaseService implements PurchaseService {
  _FakePurchaseService({bool isAvailable = true}) : _isAvailable = isAvailable;

  final bool _isAvailable;
  final boughtProducts = <PremiumProductId>[];
  var restoreCount = 0;
  var manageSubscriptionCount = 0;
  final _controller = StreamController<PremiumPurchase>.broadcast();

  @override
  Stream<PremiumPurchase> get purchaseStream => _controller.stream;

  @override
  Future<void> buy(PremiumProduct product) async {
    boughtProducts.add(product.id);
  }

  @override
  Future<void> completePurchase(PremiumPurchase purchase) async {}

  @override
  Future<bool> isAvailable() async => _isAvailable;

  @override
  Future<List<PremiumProduct>> queryPremiumProducts() async {
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
  Future<void> restorePurchases() async {
    restoreCount += 1;
  }

  @override
  Future<void> openSubscriptionManagement() async {
    manageSubscriptionCount += 1;
  }
}

class _FakeEntitlementService implements EntitlementService {
  _FakeEntitlementService();
  final _controller = StreamController<PremiumEntitlementEvent>.broadcast();

  void addEvent(PremiumEntitlementEvent event) => _controller.add(event);

  @override
  Future<void> dispose() => _controller.close();

  @override
  Future<void> init() async {}

  @override
  bool isPremiumActive(UserSettings? settings) =>
      settings != null &&
      settings.isPremium &&
      (settings.premiumExpiresAt == null ||
          settings.premiumExpiresAt!.isAfter(DateTime.now().toUtc()));

  @override
  Future<EntitlementSnapshot> refreshEntitlement() async =>
      const EntitlementSnapshot.free();

  @override
  Future<EntitlementSnapshot> validatePurchase(
    PremiumPurchase purchase,
  ) async => const EntitlementSnapshot.free();

  @override
  Stream<PremiumEntitlementEvent> watchEvents() => _controller.stream;
}

class _InMemorySettingsRepository implements SettingsRepository {
  _InMemorySettingsRepository(this._settings) {
    _controller.add(_settings);
  }

  UserSettings _settings;
  final _controller = StreamController<UserSettings>.broadcast();

  @override
  Future<UserSettings> getSettings() async => _settings;

  @override
  Future<void> updateSettings(UserSettings settings) async {
    _settings = settings;
    _controller.add(settings);
  }

  @override
  Stream<UserSettings> watchSettings() => _controller.stream;

  Future<void> dispose() => _controller.close();
}
