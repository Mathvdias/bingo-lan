import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Chaves no Firebase Remote Config (console → Remote Config → parâmetros).
/// Os defaults abaixo espelham `remoteconfig/prod.template.json`:
/// - `purchases_enabled` (bool): botão de upgrade, paywall e auto-globo.
/// - `ads_enabled` (bool): liga todos os anúncios.
/// - `revenue_model` (String): `paywall_host` | `ad_supported`.
/// - `max_free_players_path_a` (int): jogadores grátis por sala.
/// - `solo_mode_enabled` (bool): modo individual no lobby.
/// - `is_globo_paid` (bool): cobra pelo auto-globo.
/// - `is_host_premium` (bool): cobra para criar sala.
/// - `paywall_variant` (String): variante do paywall para A/B.
enum RevenueModel {
  /// Caminho A: grátis até N jogadores; o host vê o paywall no N+1.
  paywallHost,

  /// Caminho B: grátis sem limite; anúncios para host e jogadores.
  adSupported,
}

class RevenueConfigService {
  RevenueConfigService._();

  static const String keyPurchasesEnabled = 'purchases_enabled';
  static const String keyAdsEnabled = 'ads_enabled';
  static const String keyRevenueModel = 'revenue_model';
  static const String keyMaxFreePlayersPathA = 'max_free_players_path_a';
  static const String keySoloModeEnabled = 'solo_mode_enabled';
  static const String keyIsGloboPaid = 'is_globo_paid';
  static const String keyIsHostPremium = 'is_host_premium';
  static const String keyPaywallVariant = 'paywall_variant';

  /// Defaults idênticos a `remoteconfig/prod.template.json`.
  static const Map<String, dynamic> defaults = {
    keyPurchasesEnabled: true,
    keyAdsEnabled: false,
    keyRevenueModel: 'paywall_host',
    keyMaxFreePlayersPathA: 10,
    keySoloModeEnabled: true,
    keyIsGloboPaid: false,
    keyIsHostPremium: false,
    keyPaywallVariant: 'default',
  };

  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults(defaults);
      await _remoteConfig.fetchAndActivate();
      if (kDebugMode) {
        log(
          'Remote Config pronto. revenue_model=${currentModel.name} '
          'purchases=$purchasesEnabled ads=$adsEnabled '
          'paywall_variant=$paywallVariant',
        );
      }
    } catch (e) {
      log('Error initializing Remote Config: $e');
    }
  }

  static RevenueModel get currentModel {
    final modelStr = _remoteConfig.getString(keyRevenueModel);
    if (modelStr == 'paywall_host') {
      return RevenueModel.paywallHost;
    }
    return RevenueModel.adSupported;
  }

  static int get maxFreePlayersPathA =>
      _remoteConfig.getInt(keyMaxFreePlayersPathA);

  static bool get soloModeEnabled => _remoteConfig.getBool(keySoloModeEnabled);

  static bool get adsEnabled => _remoteConfig.getBool(keyAdsEnabled);

  static bool get purchasesEnabled =>
      _remoteConfig.getBool(keyPurchasesEnabled);

  static bool get isGloboPaid => _remoteConfig.getBool(keyIsGloboPaid);

  static bool get isHostPremium => _remoteConfig.getBool(keyIsHostPremium);

  /// Variante do paywall próprio (A/B via Experiments). Default `default`.
  static String get paywallVariant {
    final value = _remoteConfig.getString(keyPaywallVariant);
    return value.isEmpty ? 'default' : value;
  }

  /// `true` quando há limite de jogadores grátis por sala (modelo paywall_host).
  static bool get hasFreePlayerCap =>
      currentModel == RevenueModel.paywallHost && maxFreePlayersPathA > 0;
}
