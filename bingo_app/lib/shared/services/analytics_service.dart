import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:developer';

/// Service for tracking analytics events via Firebase Analytics
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver? _observer;

  /// Get the observer for router integration
  static FirebaseAnalyticsObserver get observer {
    _observer ??= FirebaseAnalyticsObserver(analytics: _analytics);
    return _observer!;
  }

  // ==================== App Lifecycle ====================

  /// Track app open
  static Future<void> trackAppOpen() async {
    try {
      await _analytics.logAppOpen();
      log('Analytics: App opened');
    } catch (e) {
      log('Error tracking app open: $e');
    }
  }

  // ==================== Screen Views ====================

  /// Track screen view
  static Future<void> trackScreen(
    String screenName, {
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      log('Analytics: Screen viewed - $screenName');
    } catch (e) {
      log('Error tracking screen: $e');
    }
  }

  // ==================== User Properties ====================

  /// Set user ID
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      log('Analytics: User ID set - $userId');
    } catch (e) {
      log('Error setting user ID: $e');
    }
  }

  /// Set user property
  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      log('Analytics: User property set - $name: $value');
    } catch (e) {
      log('Error setting user property: $e');
    }
  }

  /// Set subscription status
  static Future<void> setSubscriptionStatus(bool isPremium) async {
    await setUserProperty(
      'subscription_status',
      isPremium ? 'premium' : 'free',
    );
  }

  // ==================== Authentication Events ====================

  /// Track sign up
  static Future<void> trackSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      log('Analytics: Sign up - $method');
    } catch (e) {
      log('Error tracking sign up: $e');
    }
  }

  /// Track login
  static Future<void> trackLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      log('Analytics: Login - $method');
    } catch (e) {
      log('Error tracking login: $e');
    }
  }

  // ==================== Game Events ====================

  /// Track room creation
  static Future<void> trackCreateRoom(String roomId) async {
    try {
      await _analytics.logEvent(
        name: 'create_room',
        parameters: {
          'room_id': roomId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      log('Analytics: Room created - $roomId');
    } catch (e) {
      log('Error tracking create room: $e');
    }
  }

  /// Track room join
  static Future<void> trackJoinRoom(String roomId) async {
    try {
      await _analytics.logEvent(
        name: 'join_room',
        parameters: {
          'room_id': roomId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      log('Analytics: Room joined - $roomId');
    } catch (e) {
      log('Error tracking join room: $e');
    }
  }

  /// Track game completion
  static Future<void> trackGameComplete(
    String roomId,
    int duration,
    int players,
  ) async {
    try {
      await _analytics.logEvent(
        name: 'game_complete',
        parameters: {
          'room_id': roomId,
          'duration_seconds': duration,
          'player_count': players,
        },
      );
      log('Analytics: Game completed - $roomId');
    } catch (e) {
      log('Error tracking game complete: $e');
    }
  }

  /// Track bingo win
  static Future<void> trackBingoWin(String roomId) async {
    try {
      await _analytics.logEvent(
        name: 'bingo_win',
        parameters: {'room_id': roomId},
      );
      log('Analytics: Bingo won - $roomId');
    } catch (e) {
      log('Error tracking bingo win: $e');
    }
  }

  // ==================== Paywall & Purchase Events ====================

  /// Track paywall view
  static Future<void> trackPaywallView(String source) async {
    try {
      await _analytics.logEvent(
        name: 'paywall_view',
        parameters: {
          'source': source, // 'onboarding', 'feature_gate', 'settings', etc.
        },
      );
      log('Analytics: Paywall viewed - $source');
    } catch (e) {
      log('Error tracking paywall view: $e');
    }
  }

  /// Track purchase intent (button clicked)
  static Future<void> trackPurchaseIntent(String productId) async {
    try {
      await _analytics.logEvent(
        name: 'begin_checkout',
        parameters: {
          'items': [
            {'item_id': productId, 'item_name': productId},
          ],
        },
      );
      log('Analytics: Purchase intent - $productId');
    } catch (e) {
      log('Error tracking purchase intent: $e');
    }
  }

  /// Track successful purchase
  static Future<void> trackPurchase({
    required String productId,
    required double value,
    required String currency,
    String? transactionId,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: value,
        transactionId: transactionId,
        parameters: {
          'items': [
            {'item_id': productId, 'item_name': productId, 'price': value},
          ],
        },
      );
      log('Analytics: Purchase completed - $productId ($value $currency)');
    } catch (e) {
      log('Error tracking purchase: $e');
    }
  }

  /// Track subscription renewal
  static Future<void> trackSubscriptionRenewal(String productId) async {
    try {
      await _analytics.logEvent(
        name: 'subscription_renewal',
        parameters: {'product_id': productId},
      );
      log('Analytics: Subscription renewed - $productId');
    } catch (e) {
      log('Error tracking renewal: $e');
    }
  }

  // ==================== Feature Usage ====================

  /// Track feature usage
  static Future<void> trackFeatureUsed(String featureName) async {
    try {
      await _analytics.logEvent(
        name: 'feature_used',
        parameters: {'feature_name': featureName},
      );
      log('Analytics: Feature used - $featureName');
    } catch (e) {
      log('Error tracking feature usage: $e');
    }
  }

  /// Track share
  static Future<void> trackShare(String contentType, String itemId) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: 'qr_code',
      );
      log('Analytics: Content shared - $contentType');
    } catch (e) {
      log('Error tracking share: $e');
    }
  }

  // ==================== Error Tracking ====================

  /// Track error
  static Future<void> trackError(
    String errorMessage, {
    String? stackTrace,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {'error_message': errorMessage, 'stack_trace': ?stackTrace},
      );
      log('Analytics: Error tracked - $errorMessage');
    } catch (e) {
      log('Error tracking error: $e');
    }
  }

  // ==================== Custom Events ====================

  /// Track custom event
  static Future<void> trackCustomEvent(
    String eventName,
    Map<String, Object>? parameters,
  ) async {
    try {
      await _analytics.logEvent(name: eventName, parameters: parameters);
      log('Analytics: Custom event - $eventName');
    } catch (e) {
      log('Error tracking custom event: $e');
    }
  }
}
