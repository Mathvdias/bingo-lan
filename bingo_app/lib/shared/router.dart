import 'package:go_router/go_router.dart';

import '../../features/host/room_screen.dart';
import '../../features/host/setup_screen.dart';
import '../../features/lobby/lobby_screen.dart';
import '../../features/megafone/megafone_screen.dart';
import '../../features/paywall/paywall_screen.dart';
import '../../features/player/game_screen.dart';
import '../../features/player/scan_screen.dart';
import '../../main.dart'; // Assuming SplashScreen is in main.dart

/// The route configuration for the application.
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/lobby',
      builder: (context, state) => const LobbyScreen(),
    ),
    GoRoute(
      path: '/megafone',
      builder: (context, state) => const MegafoneScreen(),
    ),
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
    // Player Routes
    GoRoute(
      path: '/player/scan',
      builder: (context, state) => const PlayerScanScreen(),
    ),
    GoRoute(
      path: '/player/game',
      builder: (context, state) => const PlayerGameScreen(),
    ),
  ],
);
