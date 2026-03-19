import 'dart:io';
import 'dart:developer';
import 'package:bingo_app/core/config/env.dart';
import 'package:bingo_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:bingo_app/shared/di/service_locator.dart';
import 'package:bingo_app/shared/router.dart';
import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/services/clarity_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/app_theme.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart' show AppColors;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  // Initialize Firebase
  // Note: If you have different firebase_options for Dev/Prod, handle switching here
  // using appConfig.flavor.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Setup Service Locator
  setupServiceLocator();

  // Validate Environment Variables
  Env.validate();

  // Register AppConfig in GetIt so it can be accessed anywhere
  GetIt.I.registerSingleton<AppConfig>(appConfig);

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

  // 3. Fetch and activate remote feature flags.
  final config = GetIt.I.get<IConfigDriver>();
  await config.fetchAndActivate();

  // 4. Initialize AdMob and A/B Testing Config
  await AdService.initialize();
  await RevenueConfigService.initialize();

  // Run the main Flutter application wrapped with Clarity
  runApp(ClarityService.wrapApp(BingoApp(appConfig: appConfig)));
}

class BingoApp extends StatelessWidget {
  final AppConfig appConfig;

  const BingoApp({super.key, required this.appConfig});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'bingo_app_root',
      debugShowCheckedModeBanner: false,
      title: appConfig.appTitle,

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

