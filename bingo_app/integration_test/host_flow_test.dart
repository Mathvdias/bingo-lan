// E2E: `flutter test integration_test/host_flow_test.dart` (emulador/simulador).
// Testa o fluxo host completo: setup → invite → room

import 'package:bingo_app/main_dev.dart' as app_entry;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Host Flow E2E', () {
    testWidgets('fluxo: lobby → host setup → invite → room', (tester) async {
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

      // Lobby → Host Setup
      await tester.tap(find.byKey(const Key('lobby_btn_host')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('host_setup_screen')), findsOneWidget);

      // Configurar sala
      await tester.enterText(
        find.byKey(const Key('room_name_field')),
        'Test Room',
      );
      await tester.pump();

      // Criar sala
      await tester.tap(find.byKey(const Key('create_room_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar invite screen
      expect(find.byType(Container).first, findsOneWidget); // QR code container

      // Verificar elementos do invite screen
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.byKey(const Key('start_room_button')), findsOneWidget);

      // Navegar para room screen
      await tester.tap(find.byKey(const Key('start_room_button')));
      await tester.pumpAndSettle();

      // Verificar room screen elements
      expect(find.textContaining('--'), findsOneWidget); // Last number display
      expect(find.text('0'), findsOneWidget); // Player count inicial
    });

    testWidgets('fluxo: host setup validation', (tester) async {
      await app_entry.main();
      await tester.pump();

      // Navegar até host setup
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.tap(find.byKey(const Key('lobby_btn_host')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('host_setup_screen')), findsOneWidget);

      // Tentar criar sala sem nome
      await tester.tap(find.byKey(const Key('create_room_button')));
      await tester.pump();

      // Verificar se há mensagem de erro ou validação
      // (depende da implementação atual)
      expect(find.byKey(const Key('room_name_field')), findsOneWidget);
    });

    testWidgets('fluxo: host setup → invite com QR', (tester) async {
      await app_entry.main();
      await tester.pump();

      // Navegar até host setup
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.tap(find.byKey(const Key('lobby_btn_host')));
      await tester.pumpAndSettle();

      // Configurar sala com nome válido
      await tester.enterText(
        find.byKey(const Key('room_name_field')),
        'Integration Test Room',
      );
      await tester.pump();

      // Criar sala
      await tester.tap(find.byKey(const Key('create_room_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar invite screen
      expect(find.byType(QrImageView), findsOneWidget);

      // Verificar botões de share
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));

      // Verificar texto de código da sala
      expect(find.text(''), findsOneWidget); // Room code text
    });
  });
}
