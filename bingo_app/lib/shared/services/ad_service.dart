import 'dart:io';
import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      log('Google Mobile Ads initialized.');
    } catch (e) {
      log('Error initializing Mobile Ads: $e');
    }
  }

  // TODO: Replace with your actual Ad Unit IDs for production
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Google Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Google Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Google Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Google Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9257395915'; // Google Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5575463023'; // Google Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Carrega e exibe um Interstitial Ad
  static void showInterstitialAd({void Function()? onAdDismissed}) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          log('Interstitial Ad loaded.');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (onAdDismissed != null) {
                onAdDismissed();
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('Failed to show interstitial ad: $error');
              ad.dispose();
              if (onAdDismissed != null) {
                onAdDismissed();
              }
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Interstitial ad failed to load: $error');
          if (onAdDismissed != null) {
            onAdDismissed();
          }
        },
      ),
    );
  }

  /// Carrega e exibe um App Open Ad
  static void showAppOpenAd() {
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
      orientation: AppOpenAd.orientationPortrait,
    );
  }
}
