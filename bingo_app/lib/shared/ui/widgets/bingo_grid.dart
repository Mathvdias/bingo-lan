import 'package:bingo_app/shared/ui/widgets/card_cell.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class BingoGrid extends StatelessWidget {
  final BingoCard bingoCard;
  final Set<int> markedNumbers;
  final ValueChanged<int>? onNumberTapped;

  const BingoGrid({
    super.key,
    required this.bingoCard,
    required this.markedNumbers,
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
      itemBuilder: (context, index) {
        final int number = bingoCard.matrix[index];
        final bool isMarked = markedNumbers.contains(number);
        final CardCellState state = number == 0
            ? CardCellState.validated
            : (isMarked ? CardCellState.marked : CardCellState.normal);

        return CardCell(
          number: number,
          state: state,
          onTap: onNumberTapped == null || number == 0
              ? null
              : () => onNumberTapped!(number),
        );
      },
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
