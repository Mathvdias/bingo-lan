import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';

class PlayerGameScreen extends StatefulWidget {
  final int cardId;

  const PlayerGameScreen({super.key, required this.cardId});

  @override
  State<PlayerGameScreen> createState() => _PlayerGameScreenState();
}

class _PlayerGameScreenState extends State<PlayerGameScreen>
    with RestorationMixin {
  @override
  String? get restorationId => 'player_game_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // Register properties here if needed.
    // e.g., registerForRestoration(_counter, 'counter');
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<PlayerGameViewModel>(
      param1: widget.cardId, // Pass cardId as param1
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sua Cartela'), centerTitle: true),
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
