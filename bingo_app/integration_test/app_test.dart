// E2E: `flutter test integration_test/app_test.dart` (ideal: emulador Android ou simulador iOS).
// No alvo `flutter_tester` (VM) o Firebase não tem canal nativo — o teste falha até usar device/emulator.
// CI típico: `flutter test` só na pasta `test/`; rode integration_test em job com emulador ou dispositivo.

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

      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('lobby_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('lobby_btn_host')));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      expect(find.byKey(const Key('host_setup_screen')), findsOneWidget);
    });
  });
}
