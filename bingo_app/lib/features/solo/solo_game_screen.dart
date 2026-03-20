import 'package:bingo_app/features/solo/solo_game_view_model.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid_header.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SoloGameScreen extends StatelessWidget {
  const SoloGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ViewModelProvider<SoloGameViewModel>(
      builder: (context, viewModel, child) {
        return BingoScaffold(
          title: l10n.soloGameTitle,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Drawn Numbers Display
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.drawnNumbers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final number = viewModel.drawnNumbers.reversed
                          .toList()[index];
                      return _DrawnBall(number: number, isLatest: index == 0);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: BingoGridHeader(),
                        ),
                      ),
                      BingoGrid(
                        bingoCard: viewModel.bingoCard,
                        markedNumbers: viewModel.markedNumbers,
                        onNumberTapped: viewModel.markNumber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: BingoButton(
                        label: l10n.soloGameDraw,
                        onPressed: viewModel.drawNextNumber,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filled(
                      onPressed: viewModel.reset,
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrawnBall extends StatelessWidget {
  final int number;
  final bool isLatest;

  const _DrawnBall({required this.number, this.isLatest = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: isLatest ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 2),
        boxShadow: isLatest
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }
}
