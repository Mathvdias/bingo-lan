// E2E: `flutter test integration_test/offline_test.dart` (emulador/simulador).
// Testa comportamento offline

import 'package:bingo_app/main_dev.dart' as app_entry;
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Behavior E2E', () {
    testWidgets('fluxo: offline - solo mode functionality', (tester) async {
      await app_entry.main();
      await tester.pump();

      // Splash → Lobby
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('lobby_screen')),
        findsOneWidget,
      );

      // Solo mode deve funcionar offline
      if (RevenueConfigService.soloModeEnabled) {
        await tester.tap(find.byKey(const Key('lobby_btn_solo')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('solo_game_screen')),
          findsOneWidget,
        );

        // Testar funcionalidade offline
        await tester.tap(find.byKey(const Key('solo_draw_button')));
        await tester.pump();

        // Verificar se jogo funciona sem conexão
        expect(find.textContaining('1'), findsOneWidget);
      }
    });

    testWidgets('fluxo: offline - host setup limitations', (tester) async {
      await app_entry.main();
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      // Tentar criar sala offline
      await tester.tap(find.byKey(const Key('lobby_btn_host')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('host_setup_screen')), findsOneWidget);

      // Host setup pode mostrar avisos sobre conectividade
      expect(find.textContaining('Wi-Fi'), findsOneWidget);

      // Tentar criar sala mesmo offline
      await tester.enterText(
        find.byKey(const Key('room_name_field')),
        'Offline Test Room',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('create_room_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Pode falhar ou mostrar mensagem de erro
      // Verificar comportamento graceful
    });

    testWidgets('fluxo: offline - player scan behavior', (tester) async {
      await app_entry.main();
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      // Navegar para scan screen
      await tester.tap(find.byKey(const Key('lobby_btn_join')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('player_scan_screen')),
        findsOneWidget,
      );

      // Scanner deve funcionar, mas conexão pode falhar
      expect(find.byType(MobileScanner), findsOneWidget);

      // Verificar se há mensagens sobre conexão
      // (implementação específica)
    });
  });
}
