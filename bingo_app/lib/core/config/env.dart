/// Environment configuration manager
///
/// This class handles environment variables passed via --dart-define
/// Usage: flutter run --dart-define=SUPABASE_URL=...
class Env {
  // Supabase Configuration completely removed

  // RevenueCat Configuration
  static const String revenueCatAndroidKey = String.fromEnvironment(
    'RC_ANDROID_KEY',
    defaultValue: 'REDACTED',
  );
  static const String revenueCatIosKey = String.fromEnvironment(
    'RC_IOS_KEY',
    defaultValue: 'REDACTED',
  );

  // Clarity Configuration
  static const String clarityProjectId = String.fromEnvironment(
    'CLARITY_PROJECT_ID',
    defaultValue: 'REDACTED',
  );

  // AI Configuration
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'REDACTED',
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

  /// Validates that all required environment variables are present
  static void validate() {
    final missingKeys = <String>[];


    if (revenueCatAndroidKey.isEmpty) missingKeys.add('RC_ANDROID_KEY');
    if (revenueCatIosKey.isEmpty) missingKeys.add('RC_IOS_KEY');
    if (clarityProjectId.isEmpty) missingKeys.add('CLARITY_PROJECT_ID');
    // Gemini key is optional for now unless using AI feature, but let's check it if we enable AI
    // For now, let's just log or treat as optional if we want to allow running without it locally
    // If the user wants to enforce it:
    if (geminiApiKey.isEmpty) missingKeys.add('GEMINI_API_KEY');

    if (missingKeys.isNotEmpty) {
      throw Exception(
        'Missing required environment variables:\n'
        '${missingKeys.join('\n')}\n'
        'Please Provide these via --dart-define or launch.json',
      );
    }
  }

  static bool get isDev => environment == 'dev';
  static bool get isProd => environment == 'prod';
}
