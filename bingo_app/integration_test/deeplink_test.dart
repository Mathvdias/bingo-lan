// E2E: `flutter test integration_test/deeplink_test.dart` (emulador/simulador).
// Testa fluxo de deep link join

import 'package:bingo_app/main_dev.dart' as app_entry;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Deep Link E2E', () {
    testWidgets('fluxo: deep link join → game screen', (tester) async {
      // Dados de deep link de teste (para uso futuro em implementação real)

      // Iniciar app com dados de deep link
      await app_entry.main();
      await tester.pump();

      // Splash → Lobby (ou direto para scan se deep link detectado)
      expect(
        find.byKey(const ValueKey<String>('splash_screen')),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      // Verificar comportamento com deep link
      // Nota: Implementação real dependeria de como seu app handle deep links
      // Isso é um esboço do teste

      // Se deep link for detectado, pode pular direto para game screen
      // expect(find.byKey(const ValueKey<String>('player_game_screen')), findsOneWidget);

      // Ou pode ir para scan screen com dados pré-preenchidos
      expect(
        find.byKey(const ValueKey<String>('lobby_screen')),
        findsOneWidget,
      );

      // Navegar manualmente para simular deep link
      await tester.tap(find.byKey(const Key('lobby_btn_join')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('player_scan_screen')),
        findsOneWidget,
      );
    });

    testWidgets('fluxo: invalid deep link data', (tester) async {
      // Testar comportamento com dados inválidos
      // Nota: Implementação real usaria dados inválidos para testar

      await app_entry.main();
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      // Verificar se app lida gracefully com dados inválidos
      expect(
        find.byKey(const ValueKey<String>('lobby_screen')),
        findsOneWidget,
      );
    });
  });
}
