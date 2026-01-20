import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/lobby/lobby_screen.dart';
import '../../features/host/invite_screen.dart';
import '../../features/host/room_screen.dart';
import '../../features/host/setup_screen.dart';
import '../../features/paywall/paywall_screen.dart';
import '../../features/player/game_screen.dart';
import '../../features/player/scan_screen.dart';

/// The route configuration for the application.
final GoRouter router = GoRouter(
  initialLocation: '/lobby',
  observers: [AnalyticsService.observer],
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const LobbyScreen()),
    GoRoute(path: '/lobby', builder: (context, state) => const LobbyScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

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
  ],
);

/// Splash screen (simple loading screen)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
