import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_core/bingo_core.dart' show BingoCard;
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

  /// "B-12, marcado" / "B-12, sorteado, não marcado" / "espaço livre".
  /// Fora de um MaterialApp com delegates (previews, testes) cai no inglês.
  String _semanticsLabel(AppLocalizations? l10n) {
    if (number == 0) return l10n?.cardCellFreeSpace ?? 'free space';
    final String status;
    if (state != CardCellState.normal) {
      status = l10n?.cardCellMarked ?? 'marked';
    } else if (called) {
      status = l10n?.cardCellCalled ?? 'called, not marked';
    } else {
      status = l10n?.cardCellNotCalled ?? 'not called';
    }
    return '${BingoCard.label(number)}, $status';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final showRing = called && state == CardCellState.normal;
    final l10n = AppLocalizations.of(context);
    // Fora de um MaterialApp com delegates (previews, testes) cai em 'FREE'.
    final freeLabel = l10n?.cardFree ?? 'FREE';

    return RepaintBoundary(
      child: Semantics(
        button: onTap != null,
        selected: state != CardCellState.normal,
        label: _semanticsLabel(l10n),
        // excludeSemantics derruba a ação do GestureDetector: expõe o toque aqui.
        onTap: onTap,
        excludeSemantics: true,
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
                borderRadius: BorderRadius.circular(
                  8,
                ), // Small radius for cells
              ),
              // FittedBox: "LIVRE"/"FREE" e dois dígitos cabem em qualquer
              // célula e em qualquer escala de texto sem estourar.
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    number == 0 ? freeLabel : '$number', // 0 for FREE space
                    style: textTheme.displaySmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
Widget cardCellNormalPreview() =>
    const SizedBox(width: 80, height: 80, child: CardCell(number: 15));

@Preview(name: 'Card Cell - Marked')
Widget cardCellMarkedPreview() => const SizedBox(
  width: 80,
  height: 80,
  child: CardCell(number: 15, state: CardCellState.marked),
);

@Preview(name: 'Card Cell - FREE Space')
Widget cardCellFreePreview() => const SizedBox(
  width: 80,
  height: 80,
  child: CardCell(number: 0, state: CardCellState.validated),
);
