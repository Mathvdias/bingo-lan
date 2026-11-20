import 'dart:developer';

import 'package:bingo_app/flavors/app_config.dart';
import 'package:flutter/foundation.dart';

/// Environment configuration via `--dart-define=KEY=value` (CI / release).
/// Nunca commite chaves reais; use secrets no pipeline de build.
class Env {
  static const String revenueCatAndroidKey = String.fromEnvironment(
    'RC_ANDROID_KEY',
  );
  static const String revenueCatIosKey = String.fromEnvironment('RC_IOS_KEY');

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
  /// (RevenueCat Test Store). Alpha usa as chaves de loja, como a prod.
  /// Retorna string vazia quando não há chave.
  static String revenueCatKeyFor(AppConfig appConfig, {required bool isIOS}) {
    if (appConfig.isDev && revenueCatTestStoreKey.isNotEmpty) {
      return revenueCatTestStoreKey;
    }
    return isIOS ? revenueCatIosKey : revenueCatAndroidKey;
  }

  /// Nomes das variáveis obrigatórias que faltam para [appConfig] na
  /// plataforma atual. Em prod (e alpha) só a chave da plataforma em execução
  /// conta: um build Android não precisa de `RC_IOS_KEY` e vice-versa.
  ///
  /// Puro para ser testável: as chaves entram por parâmetro (por padrão as
  /// constantes de `--dart-define`).
  static List<String> missingKeys(
    AppConfig appConfig, {
    required bool isIOS,
    String androidKey = revenueCatAndroidKey,
    String iosKey = revenueCatIosKey,
    String testStoreKey = revenueCatTestStoreKey,
  }) {
    if (appConfig.isDev) {
      if (testStoreKey.isNotEmpty) return const [];
      final key = isIOS ? iosKey : androidKey;
      return key.isEmpty
          ? [isIOS ? 'RC_IOS_KEY' : 'RC_ANDROID_KEY', 'RC_TEST_STORE_KEY']
          : const [];
    }
    final key = isIOS ? iosKey : androidKey;
    return key.isEmpty ? [isIOS ? 'RC_IOS_KEY' : 'RC_ANDROID_KEY'] : const [];
  }

  /// Verifica as variáveis de ambiente e devolve a mensagem de erro, ou
  /// `null` quando está tudo certo.
  ///
  /// NUNCA lança: uma chave ausente desliga as compras, não o app. Antes
  /// disto um build prod sem `RC_IOS_KEY` lançava aqui, a exceção era
  /// engolida pelo handler do Crashlytics e o app ficava preso na splash.
  static String? validate(AppConfig appConfig, {bool? isIOS}) {
    final ios = isIOS ?? (defaultTargetPlatform == TargetPlatform.iOS);
    final missing = missingKeys(appConfig, isIOS: ios);
    if (missing.isEmpty) return null;
    final message = appConfig.isDev
        ? 'Env: RevenueCat ausente — defina RC_TEST_STORE_KEY (Test Store) ou '
              '${missing.first} se precisar de compras.'
        : 'Build prod sem ${missing.join(', ')}: compras desativadas. '
              'Passe via --dart-define ou configure o CI.';
    log(message);
    return message;
  }

  /// Edição aberta: build sem chave do RevenueCat para a plataforma atual
  /// (release do GitHub, forks). Tudo liberado, sem compras e sem anúncios.
  static bool isOpenEdition(AppConfig appConfig, {bool? isIOS}) =>
      revenueCatKeyFor(
        appConfig,
        isIOS: isIOS ?? (defaultTargetPlatform == TargetPlatform.iOS),
      ).isEmpty;

  static bool get isDev => environment == 'dev';
  static bool get isAlpha => environment == 'alpha';
  static bool get isProd => environment == 'prod';

  /// Ferramentas de depuração pelo `--dart-define=ENVIRONMENT`: dev e alpha.
  /// A fonte de verdade em tempo de execução é `AppConfig.hasDebugTools`
  /// (vem do flavor do entrypoint); esta é a versão em tempo de compilação.
  static bool get hasDebugTools => isDev || isAlpha;
}
