import 'package:equatable/equatable.dart';

enum PremiumProductId {
  monthly('premium_monthly'),
  yearly('premium_yearly');

  const PremiumProductId(this.storeId);

  final String storeId;

  static PremiumProductId? fromStoreId(String id) {
    for (final value in values) {
      if (value.storeId == id) return value;
    }
    return null;
  }
}

enum PremiumFeature {
  scenarios,
  compareScenarios,
  advancedReports,
  partnerSharing,
  customMilestones,
}

enum EntitlementStatus { free, active, expired, unknown }

enum PremiumPurchaseStatus { pending, purchased, restored, error, canceled }

class PremiumProduct extends Equatable {
  const PremiumProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
  });

  final PremiumProductId id;
  final String title;
  final String description;
  final String price;
  final double rawPrice;
  final String currencyCode;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    rawPrice,
    currencyCode,
  ];
}

class PremiumPurchase extends Equatable {
  const PremiumPurchase({
    required this.productId,
    required this.status,
    required this.pendingCompletePurchase,
    this.transactionId,
    this.localVerificationData,
    this.serverVerificationData,
    this.source,
    this.errorMessage,
  });

  final PremiumProductId? productId;
  final PremiumPurchaseStatus status;
  final bool pendingCompletePurchase;
  final String? transactionId;
  final String? localVerificationData;
  final String? serverVerificationData;
  final String? source;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    productId,
    status,
    pendingCompletePurchase,
    transactionId,
    localVerificationData,
    serverVerificationData,
    source,
    errorMessage,
  ];
}

class EntitlementSnapshot extends Equatable {
  const EntitlementSnapshot({required this.status, this.expiresAt});

  const EntitlementSnapshot.free() : this(status: EntitlementStatus.free);

  final EntitlementStatus status;
  final DateTime? expiresAt;

  bool get isActive {
    if (status != EntitlementStatus.active) return false;
    final expiry = expiresAt;
    return expiry == null || expiry.isAfter(DateTime.now().toUtc());
  }

  @override
  List<Object?> get props => [status, expiresAt];
}

class PremiumEntitlementEvent extends Equatable {
  const PremiumEntitlementEvent({
    required this.isPending,
    this.snapshot,
    this.message,
    this.isError = false,
  });

  const PremiumEntitlementEvent.pending()
    : this(isPending: true, message: null);

  const PremiumEntitlementEvent.resolved(EntitlementSnapshot snapshot)
    : this(isPending: false, snapshot: snapshot);

  const PremiumEntitlementEvent.error(String message)
    : this(isPending: false, message: message, isError: true);

  final bool isPending;
  final EntitlementSnapshot? snapshot;
  final String? message;
  final bool isError;

  @override
  List<Object?> get props => [isPending, snapshot, message, isError];
}
