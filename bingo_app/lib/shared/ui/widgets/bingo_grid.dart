import 'package:bingo_app/shared/ui/widgets/card_cell.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';

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
    final textTheme = Theme.of(context).textTheme;

    // B-I-N-G-O Header
    final List<String> bingoLetters = ['B', 'I', 'N', 'G', 'O'];
    final List<Color> letterColors = [
      Colors.red.shade200,
      Colors.orange.shade200,
      Colors.yellow.shade200,
      Colors.green.shade200,
      Colors.blue.shade200,
    ];

    return Column(
      children: [
        // Bingo Header Row
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: letterColors[index],
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bingoLetters[index],
                  style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // Bingo Numbers Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
            final CardCellState state =
                number == 0 ? CardCellState.validated : (isMarked ? CardCellState.marked : CardCellState.normal);

            return CardCell(
              number: number,
              state: state,
              onTap: onNumberTapped == null || number == 0
                  ? null
                  : () => onNumberTapped!(number),
            );
          },
        ),
      ],
    );
  }
}
