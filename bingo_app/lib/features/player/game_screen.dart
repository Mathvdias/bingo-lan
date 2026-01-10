import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';

class PlayerGameScreen extends StatelessWidget {
  final int cardId;

  const PlayerGameScreen({
    super.key,
    required this.cardId,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<PlayerGameViewModel>(
      param1: cardId, // Pass cardId as param1
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sua Cartela'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: BingoGrid(
                      bingoCard: viewModel.bingoCard,
                      markedNumbers: viewModel.markedNumbers,
                      onNumberTapped: viewModel.markNumber,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BingoButton(
                  label: 'Gritar BINGO!',
                  onPressed: viewModel.shoutBingo,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      onReady: (viewModel) {
        // ViewModel is ready, no specific action needed here for now.
      },
    );
  }
}
