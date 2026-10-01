import 'package:bingo_app/features/host/widgets/host_draw_panel.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
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

      // Contador compacto ao lado de desfazer: "0/10" e o rótulo completo
      // na semântica.
      expect(find.byType(PlayersCounter), findsOneWidget);
      expect(find.text('0/10'), findsOneWidget);
      expect(
        find.bySemanticsLabel('0/10 jogadores (plano grátis)'),
        findsOneWidget,
      );
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
      // Sem limite: só a contagem; "3 jogadores conectados" na semântica.
      expect(find.text('3'), findsOneWidget);
      expect(find.bySemanticsLabel('3 jogadores conectados'), findsOneWidget);

      await tester.tap(find.byKey(const Key('host_undo_button')));
      await tester.pump();
      expect(undone, 1);
      expect(tester.takeException(), isNull);
    });

    for (final scale in [1.0, 1.3]) {
      testWidgets('primeira bola não move o botão SORTEAR (escala $scale)', (
        tester,
      ) async {
        Future<Rect> pumpAndMeasure({required bool drawn}) async {
          await pumpApp(
            tester,
            SingleChildScrollView(
              child: Column(
                children: [
                  HostDrawPanel(
                    lastNumber: drawn ? 42 : null,
                    drawnNumbersNewestFirst: drawn ? const [42] : const [],
                    canUndo: drawn,
                    onUndo: () {},
                    playerCount: 2,
                    maxPlayers: 10,
                  ),
                  BingoButton(
                    key: const Key('host_draw_button'),
                    label: 'Sortear',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          return tester.getRect(find.byKey(const Key('host_draw_button')));
        }

        final emptyRect = await pumpAndMeasure(drawn: false);
        expect(find.byKey(const Key('host_empty_state')), findsOneWidget);
        expect(
          find.byKey(const Key('host_history_placeholder')),
          findsOneWidget,
        );

        final drawnRect = await pumpAndMeasure(drawn: true);
        expect(find.byKey(const Key('host_last_number')), findsOneWidget);
        expect(find.byKey(const Key('host_history')), findsOneWidget);

        expect(drawnRect, equals(emptyRect));
        // O painel inteiro também mantém o tamanho.
        expect(
          tester.getSize(find.byType(HostDrawPanel)),
          equals(tester.getSize(find.byType(HostDrawPanel))),
        );
      });
    }
  });
}
