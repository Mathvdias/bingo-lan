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

  static const String clarityProjectId = String.fromEnvironment(
    'CLARITY_PROJECT_ID',
  );

  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
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

  /// Em [Flavor.prod] exige RC e Clarity. Em dev apenas registra avisos no log.
  static void validate(AppConfig appConfig) {
    if (appConfig.isDev) {
      if (revenueCatAndroidKey.isEmpty || revenueCatIosKey.isEmpty) {
        log(
          'Env: RevenueCat ausente — defina RC_ANDROID_KEY e RC_IOS_KEY se precisar de compras.',
        );
      }
      if (clarityProjectId.isEmpty) {
        log('Env: CLARITY_PROJECT_ID ausente — Microsoft Clarity não será configurado.');
      }
      if (geminiApiKey.isEmpty) {
        log('Env: GEMINI_API_KEY ausente — piadas de IA usam fallback local.');
      }
      return;
    }

    final missingKeys = <String>[];
    if (revenueCatAndroidKey.isEmpty) missingKeys.add('RC_ANDROID_KEY');
    if (revenueCatIosKey.isEmpty) missingKeys.add('RC_IOS_KEY');
    if (clarityProjectId.isEmpty) missingKeys.add('CLARITY_PROJECT_ID');

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
