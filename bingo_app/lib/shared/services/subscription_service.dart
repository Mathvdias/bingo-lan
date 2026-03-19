import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:bingo_app/core/config/env.dart';
import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

/// Service for managing in-app purchases and subscriptions via RevenueCat
class SubscriptionService {
  static const String weeklyProductId = 'weekly_subscription';
  static const String annualProductId = 'annual_subscription';
  static const String lifetimeProductId = 'lifetime_purchase';

  /// Stream of premium status
  static final _premiumStatusController = StreamController<bool>.broadcast();
  static Stream<bool> get premiumStatusStream =>
      _premiumStatusController.stream;

  /// Initialize RevenueCat SDK
  static Future<void> initialize({String? apiKey, String? userId}) async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      final key =
          apiKey ??
          (Platform.isIOS ? Env.revenueCatIosKey : Env.revenueCatAndroidKey);

      final configuration = PurchasesConfiguration(key);
      if (userId != null) {
        configuration.appUserID = userId;
      }

      await Purchases.configure(configuration);

      // Listen for updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updatePremiumStatus(customerInfo);
      });

      log('RevenueCat initialized successfully');
    } catch (e) {
      log('Error initializing RevenueCat: $e');
      rethrow;
    }
  }

  /// Helper to update local stream
  static void _updatePremiumStatus(CustomerInfo? info) {
    if (info == null) return;
    final isPremium = info.entitlements.all['premium']?.isActive ?? false;
    _premiumStatusController.add(isPremium);
  }

  /// Set user ID (call after authentication)
  static Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      log('RevenueCat user ID set: $userId');
      await checkSubscriptionStatus(); // Initial check
    } catch (e) {
      log('Error setting RevenueCat user ID: $e');
    }
  }

  /// Get available offerings
  static Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      log('Error getting offerings: $e');
      return null;
    }
  }

  /// Purchase a product
  static Future<CustomerInfo?> purchaseProduct(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;

      log('Purchase successful: ${package.identifier}');
      return customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        log('User cancelled the purchase');
      } else {
        log('Error making purchase: $e');
      }
      return null;
    }
  }

  /// Restore purchases
  static Future<CustomerInfo?> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      log('Purchases restored successfully');
      return customerInfo;
    } catch (e) {
      log('Error restoring purchases: $e');
      return null;
    }
  }

  /// Check if user has active subscription and update stream
  static Future<bool> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      log('Error checking subscription status: $e');
      return false;
    }
  }

  /// Get customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      log('Error getting customer info: $e');
      return null;
    }
  }



  /// Sign out user
  static Future<void> signOut() async {
    try {
      await Purchases.logOut();
      log('RevenueCat user logged out');
    } catch (e) {
      log('Error logging out from RevenueCat: $e');
    }
  }
}
