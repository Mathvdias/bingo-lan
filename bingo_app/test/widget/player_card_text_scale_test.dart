import 'package:bingo_app/shared/ui/widgets/bingo_grid.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid_header.dart';
import 'package:bingo_app/shared/ui/widgets/card_cell.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('Cartela do jogador com escala de texto 1.3x', () {
    testWidgets('cabeçalho + 25 células em 360 px sem overflow', (
      tester,
    ) async {
      final card = BingoCard(id: 1);
      final first = card.matrix.firstWhere((n) => n != 0);
      final second = card.matrix.lastWhere((n) => n != 0);

      await pumpApp(
        tester,
        CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: BingoGridHeader(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: BingoGrid(
                bingoCard: card,
                markedNumbers: {first},
                calledNumbers: {first, second},
                onNumberTapped: (_) {},
              ),
            ),
          ],
        ),
        textScale: 1.3,
      );

      expect(find.byType(CardCell), findsNWidgets(25));
      expect(find.text('LIVRE'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Semântica: estado cantado/marcado no rótulo, selected na célula marcada.
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('${BingoCard.label(first)}, marcado'),
        ),
        matchesSemantics(
          label: '${BingoCard.label(first)}, marcado',
          hasSelectedState: true,
          isSelected: true,
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel(
            '${BingoCard.label(second)}, sorteado, não marcado',
          ),
        ),
        matchesSemantics(
          label: '${BingoCard.label(second)}, sorteado, não marcado',
          hasSelectedState: true,
          isSelected: false,
          isButton: true,
          hasTapAction: true,
        ),
      );

      expect(find.bySemanticsLabel('espaço livre'), findsOneWidget);
    });

    testWidgets('BingoGridBox com célula de 44 dp: 25 células sem overflow', (
      tester,
    ) async {
      final card = BingoCard(id: 1);
      await pumpApp(
        tester,
        Center(
          child: BingoGridBox(
            bingoCard: card,
            markedNumbers: const {},
            cellSize: 44,
            gap: 6,
            onNumberTapped: (_) {},
          ),
        ),
        textScale: 1.3,
      );

      expect(find.byType(CardCell), findsNWidgets(25));
      expect(find.text('LIVRE'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final size = tester.getSize(find.byType(BingoGridBox));
      expect(size.width, BingoGridBox.sideFor(cellSize: 44, gap: 6));
      expect(size.height, size.width);
      for (var i = 0; i < 25; i++) {
        expect(tester.getSize(find.byType(CardCell).at(i)), const Size(44, 44));
      }
    });

    testWidgets('célula minúscula não estoura com "LIVRE" a 1.3x', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CardCell(number: 0, state: CardCellState.validated),
          ),
        ),
        textScale: 1.3,
      );
      expect(find.text('LIVRE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
