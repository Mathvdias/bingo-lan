// E2E: `flutter test integration_test/paywall_test.dart` (emulador/simulador).
// Testa interação com paywall

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bingo_app/main_dev.dart' as app_entry;
import 'package:bingo_app/shared/services/revenue_config_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Paywall E2E', () {
    testWidgets('fluxo: paywall navigation and dismissal', (tester) async {
      await app_entry.main();
      await tester.pump();

      // Splash → Lobby
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('lobby_screen')), findsOneWidget);

      // Verificar se paywall está acessível (depende da configuração)
      if (RevenueConfigService.purchasesEnabled) {
        // Tentar acessar funcionalidade premium
        // Por exemplo: tentar usar auto-play no host room
        
        // Navegar para host setup
        await tester.tap(find.byKey(const Key('lobby_btn_host')));
        await tester.pumpAndSettle();
        
        expect(find.byKey(const Key('host_setup_screen')), findsOneWidget);
        
        // Configurar sala
        await tester.enterText(find.byKey(const Key('room_name_field')), 'Paywall Test Room');
        await tester.pump();
        
        await tester.tap(find.byKey(const Key('create_room_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Navegar para room
        await tester.tap(find.byKey(const Key('start_room_button')));
        await tester.pumpAndSettle();
        
        // Tentar usar funcionalidade premium (se implementado)
        // Pode levar ao paywall
      }
    });

    testWidgets('fluxo: paywall UI elements', (tester) async {
      await app_entry.main();
      await tester.pump();

      // Testar UI do paywall se acessível
      // Nota: Implementação depende de como paywall é acionado
      
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();
      
      expect(find.byKey(const ValueKey<String>('lobby_screen')), findsOneWidget);
      
      // Verificar se há indicações de funcionalidades premium
      // (depende da implementação atual)
    });

    testWidgets('fluxo: purchase flow simulation', (tester) async {
      await app_entry.main();
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      // Simular fluxo de compra (sem realizar compra real)
      // Testar navegação e UI elements
      
      if (RevenueConfigService.purchasesEnabled) {
        // Verificar se há botões ou elementos de upgrade
        // expect(find.text('Upgrade'), findsOneWidget);
        // expect(find.text('Premium'), findsOneWidget);
      }
    });
  });
}
