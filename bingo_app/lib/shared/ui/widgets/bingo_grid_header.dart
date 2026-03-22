import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';

class BingoGridHeader extends StatelessWidget {
  const BingoGridHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // B-I-N-G-O Header
    final List<String> bingoLetters = ['B', 'I', 'N', 'G', 'O'];
    final List<Color> letterColors = [
      AppColors.pastelRed,
      AppColors.pastelOrange,
      AppColors.pastelYellow,
      AppColors.pastelGreen,
      AppColors.pastelBlue,
    ];

    return RepaintBoundary(
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: letterColors[index],
                border: Border.all(color: AppColors.outline, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                bingoLetters[index],
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
