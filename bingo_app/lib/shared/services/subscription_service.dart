import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:bingo_app/shared/services/supabase_service.dart';
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
        _syncPurchaseToSupabase(customerInfo);
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

      // Sync purchase to Supabase
      await _syncPurchaseToSupabase(customerInfo);

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

      // Sync restored purchases to Supabase
      await _syncPurchaseToSupabase(customerInfo);

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

  /// Sync purchase to Supabase
  static Future<void> _syncPurchaseToSupabase(CustomerInfo customerInfo) async {
    try {
      // Get active entitlements
      final activeEntitlements = customerInfo.entitlements.active;

      if (activeEntitlements.isEmpty) {
        log('No active entitlements to sync');
        return;
      }

      // Get the first active entitlement (assuming one subscription)
      final entitlement = activeEntitlements.values.first;

      // Determine subscription type
      String subscriptionType = 'unknown';
      if (entitlement.productIdentifier.contains('weekly')) {
        subscriptionType = 'weekly';
      } else if (entitlement.productIdentifier.contains('annual')) {
        subscriptionType = 'annual';
      } else if (entitlement.productIdentifier.contains('lifetime')) {
        subscriptionType = 'lifetime';
      }

      // Get current user ID
      final userId = customerInfo.originalAppUserId;

      await SupabaseService.client.from('purchases').upsert({
        'user_id': userId,
        'product_id': entitlement.productIdentifier,
        'subscription_type': subscriptionType,
        'purchase_date': entitlement.originalPurchaseDate,
        'expiry_date': entitlement.expirationDate,
        'is_active': entitlement.isActive,
        'revenuecat_transaction_id': entitlement.identifier,
        'revenuecat_metadata': {}, // CustomerInfo no longer has toJson()
      }, onConflict: 'user_id');

      log('Purchase synced to Supabase');
    } catch (e) {
      log('Error syncing purchase to Supabase: $e');
      // Don't rethrow - allow purchase to complete even if sync fails
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
