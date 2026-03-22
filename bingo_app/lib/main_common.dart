import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:bingo_app/core/config/env.dart';
import 'package:bingo_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:bingo_app/shared/di/service_locator.dart';
import 'package:bingo_app/shared/providers/locale_provider.dart';
import 'package:bingo_app/shared/router.dart';
import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/services/att_service.dart';
import 'package:bingo_app/shared/services/clarity_service.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/app_fonts.dart';
import 'package:bingo_app/shared/ui/app_theme.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart' show AppColors;
import 'package:bingo_core/bingo_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'firebase_options.dart';
import 'flavors/app_config.dart';

Future<void> mainCommon(AppConfig appConfig) async {
  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Ensure Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  await preloadBingoFonts();

  // Initialize Firebase
  // Note: If you have different firebase_options for Dev/Prod, handle switching here
  // using appConfig.flavor.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    kReleaseMode,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  GetIt.I.registerSingleton<AppConfig>(appConfig);

  setupServiceLocator();

  Env.validate(appConfig);

  // 2. Initialize the Bingo SDK
  try {
    await BingoSDK.initialize(
      revenueCatKey: Platform.isIOS
          ? Env.revenueCatIosKey
          : Env.revenueCatAndroidKey,
    );
  } catch (e) {
    log('BingoSDK (Core) initialization failed: $e');
  }

  // 2.5 Initialize RevenueCat for subscriptions (non-blocking)
  try {
    await SubscriptionService.initialize().timeout(const Duration(seconds: 5));
  } catch (e) {
    // Ignore RevenueCat errors during development
    // App will work without monetization features
    log('RevenueCat initialization skipped: $e');
  }

  // Track app open (non-blocking)
  try {
    AnalyticsService.trackAppOpen();
  } catch (e) {
    log('Analytics tracking skipped: $e');
  }

  // 3. Fetch and activate remote feature flags (core SDK).
  final config = GetIt.I.get<IConfigDriver>();
  await config.fetchAndActivate();

  // 4. Remote Config da receita, ATT (iOS) se anúncios ativos, depois AdMob.
  await RevenueConfigService.initialize();
  if (RevenueConfigService.adsEnabled) {
    await AttService.requestIfNeeded();
  }
  await AdService.initialize();

  // 5. Initialize global Showcase scope for app tours
  ShowcaseView.register();

  // Run the main Flutter application wrapped with Clarity and Provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: ClarityService.wrapApp(BingoApp(appConfig: appConfig)),
    ),
  );
}

class BingoApp extends StatelessWidget {
  final AppConfig appConfig;

  const BingoApp({super.key, required this.appConfig});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      restorationScopeId: 'bingo_app_root',
      debugShowCheckedModeBanner: false,
      title: appConfig.appTitle,
      locale: localeProvider.locale,

      // Localization Configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English (Primary)
        Locale('pt', ''), // Portuguese
        Locale('es', ''), // Spanish
        Locale('fr', ''), // French
        Locale('it', ''), // Italian
        Locale('ja', ''), // Japanese
      ],

      theme: bingoTheme,
      themeMode: ThemeMode.light, // Enforce light mode
      routerConfig: router,
    );
  }
}
