import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:bingo_app/core/config/env.dart';
import 'package:bingo_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:bingo_app/shared/di/service_locator.dart';
import 'package:bingo_app/shared/providers/locale_provider.dart';
import 'package:bingo_app/shared/router.dart';
import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/services/att_service.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/shared_prefs_key_value_store.dart';
import 'package:bingo_app/shared/services/sound_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/app_fonts.dart';
import 'package:bingo_app/shared/ui/app_theme.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'firebase_options.dart' as prod;
import 'firebase_options_dev.dart' as dev;
import 'flavors/app_config.dart';

Future<void> mainCommon(AppConfig appConfig) async {
  // Ensure Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge: o app desenha sob a barra de status e a de navegação, e
  // ambas ficam transparentes. Com targetSdk 36 o Android 15+ impõe isso de
  // qualquer forma; declarar deixa de ser opcional e passa a ser intencional,
  // e é o que permite pintar as barras em vez de aceitar o preto do sistema.
  //
  // Quem respeita os recortes é o BingoScaffold, via SafeArea.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(kBingoSystemUiStyle);

  // Retrato, como no Info.plist do iPhone: a grade da cartela e o número
  // gigante do host estouram em paisagem.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  await preloadBingoFonts();

  // Firebase: app Android separado por flavor; iOS dev reutiliza o app de prod
  // enquanto não houver scheme dev no Xcode.
  final useDevFirebase =
      appConfig.isDev && defaultTargetPlatform == TargetPlatform.android;
  await Firebase.initializeApp(
    options: useDevFirebase
        ? dev.DefaultFirebaseOptions.currentPlatform
        : prod.DefaultFirebaseOptions.currentPlatform,
  );

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

  // Chave do RevenueCat ausente não derruba o app: fica registrada no
  // Crashlytics (não fatal) e as compras ficam desativadas nesta sessão.
  final envError = Env.validate(appConfig);
  if (envError != null && kReleaseMode) {
    unawaited(
      FirebaseCrashlytics.instance.recordError(
        StateError(envError),
        StackTrace.current,
        reason: 'env_validate',
      ),
    );
  }

  // 2. Initialize the Bingo SDK (não configura o RevenueCat). Em dev/alpha
  //    o IConfigDriver ganha overrides locais de flags (tela /debug/flags),
  //    persistidos em shared_preferences; em prod é o Remote Config puro.
  try {
    await BingoSDK.initialize(
      debugOverridesStore: appConfig.hasDebugTools
          ? SharedPrefsKeyValueStore(await SharedPreferences.getInstance())
          : null,
    );
  } catch (e) {
    log('BingoSDK (Core) initialization failed: $e');
  }

  // 2.5 RevenueCat: configuração única + cache do status premium.
  // Em dev com RC_TEST_STORE_KEY usa o Test Store. Nunca derruba o startup.
  try {
    await SubscriptionService.initialize(
      appConfig: appConfig,
    ).timeout(const Duration(seconds: 5));
  } catch (e) {
    log('RevenueCat initialization skipped: $e');
  }

  // 2.6 Som: lê as preferências salvas e prepara o player. Sem rede, rápido,
  // e já resolvido antes do primeiro toque em um botão.
  try {
    // Falha de áudio é silenciosa por projeto — o jogo segue mudo em vez de
    // quebrar. Sem isto, "não sai som" no aparelho de um usuário não deixa
    // rastro nenhum para investigar.
    SoundService.onError = (error, stack, reason) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          reason: reason,
          fatal: false,
        ),
      );
    };
    await SoundService.initialize();
  } catch (e) {
    log('SoundService initialization skipped: $e');
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

  // 4. Remote Config da receita; se anúncios ativos: ATT (iOS), consentimento
  //    UMP e AdMob. Não bloqueia o primeiro frame: o formulário de
  //    consentimento aparece sobre o lobby e o SDK inicializa quando puder.
  await RevenueConfigService.initialize();
  if (RevenueConfigService.adsEnabled && !SubscriptionService.isPremium.value) {
    await AttService.requestIfNeeded();
    unawaited(AdService.ensureInitialized());
  }

  // 5. Initialize global Showcase scope for app tours
  ShowcaseView.register();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: BingoApp(appConfig: appConfig),
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
