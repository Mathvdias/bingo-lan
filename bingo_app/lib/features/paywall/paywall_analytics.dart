import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Funil do paywall. Interface pequena para o ViewModel ser testável.
abstract class PaywallAnalytics {
  void paywallViewed(String source);
  void purchaseIntent(String productId);
  void purchased(Package package);
  void restored(String result);
}

/// Envia o funil para o Firebase Analytics via [AnalyticsService].
class FirebasePaywallAnalytics implements PaywallAnalytics {
  const FirebasePaywallAnalytics();

  @override
  void paywallViewed(String source) {
    AnalyticsService.trackPaywallView(source);
  }

  @override
  void purchaseIntent(String productId) {
    AnalyticsService.trackPurchaseIntent(productId);
  }

  @override
  void purchased(Package package) {
    final product = package.storeProduct;
    AnalyticsService.trackPurchase(
      productId: product.identifier,
      value: product.price,
      currency: product.currencyCode,
    );
  }

  @override
  void restored(String result) {
    AnalyticsService.trackRestorePurchases(result);
  }
}
