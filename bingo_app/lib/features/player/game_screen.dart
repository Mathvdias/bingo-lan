import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid_header.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:bingo_app/shared/ui/widgets/banner_ad_widget.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PlayerGameScreen extends StatelessWidget {
  final int cardId;
  final String playerName;

  const PlayerGameScreen(
      {super.key, required this.cardId, required this.playerName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ViewModelProvider<PlayerGameViewModel>(
      param1: cardId, // Pass cardId as param1
      builder: (context, viewModel, child) {
        return BingoScaffold(
          title: l10n.playerGameTitle,
          body: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: BingoGridHeader(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: BingoGrid(
                  bingoCard: viewModel.bingoCard,
                  markedNumbers: viewModel.markedNumbers,
                  onNumberTapped: viewModel.markNumber,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BingoButton(
                    label: l10n.playerGameShout,
                    onPressed: viewModel.shoutBingo,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 32.0),
                  child: BannerAdWidget(),
                ),
              ),
            ],
          ),
        );
      },
      onReady: (viewModel) {
        viewModel.setPlayerName(playerName);
      },
    );
  }
}
