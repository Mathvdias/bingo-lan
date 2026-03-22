import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// iOS 14+ — pedido de rastreamento antes do AdMob (recomendação Apple / Google UMP).
class AttService {
  static Future<void> requestIfNeeded() async {
    if (!Platform.isIOS) return;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      log('ATT request failed: $e');
    }
  }
}
