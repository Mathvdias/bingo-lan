import 'dart:async';

import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/features/player/widgets/player_game_view.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayerGameScreen extends StatefulWidget {
  final PlayerGameArgs args;

  const PlayerGameScreen({super.key, required this.args});

  @override
  State<PlayerGameScreen> createState() => _PlayerGameScreenState();
}

class _PlayerGameScreenState extends State<PlayerGameScreen> {
  StreamSubscription<PlayerGameAction>? _actionsSub;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _actionsSub?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _leave(PlayerGameViewModel viewModel) async {
    await viewModel.leaveRoom();
    if (mounted) context.go('/lobby');
  }

  Future<void> _onExit(PlayerGameViewModel viewModel) async {
    // Fim de jogo ou sala encerrada: sai direto.
    if (viewModel.isGameOver || viewModel.roomClosed) {
      await _leave(viewModel);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.playerGameLeaveTitle),
        content: Text(l10n.playerGameLeaveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.playerGameStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.playerGameLeave),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _leave(viewModel);
    }
  }

  void _onAction(PlayerGameAction action, AppLocalizations l10n) {
    if (!mounted) return;
    switch (action) {
      case ClaimRejected():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.playerGameClaimRejected),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ViewModelProvider<PlayerGameViewModel>(
      param1: widget.args,
      onReady: (viewModel) {
        viewModel.announceName();
        _actionsSub = viewModel.actionStream.listen(
          (action) => _onAction(action, l10n),
        );
      },
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _onExit(viewModel);
          },
          child: PlayerGameView(
            viewModel: viewModel,
            onExit: () => _onExit(viewModel),
            onLeave: () => _leave(viewModel),
          ),
        );
      },
    );
  }
}
