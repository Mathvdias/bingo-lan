import 'dart:developer';

import 'package:bingo_app/flavors/app_config.dart';

/// Environment configuration via `--dart-define=KEY=value` (CI / release).
/// Nunca commite chaves reais; use secrets no pipeline de build.
class Env {
  static const String revenueCatAndroidKey = String.fromEnvironment(
    'RC_ANDROID_KEY',
  );
  static const String revenueCatIosKey = String.fromEnvironment(
    'RC_IOS_KEY',
  );

  /// Chave do RevenueCat Test Store (`test_...`). Usada apenas no flavor dev
  /// para testar o paywall sem produtos reais na Play/App Store.
  static const String revenueCatTestStoreKey = String.fromEnvironment(
    'RC_TEST_STORE_KEY',
  );

  // Feature Flags / Debug
  static const bool enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: false,
  );
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// Chave do RevenueCat que o app deve usar para este [appConfig] e plataforma.
  ///
  /// Em dev, se `RC_TEST_STORE_KEY` estiver definida, ela tem prioridade
  /// (RevenueCat Test Store). Retorna string vazia quando não há chave.
  static String revenueCatKeyFor(AppConfig appConfig, {required bool isIOS}) {
    if (appConfig.isDev && revenueCatTestStoreKey.isNotEmpty) {
      return revenueCatTestStoreKey;
    }
    return isIOS ? revenueCatIosKey : revenueCatAndroidKey;
  }

  /// Em [Flavor.prod] exige as chaves do RevenueCat. Em dev apenas registra
  /// avisos no log.
  static void validate(AppConfig appConfig) {
    if (appConfig.isDev) {
      if (revenueCatTestStoreKey.isEmpty &&
          (revenueCatAndroidKey.isEmpty || revenueCatIosKey.isEmpty)) {
        log(
          'Env: RevenueCat ausente — defina RC_TEST_STORE_KEY (Test Store) ou '
          'RC_ANDROID_KEY/RC_IOS_KEY se precisar de compras.',
        );
      }
      return;
    }

    final missingKeys = <String>[];
    if (revenueCatAndroidKey.isEmpty) missingKeys.add('RC_ANDROID_KEY');
    if (revenueCatIosKey.isEmpty) missingKeys.add('RC_IOS_KEY');

    if (missingKeys.isNotEmpty) {
      throw Exception(
        'Build prod sem variáveis obrigatórias:\n'
        '${missingKeys.join('\n')}\n'
        'Passe via --dart-define ou configure o CI.',
      );
    }
  }

  static bool get isDev => environment == 'dev';
  static bool get isProd => environment == 'prod';
}
