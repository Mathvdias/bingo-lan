import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';

enum CardCellState { normal, marked, validated }

class CardCell extends StatelessWidget {
  final int number;
  final CardCellState state;
  final VoidCallback? onTap;

  const CardCell({
    super.key,
    required this.number,
    this.state = CardCellState.normal,
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

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1, // Make it square
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            border: Border.all(color: AppColors.outline, width: 2),
            borderRadius: BorderRadius.circular(8), // Small radius for cells
          ),
          child: Center(
            child: Text(
              number == 0 ? 'FREE' : '$number', // 0 for FREE space
              style: textTheme.displaySmall?.copyWith(
                color: _getForegroundColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
