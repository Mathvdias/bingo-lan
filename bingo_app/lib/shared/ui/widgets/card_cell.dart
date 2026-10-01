import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

enum CardCellState { normal, marked, validated }

class CardCell extends StatelessWidget {
  final int number;
  final CardCellState state;

  /// O host já cantou este número. Mostra um anel; não marca sozinho.
  final bool called;
  final VoidCallback? onTap;

  const CardCell({
    super.key,
    required this.number,
    this.state = CardCellState.normal,
    this.called = false,
    this.onTap,
  });

  Color _getBackgroundColor(BuildContext context) {
    switch (state) {
      case CardCellState.marked:
        return AppColors.primary; // Marked: Yellow
      case CardCellState.validated:
        return AppColors.success; // Validated: Green
      case CardCellState.normal:
        return AppColors.card; // Normal: White
    }
  }

  Color _getForegroundColor(BuildContext context) {
    if (state == CardCellState.marked || state == CardCellState.validated) {
      return AppColors.text; // Text is black on marked/validated colors
    }
    return AppColors.text; // Default black
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final showRing = called && state == CardCellState.normal;
    // Fora de um MaterialApp com delegates (previews, testes) cai em 'FREE'.
    final freeLabel = AppLocalizations.of(context)?.cardFree ?? 'FREE';

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1, // Make it square
          child: Container(
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              border: Border.all(
                color: showRing ? AppColors.secondary : AppColors.outline,
                width: showRing ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(8), // Small radius for cells
            ),
            child: Center(
              child: Text(
                number == 0 ? freeLabel : '$number', // 0 for FREE space
                style: textTheme.displaySmall?.copyWith(
                  color: _getForegroundColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'Card Cell - Normal')
Widget cardCellNormalPreview() => const SizedBox(width: 80, height: 80, child: CardCell(number: 15));

@Preview(name: 'Card Cell - Marked')
Widget cardCellMarkedPreview() => const SizedBox(width: 80, height: 80, child: CardCell(number: 15, state: CardCellState.marked));

@Preview(name: 'Card Cell - FREE Space')
Widget cardCellFreePreview() => const SizedBox(width: 80, height: 80, child: CardCell(number: 0, state: CardCellState.validated));
