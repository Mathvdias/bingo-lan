import 'package:bingo_app/shared/ui/widgets/card_cell.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class BingoGrid extends StatelessWidget {
  final BingoCard bingoCard;
  final Set<int> markedNumbers;

  /// Números já cantados pelo host: a célula ganha um anel discreto, mas a
  /// marcação continua manual.
  final Set<int> calledNumbers;
  final ValueChanged<int>? onNumberTapped;

  const BingoGrid({
    super.key,
    required this.bingoCard,
    required this.markedNumbers,
    this.calledNumbers = const {},
    this.onNumberTapped,
  });

  @override
  Widget build(BuildContext context) {
    // addRepaintBoundaries: false — cada [CardCell] já usa RepaintBoundary.
    return SliverGrid.builder(
      addRepaintBoundaries: false,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1, // Make cells square
      ),
      itemCount: 25,
      itemBuilder: (context, index) => bingoCardCell(
        bingoCard: bingoCard,
        index: index,
        markedNumbers: markedNumbers,
        calledNumbers: calledNumbers,
        onNumberTapped: onNumberTapped,
      ),
    );
  }
}

/// Célula [index] (0..24) da cartela: estado livre/marcada/normal, anel de
/// "cantado" e toque (nunca no espaço livre). Compartilhada pelas duas
/// cartelas ([BingoGrid] e [BingoGridBox]).
CardCell bingoCardCell({
  required BingoCard bingoCard,
  required int index,
  required Set<int> markedNumbers,
  required Set<int> calledNumbers,
  required ValueChanged<int>? onNumberTapped,
}) {
  final int number = bingoCard.matrix[index];
  final bool isMarked = markedNumbers.contains(number);
  final CardCellState state = number == 0
      ? CardCellState.validated
      : (isMarked ? CardCellState.marked : CardCellState.normal);

  return CardCell(
    number: number,
    state: state,
    called: number != 0 && calledNumbers.contains(number),
    onTap: onNumberTapped == null || number == 0
        ? null
        : () => onNumberTapped(number),
  );
}

/// Cartela 5x5 de tamanho fixo, fora de slivers: [cellSize] de lado por
/// célula e [gap] entre elas (largura total `5*cellSize + 4*gap`).
///
/// A tela do jogador calcula [cellSize] a partir da altura disponível para a
/// cartela inteira caber acima do rodapé "GRITAR BINGO!" sem rolar em
/// 360x640 dp.
class BingoGridBox extends StatelessWidget {
  final BingoCard bingoCard;
  final Set<int> markedNumbers;
  final Set<int> calledNumbers;
  final ValueChanged<int>? onNumberTapped;
  final double cellSize;
  final double gap;

  const BingoGridBox({
    super.key,
    required this.bingoCard,
    required this.markedNumbers,
    required this.cellSize,
    this.calledNumbers = const {},
    this.onNumberTapped,
    this.gap = 6,
  });

  /// Largura (e altura) total da cartela para [cellSize] e [gap].
  static double sideFor({required double cellSize, required double gap}) =>
      cellSize * 5 + gap * 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 5; row++) ...[
          if (row > 0) SizedBox(height: gap),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var col = 0; col < 5; col++) ...[
                if (col > 0) SizedBox(width: gap),
                SizedBox.square(
                  dimension: cellSize,
                  child: bingoCardCell(
                    bingoCard: bingoCard,
                    index: row * 5 + col,
                    markedNumbers: markedNumbers,
                    calledNumbers: calledNumbers,
                    onNumberTapped: onNumberTapped,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Bingo Grid (Cartela)')
Widget bingoGridPreview() {
  return Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: BingoGrid(
            bingoCard: BingoCard(id: 1),
            markedNumbers: const {1, 16, 45, 0}, // Mocked Marks
          ),
        ),
      ],
    ),
  );
}
