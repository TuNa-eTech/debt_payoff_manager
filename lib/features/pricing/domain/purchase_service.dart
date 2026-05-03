import 'premium_models.dart';

abstract interface class PurchaseService {
  Stream<PremiumPurchase> get purchaseStream;

  Future<bool> isAvailable();

  Future<List<PremiumProduct>> queryPremiumProducts();

  Future<List<PremiumPurchase>> queryPastPurchases();

  Future<void> buy(PremiumProduct product);

  Future<void> restorePurchases();

  Future<void> openSubscriptionManagement();

  Future<void> completePurchase(PremiumPurchase purchase);
}
