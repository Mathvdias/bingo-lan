import 'package:flutter_jailbreak__root_detection/flutter_jailbreak__root_detection.dart';

import '../drivers/i_config_driver.dart';
import '../drivers/i_payment_driver.dart';

/// Service to manage access to premium features based on remote config and payment status.
/// It also includes a security check for rooted/jailbroken devices.
class AccessControlService {
  final IConfigDriver _config;
  final IPaymentDriver _payment;

  AccessControlService({
    required IConfigDriver config,
    required IPaymentDriver payment,
  }) : _config = config,
       _payment = payment;

  /// The master logic to determine if a feature is accessible.
  /// A feature is accessible if:
  /// 1. The remote config flag for it is `false` (i.e., it's a free feature).
  /// 2. The user has paid and is a "pro" user.
  Future<bool> canAccess(String featureKey) async {
    final bool isPaidFeature = _config.getBool(featureKey);
    if (!isPaidFeature) {
      return true; // Feature is free for everyone.
    }

    // For paid features, check if the user is a pro user.
    return await _payment.isProUser;
  }

  /// Checks if the app is running in a secure environment.
  /// It returns `false` if the device is detected as jailbroken or rooted.
  ///
  /// Produto: decidir se bloqueia IAP, só avisa ou apenas registra analytics.
  /// Esta API não bloqueia sozinha — combine com fluxo de paywall se necessário.
  Future<bool> isSecureEnvironment() async {
    try {
      final bool isJailbroken = await FlutterJailbreakDetection.jailbroken;
      return !isJailbroken;
    } catch (e) {
      // If the check fails for any reason, assume it's not a secure environment
      // as a fallback, but you might want to log this error.
      return false;
    }
  }
}
