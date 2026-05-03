import 'premium_models.dart';

abstract interface class PurchaseService {
  Stream<PremiumPurchase> get purchaseStream;

  Future<bool> isAvailable();

  Future<List<PremiumProduct>> queryPremiumProducts();

  Future<void> buy(PremiumProduct product);

  Future<void> restorePurchases();

  Future<void> completePurchase(PremiumPurchase purchase);
}
