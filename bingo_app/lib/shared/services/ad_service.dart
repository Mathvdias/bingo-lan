import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob com inicialização preguiçosa e consentimento UMP.
///
/// Regras:
/// - Nada é carregado se `ads_enabled` for false ou o usuário for premium.
/// - iOS ainda não tem ad units: os ids são `null` e tudo é pulado.
/// - Em debug usamos sempre os ids de teste oficiais do Google.
/// - `MobileAds.initialize` só roda após o UMP responder `canRequestAds()`.
class AdService {
  AdService._();

  // Android (produção)
  static const String _androidBannerUnitId =
      'ca-app-pub-8371522528180957/2105747837';
  static const String _androidInterstitialUnitId =
      'ca-app-pub-8371522528180957/5761388983';
  static const String _androidAppOpenUnitId =
      'ca-app-pub-8371522528180957/6264786014';

  // Android (ids de teste oficiais do Google)
  static const String _testBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppOpenUnitId =
      'ca-app-pub-3940256099942544/9257395921';

  static bool _initialized = false;
  static Future<bool>? _initializing;
  static Future<bool>? _consentFuture;

  static InterstitialAd? _interstitialAd;
  static AppOpenAd? _appOpenAd;
  static bool _appOpenShown = false;
  static bool _appOpenLoading = false;

  /// Enquanto `true` (paywall aberto) nenhum anúncio de tela cheia é exibido.
  static bool suppressFullScreenAds = false;

  static bool get _platformSupported => !kIsWeb && Platform.isAndroid;

  static String? _unitId({required String prod, required String test}) {
    if (!_platformSupported) return null;
    return kDebugMode ? test : prod;
  }

  /// Unit id do banner ou `null` quando a plataforma não tem anúncios.
  static String? get bannerAdUnitId =>
      _unitId(prod: _androidBannerUnitId, test: _testBannerUnitId);

  /// Unit id do interstitial ou `null` quando a plataforma não tem anúncios.
  static String? get interstitialAdUnitId =>
      _unitId(prod: _androidInterstitialUnitId, test: _testInterstitialUnitId);

  /// Unit id do app open ou `null` quando a plataforma não tem anúncios.
  static String? get appOpenAdUnitId =>
      _unitId(prod: _androidAppOpenUnitId, test: _testAppOpenUnitId);

  /// Gate único para qualquer superfície de anúncio.
  static bool get canShowAds =>
      _platformSupported &&
      RevenueConfigService.adsEnabled &&
      !SubscriptionService.isPremium.value;

  /// Coleta consentimento (UMP) uma única vez e devolve `canRequestAds()`.
  static Future<bool> gatherConsent() {
    _consentFuture ??= _gatherConsent();
    return _consentFuture!;
  }

  static Future<bool> _gatherConsent() async {
    if (!_platformSupported) return false;
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
              if (formError != null) {
                log('UMP: formulário falhou: ${formError.message}');
              }
              finish();
            });
          } catch (e) {
            log('UMP: erro ao exibir formulário: $e');
            finish();
          }
        },
        (error) {
          log('UMP: falha ao atualizar consentimento: ${error.message}');
          finish();
        },
      );
      await done.future;
      final canRequest = await ConsentInformation.instance.canRequestAds();
      if (kDebugMode) log('UMP: canRequestAds=$canRequest');
      return canRequest;
    } catch (e) {
      log('UMP: erro inesperado: $e');
      finish();
      return false;
    }
  }

  /// Inicializa o SDK na primeira vez que um anúncio é pedido.
  ///
  /// Retorna `true` quando anúncios podem ser carregados agora.
  static Future<bool> ensureInitialized() async {
    if (!canShowAds) return false;
    if (_initialized) return true;
    _initializing ??= _initialize();
    final ok = await _initializing!;
    if (!ok) _initializing = null; // permite tentar de novo depois
    return ok;
  }

  static Future<bool> _initialize() async {
    try {
      final canRequest = await gatherConsent();
      if (!canRequest) {
        log('AdMob: sem consentimento para anúncios; inicialização pulada.');
        return false;
      }
      await MobileAds.instance.initialize();
      _initialized = true;
      log('Google Mobile Ads inicializado.');
      return true;
    } catch (e) {
      log('AdMob: falha ao inicializar: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------- Interstitial

  /// Pré-carrega um interstitial (ex.: saída da sala do host).
  static Future<void> loadInterstitialAd({
    VoidCallback? onAdLoaded,
    void Function(LoadAdError error)? onAdFailedToLoad,
  }) async {
    final unitId = interstitialAdUnitId;
    if (unitId == null || !await ensureInitialized()) {
      if (kDebugMode) log('Interstitial pulado: anúncios indisponíveis.');
      onAdFailedToLoad?.call(LoadAdError(0, 'bingo', 'Ads unavailable', null));
      return;
    }

    await InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) log('Interstitial falhou ao carregar: $error');
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Exibe o interstitial carregado; se não houver (ou o usuário for premium)
  /// chama [onAdDismissed] imediatamente.
  static void showInterstitialAd({VoidCallback? onAdDismissed}) {
    final ad = _interstitialAd;
    _interstitialAd = null;
    if (ad == null || !canShowAds || suppressFullScreenAds) {
      ad?.dispose();
      onAdDismissed?.call();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) log('Interstitial falhou ao exibir: $error');
        ad.dispose();
        onAdDismissed?.call();
      },
    );
    ad.show();
  }

  // ------------------------------------------------------------------- App Open

  /// Pré-carrega o App Open no lobby e exibe uma única vez quando carregar.
  static Future<void> preloadAppOpenAd() async {
    if (_appOpenShown || _appOpenLoading || _appOpenAd != null) return;
    final unitId = appOpenAdUnitId;
    if (unitId == null) return;

    _appOpenLoading = true;
    if (!await ensureInitialized()) {
      _appOpenLoading = false;
      return;
    }

    await AppOpenAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoading = false;
          _appOpenAd = ad;
          _showAppOpenAdOnce();
        },
        onAdFailedToLoad: (error) {
          _appOpenLoading = false;
          if (kDebugMode) log('App Open falhou ao carregar: $error');
        },
      ),
    );
  }

  static void _showAppOpenAdOnce() {
    final ad = _appOpenAd;
    if (ad == null) return;
    if (_appOpenShown || suppressFullScreenAds || !canShowAds) {
      // Nunca sobre o paywall nem para premium: descarta e não tenta de novo.
      ad.dispose();
      _appOpenAd = null;
      return;
    }
    _appOpenShown = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) log('App Open falhou ao exibir: $error');
        ad.dispose();
        _appOpenAd = null;
      },
    );
    ad.show();
  }
}
