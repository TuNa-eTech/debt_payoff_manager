import '../../../domain/entities/user_settings.dart';
import 'premium_models.dart';

abstract interface class EntitlementService {
  Stream<PremiumEntitlementEvent> watchEvents();

  Future<void> init();

  Future<EntitlementSnapshot> refreshEntitlement();

  Future<EntitlementSnapshot> validatePurchase(PremiumPurchase purchase);

  Future<void> dispose();

  bool isPremiumActive(UserSettings? settings);
}
