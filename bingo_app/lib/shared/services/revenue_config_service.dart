import 'dart:developer';

import 'package:bingo_core/bingo_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

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

/// Leitura das flags de receita.
///
/// Os getters leem pelo [IConfigDriver] do GetIt (o mesmo que o core usa), e
/// não pelo `FirebaseRemoteConfig` direto: assim os overrides locais do
/// [OverridableConfigDriver] (dev/alpha) valem aqui também. O Firebase só
/// entra em [initialize], para registrar os defaults e buscar.
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

  /// Driver registrado pelo `BingoSDK.initialize`; nulo se o SDK não subiu
  /// (os getters caem nos [defaults]).
  static IConfigDriver? get _driver =>
      GetIt.I.isRegistered<IConfigDriver>() ? GetIt.I<IConfigDriver>() : null;

  /// Notifica quando as flags podem ter mudado (override local ou novo
  /// fetch). Em prod o driver não é [Listenable] e isto nunca dispara.
  static Listenable get listenable {
    final driver = _driver;
    return driver is Listenable ? driver as Listenable : _never;
  }

  static final Listenable _never = ChangeNotifier();

  static Future<void> initialize() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );

      await remoteConfig.setDefaults(defaults);
      await remoteConfig.fetchAndActivate();
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

  static bool _bool(String key) =>
      _driver?.getBool(key) ?? defaults[key] as bool;

  static int _int(String key) => _driver?.getInt(key) ?? defaults[key] as int;

  static String _string(String key) =>
      _driver?.getString(key) ?? defaults[key] as String;

  static RevenueModel get currentModel {
    final modelStr = _string(keyRevenueModel);
    if (modelStr == 'paywall_host') {
      return RevenueModel.paywallHost;
    }
    return RevenueModel.adSupported;
  }

  static int get maxFreePlayersPathA => _int(keyMaxFreePlayersPathA);

  static bool get soloModeEnabled => _bool(keySoloModeEnabled);

  static bool get adsEnabled => _bool(keyAdsEnabled);

  static bool get purchasesEnabled => _bool(keyPurchasesEnabled);

  static bool get isGloboPaid => _bool(keyIsGloboPaid);

  static bool get isHostPremium => _bool(keyIsHostPremium);

  /// Variante do paywall próprio (A/B via Experiments). Default `default`.
  static String get paywallVariant {
    final value = _string(keyPaywallVariant);
    return value.isEmpty ? 'default' : value;
  }

  /// `true` quando há limite de jogadores grátis por sala (modelo paywall_host).
  static bool get hasFreePlayerCap =>
      currentModel == RevenueModel.paywallHost && maxFreePlayersPathA > 0;
}
