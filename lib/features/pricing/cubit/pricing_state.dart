import 'package:equatable/equatable.dart';

import '../domain/premium_models.dart';

class PricingState extends Equatable {
  const PricingState({
    this.isLoading = true,
    this.isStoreAvailable = false,
    this.products = const [],
    this.selectedProductId = PremiumProductId.yearly,
    this.isPurchasing = false,
    this.isPremiumActive = false,
    this.premiumExpiresAt,
    this.message,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isStoreAvailable;
  final List<PremiumProduct> products;
  final PremiumProductId selectedProductId;
  final bool isPurchasing;
  final bool isPremiumActive;
  final DateTime? premiumExpiresAt;
  final String? message;
  final String? errorMessage;

  PremiumProduct? get selectedProduct {
    for (final product in products) {
      if (product.id == selectedProductId) return product;
    }
    return products.isNotEmpty ? products.first : null;
  }

  PricingState copyWith({
    bool? isLoading,
    bool? isStoreAvailable,
    List<PremiumProduct>? products,
    PremiumProductId? selectedProductId,
    bool? isPurchasing,
    bool? isPremiumActive,
    DateTime? premiumExpiresAt,
    bool clearPremiumExpiresAt = false,
    String? message,
    bool clearMessage = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PricingState(
      isLoading: isLoading ?? this.isLoading,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      products: products ?? this.products,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isPremiumActive: isPremiumActive ?? this.isPremiumActive,
      premiumExpiresAt: clearPremiumExpiresAt
          ? null
          : premiumExpiresAt ?? this.premiumExpiresAt,
      message: clearMessage ? null : message ?? this.message,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isStoreAvailable,
    products,
    selectedProductId,
    isPurchasing,
    isPremiumActive,
    premiumExpiresAt,
    message,
    errorMessage,
  ];
}
