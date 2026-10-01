import 'dart:developer';

import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/splash/splash_screen.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/about_screen.dart';
import '../../features/host/invite_screen.dart';
import '../../features/host/room_screen.dart';
import '../../features/host/setup_screen.dart';
import '../../features/lobby/lobby_screen.dart';
import '../../features/paywall/paywall_screen.dart';
import '../../features/player/game_screen.dart';
import '../../features/player/scan_screen.dart';
import '../../features/solo/solo_game_screen.dart';

/// Deep link `bingo://join?data=<base64>`.
///
/// O sistema entrega o link como rota inicial (`?data=` ou `/join?data=`) ou
/// via `pushRouteInformation` quando o app já está aberto. Em qualquer forma,
/// se há `data` fora da tela de scan, redireciona para `/player/scan?data=`
/// e a tela entra na sala automaticamente.
String? _deepLinkRedirect(BuildContext context, GoRouterState state) {
  final uri = state.uri;
  final data = uri.queryParameters[BingoInvite.dataParam];
  if (data == null || data.isEmpty) return null;
  if (uri.path == '/player/scan') return null;
  return Uri(
    path: '/player/scan',
    queryParameters: {BingoInvite.dataParam: data},
  ).toString();
}

/// The route configuration for the application.
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: kDebugMode,
  observers: [AnalyticsService.observer],
  redirect: _deepLinkRedirect,
  errorBuilder: (context, state) {
    if (kDebugMode) log('Route error: ${state.error}');
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.of(context)!.routeErrorMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  },
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/lobby', builder: (context, state) => const LobbyScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),

    // Aceita `?source=` para o funil de analytics (ex.: /paywall?source=lobby).
    GoRoute(
      path: '/paywall',
      builder: (context, state) => PaywallScreen(
        source: state.uri.queryParameters['source'] ?? 'unknown',
      ),
    ),
    // Host Routes
    GoRoute(
      path: '/host/setup',
      builder: (context, state) => const HostSetupScreen(),
    ),
    GoRoute(
      path: '/host/room',
      builder: (context, state) => const HostRoomScreen(),
    ),
    GoRoute(
      path: '/host/invite',
      builder: (context, state) {
        final qrData = state.extra as String?;
        if (qrData == null) {
          return const HostSetupScreen();
        }
        return HostInviteScreen(qrData: qrData);
      },
    ),
    // Player Routes
    GoRoute(
      path: '/player/scan',
      builder: (context, state) => PlayerScanScreen(
        initialData: state.uri.queryParameters[BingoInvite.dataParam],
      ),
    ),
    GoRoute(
      path: '/player/game',
      builder: (context, state) {
        final args = state.extra as PlayerGameArgs?;
        if (args == null) {
          return const PlayerScanScreen();
        }
        return PlayerGameScreen(args: args);
      },
    ),
    GoRoute(path: '/solo', builder: (context, state) => const SoloGameScreen()),
  ],
);
