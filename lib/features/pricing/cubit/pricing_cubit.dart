import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/settings_repository.dart';
import '../domain/entitlement_service.dart';
import '../domain/premium_models.dart';
import '../domain/purchase_service.dart';
import 'pricing_state.dart';

class PricingCubit extends Cubit<PricingState> {
  PricingCubit({
    required PurchaseService purchaseService,
    required EntitlementService entitlementService,
    required SettingsRepository settingsRepository,
  }) : _purchaseService = purchaseService,
       _entitlementService = entitlementService,
       _settingsRepository = settingsRepository,
       super(const PricingState()) {
    _eventsSub = _entitlementService.watchEvents().listen(_onEvent);
  }

  final PurchaseService _purchaseService;
  final EntitlementService _entitlementService;
  final SettingsRepository _settingsRepository;
  StreamSubscription<PremiumEntitlementEvent>? _eventsSub;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearMessage: true));
    unawaited(_entitlementService.refreshEntitlement());
    try {
      final settings = await _settingsRepository.getSettings();
      final isActive = _entitlementService.isPremiumActive(settings);
      final available = await _purchaseService.isAvailable();
      final products = available
          ? await _purchaseService.queryPremiumProducts()
          : <PremiumProduct>[];
      emit(
        state.copyWith(
          isLoading: false,
          isStoreAvailable: available,
          products: products,
          selectedProductId:
              products.any((product) => product.id == PremiumProductId.yearly)
              ? PremiumProductId.yearly
              : products.isNotEmpty
              ? products.first.id
              : null,
          isPremiumActive: isActive,
          premiumExpiresAt: settings.premiumExpiresAt,
          clearPremiumExpiresAt: settings.premiumExpiresAt == null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isStoreAvailable: false,
          errorMessage: _cleanError(error),
        ),
      );
    }
  }

  void selectProduct(PremiumProductId id) {
    emit(state.copyWith(selectedProductId: id));
  }

  Future<void> buySelected() async {
    final product = state.selectedProduct;
    if (product == null) {
      emit(state.copyWith(errorMessage: 'Premium products are not available.'));
      return;
    }
    emit(state.copyWith(isPurchasing: true, clearError: true));
    try {
      await _purchaseService.buy(product);
    } catch (error) {
      emit(
        state.copyWith(isPurchasing: false, errorMessage: _cleanError(error)),
      );
    }
  }

  Future<void> restorePurchases() async {
    emit(state.copyWith(isPurchasing: true, clearError: true));
    try {
      await _purchaseService.restorePurchases();
    } catch (error) {
      emit(
        state.copyWith(isPurchasing: false, errorMessage: _cleanError(error)),
      );
    }
  }

  Future<void> refreshEntitlement() async {
    await _entitlementService.refreshEntitlement();
  }

  void _onEvent(PremiumEntitlementEvent event) {
    if (event.isPending) {
      emit(state.copyWith(isPurchasing: true, clearError: true));
      return;
    }
    if (event.isError) {
      emit(
        state.copyWith(
          isPurchasing: false,
          errorMessage: event.message ?? 'Purchase could not be completed.',
        ),
      );
      return;
    }
    final snapshot = event.snapshot;
    if (snapshot == null) return;
    emit(
      state.copyWith(
        isPurchasing: false,
        isPremiumActive: snapshot.isActive,
        premiumExpiresAt: snapshot.expiresAt,
        clearPremiumExpiresAt: snapshot.expiresAt == null,
        message: snapshot.isActive ? 'Premium is active.' : null,
      ),
    );
  }

  String _cleanError(Object error) {
    final value = error.toString();
    const prefixes = ['Exception: ', 'Bad state: ', 'Invalid argument(s): '];
    for (final prefix in prefixes) {
      if (value.startsWith(prefix)) return value.substring(prefix.length);
    }
    return value;
  }

  @override
  Future<void> close() {
    _eventsSub?.cancel();
    return super.close();
  }
}
