/// Defines the contract for a payment driver, used for in-app purchases.
/// This will be implemented using a service like RevenueCat.
abstract class IPaymentDriver {
  /// Initializes the payment service.
  Future<void> init();

  /// A getter to check if the current user has an active "pro" subscription.
  Future<bool> get isProUser;

  /// Initiates the purchase flow for the "pro" subscription.
  Future<void> purchasePro();

  /// Restores previous purchases for the user.
  Future<void> restorePurchases();
}
