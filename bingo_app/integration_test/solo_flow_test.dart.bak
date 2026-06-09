// E2E: `flutter test integration_test/solo_flow_test.dart` (emulador/simulador).
// Testa o fluxo solo mode: lobby → solo game → draw numbers

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bingo_app/main_dev.dart' as app_entry;
import 'package:bingo_app/shared/services/revenue_config_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Solo Mode E2E', () {
    testWidgets('fluxo: lobby → solo game → draw numbers', (tester) async {
      await app_entry.main();
      await tester.pump();

      // Splash → Lobby
      expect(find.byKey(const ValueKey<String>('splash_screen')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('lobby_screen')), findsOneWidget);

      // Verificar se solo mode está habilitado
      if (RevenueConfigService.soloModeEnabled) {
        // Lobby → Solo
        await tester.tap(find.byKey(const Key('lobby_btn_solo')));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey<String>('solo_game_screen')), findsOneWidget);

        // Verificar elementos do jogo solo
        expect(find.byKey(const Key('solo_draw_button')), findsOneWidget);
        
        // Verificar grid de bingo vazio inicialmente
        expect(find.byType(CustomScrollView), findsOneWidget);

        // Testar draw numbers
        await tester.tap(find.byKey(const Key('solo_draw_button')));
        await tester.pump();

        // Verificar se números foram sorteados (lista de drawn numbers)
        expect(find.textContaining('1'), findsOneWidget); // Primeiro número

        // Testar mais draws
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.byKey(const Key('solo_draw_button')));
          await tester.pump();
        }

        // Verificar se há múltiplos números sorteados
        expect(find.textContaining('1'), findsOneWidget);
        expect(find.textContaining('2'), findsOneWidget);

        // Testar marcação de números no grid
        // Encontrar e clicar em uma célula do grid
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();

        // Testar botão de reset
        await tester.tap(find.byType(IconButton));
        await tester.pump();
      } else {
        // Se solo mode não está habilitado, verificar que botão não aparece
        expect(find.byKey(const Key('lobby_btn_solo')), findsNothing);
      }
    });

    testWidgets('fluxo: solo game completion', (tester) async {
      await app_entry.main();
      await tester.pump();

      // Navegar até solo game se disponível
      await tester.pump(const Duration(milliseconds: 2200));
      
      if (RevenueConfigService.soloModeEnabled) {
        await tester.tap(find.byKey(const Key('lobby_btn_solo')));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey<String>('solo_game_screen')), findsOneWidget);

        // Simular jogo completo - draw muitos números
        for (int i = 0; i < 25; i++) {
          await tester.tap(find.byKey(const Key('solo_draw_button')));
          await tester.pump();
          
          // Marcar alguns números aleatoriamente
          if (i % 3 == 0) {
            await tester.tap(find.byType(GestureDetector).first);
            await tester.pump();
          }
        }

        // Verificar comportamento do jogo
        expect(find.byKey(const Key('solo_draw_button')), findsOneWidget);
      }
    });
  });
}
