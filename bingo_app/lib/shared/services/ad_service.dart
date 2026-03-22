import 'dart:developer';
import 'dart:io';

import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static InterstitialAd? _interstitialAd;

  static Future<void> initialize() async {
    if (!RevenueConfigService.adsEnabled) {
      log('Ads are disabled via Remote Config. Skipping initialization.');
      return;
    }
    try {
      await MobileAds.instance.initialize();
      log('Google Mobile Ads initialized.');
    } catch (e) {
      log('Error initializing Mobile Ads: $e');
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'ca-app-pub-8371522528180957/2105747837';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'ca-app-pub-8371522528180957/5761388983';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'ca-app-pub-8371522528180957/6264786014';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Carrega e exibe um Interstitial Ad
  static void loadInterstitialAd({
    required Function() onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) {
    if (!RevenueConfigService.adsEnabled) {
      log('Interstitial Ad loading skipped: Ads are disabled.');
      onAdFailedToLoad(LoadAdError(0, '', 'Ads Disabled', null));
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          log('Interstitial Ad loaded.');
          _interstitialAd = ad;
          onAdLoaded();
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Interstitial ad failed to load: $error');
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  static void showInterstitialAd({void Function()? onAdDismissed}) {
    if (_interstitialAd == null) {
      log('Warning: attempt to show interstitial before loaded.');
      if (onAdDismissed != null) onAdDismissed();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        if (onAdDismissed != null) {
          onAdDismissed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Failed to show interstitial ad: $error');
        ad.dispose();
        _interstitialAd = null;
        if (onAdDismissed != null) {
          onAdDismissed();
        }
      },
    );
    _interstitialAd!.show();
  }

  /// Carrega e exibe um App Open Ad
  static void showAppOpenAd() {
    if (!RevenueConfigService.adsEnabled) return;

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          log('App Open Ad loaded.');
          ad.show();
        },
        onAdFailedToLoad: (error) {
          log('App Open Ad failed to load: $error');
        },
      ),
    );
  }
}
