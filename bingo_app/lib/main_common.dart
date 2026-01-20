import 'dart:io';
import 'dart:developer';
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
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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

  // Register AppConfig in GetIt so it can be accessed anywhere
  GetIt.I.registerSingleton<AppConfig>(appConfig);

  // 2. Initialize the Bingo SDK
  // Using placeholder keys for now. These should be stored securely.
  await BingoSDK.initialize(
    supabaseUrl: "REDACTED",
    supabaseKey:
        "REDACTED",
    revenueCatKey: "REDACTED_REVENUECAT_TEST_KEY",
  );

  // 2.5 Initialize RevenueCat for subscriptions (non-blocking)
  // TODO: Replace with your production keys when available
  try {
    await SubscriptionService.initialize(
      apiKey: Platform.isIOS
          ? 'REDACTED_REVENUECAT_TEST_KEY'
          : 'REDACTED_REVENUECAT_TEST_KEY',
    ).timeout(const Duration(seconds: 5));
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
      title: appConfig.appTitle, // Use dynamic title
      theme: bingoTheme,
      routerConfig: router,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate app initialization and then navigate to the lobby.
    Future.delayed(const Duration(seconds: 2), () {
      // It's important to check if the widget is still mounted before navigating.
      if (mounted) {
        context.go('/lobby');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Inicializando o Bingo..."),
          ],
        ),
      ),
    );
  }
}
