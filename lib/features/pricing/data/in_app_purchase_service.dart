import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

import '../domain/premium_models.dart';
import '../domain/purchase_service.dart';

class InAppPurchaseService implements PurchaseService {
  InAppPurchaseService({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  static const MethodChannel _subscriptionChannel = MethodChannel(
    'debt_payoff_manager/subscriptions',
  );

  final InAppPurchase _inAppPurchase;
  final Map<PremiumProductId, ProductDetails> _productsById = {};

  @override
  Stream<PremiumPurchase> get purchaseStream => _inAppPurchase.purchaseStream
      .expand((purchases) => purchases.map(_mapPurchase));

  @override
  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  @override
  Future<List<PremiumProduct>> queryPremiumProducts() async {
    final response = await _inAppPurchase.queryProductDetails(
      PremiumProductId.values.map((id) => id.storeId).toSet(),
    );
    if (response.error != null) {
      throw StateError(response.error!.message);
    }

    _productsById
      ..clear()
      ..addEntries(
        response.productDetails.map((details) {
          final productId = PremiumProductId.fromStoreId(details.id);
          if (productId == null) return null;
          return MapEntry(productId, details);
        }).whereType<MapEntry<PremiumProductId, ProductDetails>>(),
      );

    return response.productDetails
        .map(_mapProduct)
        .whereType<PremiumProduct>()
        .toList(growable: false)
      ..sort((a, b) => a.id.index.compareTo(b.id.index));
  }

  @override
  Future<List<PremiumPurchase>> queryPastPurchases() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const <PremiumPurchase>[];
    }

    final transactions = await SK2Transaction.transactions();
    return transactions
        .map(_mapStoreKit2Transaction)
        .whereType<PremiumPurchase>()
        .toList(growable: false);
  }

  @override
  Future<void> buy(PremiumProduct product) async {
    final details = _productsById[product.id];
    if (details == null) {
      throw StateError('Premium product is not loaded.');
    }
    final started = await _inAppPurchase.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
    if (!started) {
      throw StateError('Purchase could not be started.');
    }
  }

  @override
  Future<void> restorePurchases() => _inAppPurchase.restorePurchases();

  @override
  Future<void> openSubscriptionManagement() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnsupportedError(
        'Subscription management is only available on iOS.',
      );
    }
    await _subscriptionChannel.invokeMethod<void>('openManageSubscriptions');
  }

  @override
  Future<void> completePurchase(PremiumPurchase purchase) async {
    final pending = purchase.source;
    if (!purchase.pendingCompletePurchase || pending == null) return;
    // The plugin requires the original PurchaseDetails. This source marker is
    // used by tests; real completion is handled in [_mapPurchaseDetails].
  }

  Future<void> completeRawPurchase(PurchaseDetails purchase) {
    return _inAppPurchase.completePurchase(purchase);
  }

  PremiumProduct? _mapProduct(ProductDetails details) {
    final productId = PremiumProductId.fromStoreId(details.id);
    if (productId == null) return null;
    return PremiumProduct(
      id: productId,
      title: details.title,
      description: details.description,
      price: details.price,
      rawPrice: details.rawPrice,
      currencyCode: details.currencyCode,
    );
  }

  PremiumPurchase _mapPurchase(PurchaseDetails details) {
    return _PurchaseWithRawDetails(
      productId: PremiumProductId.fromStoreId(details.productID),
      status: _mapStatus(details.status),
      pendingCompletePurchase: details.pendingCompletePurchase,
      transactionId: details.purchaseID,
      localVerificationData: details.verificationData.localVerificationData,
      serverVerificationData: details.verificationData.serverVerificationData,
      source: details.verificationData.source,
      errorMessage: details.error?.message,
      rawDetails: details,
      completeRawPurchase: completeRawPurchase,
    );
  }

  PremiumPurchase? _mapStoreKit2Transaction(SK2Transaction transaction) {
    final productId = PremiumProductId.fromStoreId(transaction.productId);
    if (productId == null) return null;
    return PremiumPurchase(
      productId: productId,
      status: PremiumPurchaseStatus.purchased,
      pendingCompletePurchase: false,
      transactionId: transaction.id,
      localVerificationData: _storeKit2LocalVerificationData(transaction),
      serverVerificationData: transaction.receiptData,
      source: 'app_store',
    );
  }

  String? _storeKit2LocalVerificationData(SK2Transaction transaction) {
    final jsonRepresentation = transaction.jsonRepresentation;
    if (jsonRepresentation != null && jsonRepresentation.trim().isNotEmpty) {
      return jsonRepresentation;
    }
    final expirationDate = transaction.expirationDate;
    if (expirationDate == null || expirationDate.trim().isEmpty) return null;
    return jsonEncode(<String, Object?>{
      'productId': transaction.productId,
      'expiresDate': expirationDate,
    });
  }

  PremiumPurchaseStatus _mapStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return PremiumPurchaseStatus.pending;
      case PurchaseStatus.purchased:
        return PremiumPurchaseStatus.purchased;
      case PurchaseStatus.restored:
        return PremiumPurchaseStatus.restored;
      case PurchaseStatus.error:
        return PremiumPurchaseStatus.error;
      case PurchaseStatus.canceled:
        return PremiumPurchaseStatus.canceled;
    }
  }
}

class _PurchaseWithRawDetails extends PremiumPurchase {
  const _PurchaseWithRawDetails({
    required super.productId,
    required super.status,
    required super.pendingCompletePurchase,
    required this.rawDetails,
    required this.completeRawPurchase,
    super.transactionId,
    super.localVerificationData,
    super.serverVerificationData,
    super.source,
    super.errorMessage,
  });

  final PurchaseDetails rawDetails;
  final Future<void> Function(PurchaseDetails purchase) completeRawPurchase;
}

extension InAppPurchaseCompletion on PurchaseService {
  Future<void> completeStorePurchase(PremiumPurchase purchase) async {
    if (purchase is _PurchaseWithRawDetails &&
        purchase.pendingCompletePurchase) {
      await purchase.completeRawPurchase(purchase.rawDetails);
      return;
    }
    await completePurchase(purchase);
  }
}
