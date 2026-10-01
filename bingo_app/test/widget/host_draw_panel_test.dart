import 'package:bingo_app/features/host/widgets/host_draw_panel.dart';
import 'package:bingo_app/shared/ui/widgets/players_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('HostDrawPanel', () {
    testWidgets('estado vazio a 1.3x: bola em contorno, texto e sem overflow', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const SingleChildScrollView(
          child: HostDrawPanel(
            lastNumber: null,
            drawnNumbersNewestFirst: [],
            canUndo: false,
            onUndo: null,
            playerCount: 0,
            maxPlayers: 10,
          ),
        ),
        textScale: 1.3,
      );

      expect(find.byKey(const Key('host_empty_state')), findsOneWidget);
      expect(find.text('Nenhuma bola ainda'), findsOneWidget);
      expect(find.byKey(const Key('host_last_number')), findsNothing);
      expect(find.byKey(const Key('host_history')), findsNothing);
      // Nada de "--" amarelo gigante.
      expect(find.text('--'), findsNothing);

      // Desfazer existe, mas desabilitado.
      final undo = tester.widget<OutlinedButton>(
        find.byKey(const Key('host_undo_button')),
      );
      expect(undo.onPressed, isNull);

      // Contador em duas linhas: "0/10" e o rótulo.
      expect(find.byType(PlayersCounter), findsOneWidget);
      expect(find.text('0/10'), findsOneWidget);
      expect(find.text('jogadores (plano grátis)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('com bolas a 1.3x: número grande cabe e desfazer chama', (
      tester,
    ) async {
      var undone = 0;
      await pumpApp(
        tester,
        SingleChildScrollView(
          child: HostDrawPanel(
            lastNumber: 75,
            drawnNumbersNewestFirst: const [75, 12, 33, 60, 7, 41, 22],
            canUndo: true,
            onUndo: () => undone++,
            playerCount: 3,
          ),
        ),
        textScale: 1.3,
      );

      expect(find.byKey(const Key('host_empty_state')), findsNothing);
      expect(find.byKey(const Key('host_last_number')), findsOneWidget);
      expect(find.byKey(const Key('host_history')), findsOneWidget);
      expect(find.text('7/75 sorteados'), findsOneWidget);
      // Sem limite: só a contagem e "jogadores conectados".
      expect(find.text('3'), findsOneWidget);
      expect(find.text('jogadores conectados'), findsOneWidget);

      await tester.tap(find.byKey(const Key('host_undo_button')));
      await tester.pump();
      expect(undone, 1);
      expect(tester.takeException(), isNull);
    });
  });
}
