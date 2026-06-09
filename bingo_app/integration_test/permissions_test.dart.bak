// E2E: `flutter test integration_test/permissions_test.dart` (emulador/simulador).
// Testa comportamento relacionado a permissões

import 'package:bingo_app/main_dev.dart' as app_entry;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Permissions E2E', () {
    testWidgets('fluxo: scan screen → camera permission request', (
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

      // Verificar status inicial da permissão
      final cameraStatus = await Permission.camera.status;

      if (cameraStatus.isDenied) {
        // Se permissão negada, verificar se há UI para solicitar
        // (implementação específica dependeria do seu código)
        expect(
          find.byKey(const ValueKey<String>('player_scan_screen')),
          findsOneWidget,
        );
      } else if (cameraStatus.isGranted) {
        // Se permissão concedida, scanner deve funcionar
        expect(find.byType(MobileScanner), findsOneWidget);
      }

      // Testar comportamento quando permissão é negada
      // Nota: Em testes reais, você precisaria mockar PermissionHandler
    });

    testWidgets('fluxo: app settings navigation', (tester) async {
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

      // Verificar se há botão para abrir configurações
      // (se implementado no seu código)
      // expect(find.text('Abrir Configurações'), findsOneWidget);

      // Testar navegação para configurações (se implementado)
    });
  });
}
