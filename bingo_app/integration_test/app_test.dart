// E2E: `flutter test integration_test/app_test.dart` (emulador/simulador com Firebase).
// VM/flutter_tester: sem canal Firebase — falha. Splash ~1,9s (animação + 400ms) antes do lobby.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bingo_app/main_common.dart';
import 'package:bingo_app/main_dev.dart' as app_entry;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E', () {
    testWidgets('fluxo: splash → lobby → host setup', (tester) async {
      await app_entry.main();
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('splash_screen')), findsOneWidget);
      expect(find.byType(BingoApp), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('lobby_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('lobby_btn_host')));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      expect(find.byKey(const Key('host_setup_screen')), findsOneWidget);
    });
  });
}
