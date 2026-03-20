import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:developer';

enum RevenueModel {
  // Caminho A: Grátis até 10 jogadores; Host entra num Paywall no 11º jogador.
  paywallHost,
  // Caminho B: Grátis sem limite; Ads para Host e Banners para Jogadores.
  adSupported,
}

class RevenueConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // Default interval
      ));

      await _remoteConfig.setDefaults(const {
        'revenue_model': 'ad_supported',
        'max_free_players_path_a': 10,
        'solo_mode_enabled': true,
        'ads_enabled': false,
        'purchases_enabled': false,
      });

      await _remoteConfig.fetchAndActivate();
      log('Remote config initialized. Active model: ${currentModel.name}');
    } catch (e) {
      log('Error initializing Remote Config: $e');
    }
  }

  static RevenueModel get currentModel {
    final modelStr = _remoteConfig.getString('revenue_model');
    if (modelStr == 'paywall_host') {
      return RevenueModel.paywallHost;
    }
    // Default fallback is adSupported
    return RevenueModel.adSupported;
  }

  static int get maxFreePlayersPathA {
    return _remoteConfig.getInt('max_free_players_path_a');
  }
  static bool get soloModeEnabled {
    return _remoteConfig.getBool('solo_mode_enabled');
  }

  static bool get adsEnabled {
    return _remoteConfig.getBool('ads_enabled');
  }

  static bool get purchasesEnabled {
    return _remoteConfig.getBool('purchases_enabled');
  }
}
