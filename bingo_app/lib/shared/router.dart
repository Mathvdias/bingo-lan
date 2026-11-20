import 'dart:developer';

import 'package:bingo_app/core/config/debug_tools.dart';
import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/about_screen.dart';
import '../../features/debug/debug_flags_screen.dart';
import '../../features/host/invite_screen.dart';
import '../../features/host/room_screen.dart';
import '../../features/host/setup_screen.dart';
import '../../features/lobby/lobby_screen.dart';
import '../../features/paywall/paywall_screen.dart';
import '../../features/player/game_screen.dart';
import '../../features/player/scan_screen.dart';
import '../../features/premium/premium_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/solo/solo_game_screen.dart';

/// Caminho do App Link https (`https://<BingoInvite.webHost>/join?data=`) e
/// do deep link `bingo://join?data=`, como o go_router o recebe.
const String joinPath = '/join';

/// Tela de overrides de feature flags. Só existe com ferramentas de
/// depuração (dev/alpha); em prod a rota não é registrada.
const String debugFlagsPath = '/debug/flags';

/// Convite recebido por link: `bingo://join?data=<base64>` ou
/// `https://bingo-policy-and-terms.vercel.app/join?data=<base64>`.
///
/// O sistema entrega o link como rota inicial (`?data=`, `/join?data=`) ou
/// via `pushRouteInformation` quando o app já está aberto. Independente do
/// caminho, se há `data` fora da tela de scan, redireciona para
/// `/player/scan?data=` e a tela entra na sala automaticamente.
String? deepLinkRedirect(BuildContext context, GoRouterState state) {
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
  initialLocation: '/lobby',
  debugLogDiagnostics: kDebugMode,
  observers: [AnalyticsService.observer],
  redirect: deepLinkRedirect,
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
  routes: appRoutes,
);

/// Tabela de rotas do app (separada do [router] para ser testável sem os
/// singletons do Firebase que o observer de analytics exige).
///
/// Avaliada na primeira leitura, depois de a [AppConfig] estar no GetIt:
/// é ela que decide se as rotas de depuração entram.
final List<RouteBase> appRoutes = buildAppRoutes(
  debugTools: debugToolsEnabled,
);

/// Monta a tabela de rotas. Com [debugTools] inclui `/debug/flags`.
List<RouteBase> buildAppRoutes({required bool debugTools}) => <RouteBase>[
  // A splash nativa (flutter_native_splash) é a única splash: o app abre
  // direto no lobby. `/splash` segue válido só como redirecionamento.
  GoRoute(path: '/', redirect: (context, state) => '/lobby'),
  GoRoute(path: '/splash', redirect: (context, state) => '/lobby'),
  GoRoute(path: '/lobby', builder: (context, state) => const LobbyScreen()),
  GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
  ),

  // Destino do selo PREMIUM no lobby: o que a assinatura já liberou.
  GoRoute(path: '/premium', builder: (context, state) => const PremiumScreen()),

  // Aceita `?source=` para o funil de analytics (ex.: /paywall?source=lobby).
  GoRoute(
    path: '/paywall',
    builder: (context, state) =>
        PaywallScreen(source: state.uri.queryParameters['source'] ?? 'unknown'),
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
  // App Link `/join?data=`: com `data` o redirect acima leva ao scan; sem
  // `data` abre o leitor em vez da tela de erro.
  GoRoute(
    path: joinPath,
    builder: (context, state) => PlayerScanScreen(
      initialData: state.uri.queryParameters[BingoInvite.dataParam],
    ),
  ),
  // Ferramentas de depuração (dev/alpha). Em prod a lista termina acima.
  if (debugTools)
    GoRoute(
      path: debugFlagsPath,
      builder: (context, state) => const DebugFlagsScreen(),
    ),
];
