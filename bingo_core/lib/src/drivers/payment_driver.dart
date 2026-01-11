import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'i_payment_driver.dart';

class PaymentDriver implements IPaymentDriver {
  final String _apiKey;
  final String _proEntitlementId = 'pro_access'; // Example entitlement ID

  PaymentDriver(this._apiKey);

  @override
  Future<void> init() async {
    try {
      await Purchases.configure(PurchasesConfiguration(_apiKey));
    } catch (e) {
      log('Error initializing payments: $e');
    }
  }

  @override
  Future<bool> get isProUser async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_proEntitlementId]?.isActive ??
          false;
    } catch (e) {
      // If error (e.g. network), default to false for safety
      log("Error checking pro status: $e");
      return false;
    }
  }

  @override
  Future<void> purchasePro() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        // Assume the first package is the pro subscription
        final package = offerings.current!.availablePackages.first;
        await Purchases.purchase(PurchaseParams.package(package));
      }
    } on PlatformException catch (e) {
      // Handle user cancelled, etc
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // show error
        log("Purchase error: $e");
      }
    } catch (e) {
      log("Purchase error: $e");
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      log("Restore purchase error: $e");
    }
  }
}
