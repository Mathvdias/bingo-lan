import 'package:bingo_app/features/splash/splash_screen.dart';
import 'package:bingo_app/shared/services/analytics_service.dart';
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

/// The route configuration for the application.
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: kDebugMode,
  observers: [AnalyticsService.observer],
  errorBuilder: (context, state) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.error?.toString() ?? 'Não foi possível abrir esta rota.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  ),
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/lobby', builder: (context, state) => const LobbyScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),

    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
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
          // Handle error case, maybe redirect to setup
          return const HostSetupScreen();
        }
        return HostInviteScreen(qrData: qrData);
      },
    ),
    // Player Routes
    GoRoute(
      path: '/player/scan',
      builder: (context, state) => const PlayerScanScreen(),
    ),
    GoRoute(
      path: '/player/game',
      builder: (context, state) {
        final cardId = state.extra as int?;
        if (cardId == null) {
          // Handle error case, maybe redirect to scan
          return const PlayerScanScreen();
        }
        return PlayerGameScreen(cardId: cardId, playerName: 'Player');
      },
    ),
    GoRoute(path: '/solo', builder: (context, state) => const SoloGameScreen()),
  ],
);
