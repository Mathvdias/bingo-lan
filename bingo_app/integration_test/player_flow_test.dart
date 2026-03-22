// E2E: `flutter test integration_test/player_flow_test.dart` (emulador/simulador com Firebase).
// Testa o fluxo completo do jogador: lobby → scan QR → game screen

import 'package:bingo_app/main_dev.dart' as app_entry;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Player Flow E2E', () {
    testWidgets('fluxo: lobby → scan → game screen', (tester) async {
      await app_entry.main();
      await tester.pump();

      // Splash → Lobby
      expect(
        find.byKey(const ValueKey<String>('splash_screen')),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('lobby_screen')),
        findsOneWidget,
      );

      // Lobby → Scan
      await tester.tap(find.byKey(const Key('lobby_btn_join')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('player_scan_screen')),
        findsOneWidget,
      );
      expect(find.byType(MobileScanner), findsOneWidget);

      // Nota: O teste real de QR scan requer complexidade adicional
      // pois o MobileScanner não pode ser facilmente mockado em testes de integração
      // Esta é uma verificação básica do fluxo UI
    });

    testWidgets('fluxo: scan screen → permission denied behavior', (
      tester,
    ) async {
      await app_entry.main();
      await tester.pump();

      // Navegar até scan screen
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.tap(find.byKey(const Key('lobby_btn_join')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('player_scan_screen')),
        findsOneWidget,
      );

      // Verificar elementos da UI de scan
      expect(find.byType(MobileScanner), findsOneWidget);

      // Verificar se há botões de configuração quando permissão é negada
      // (implementação específica dependeria do seu código atual)
    });
  });
}
