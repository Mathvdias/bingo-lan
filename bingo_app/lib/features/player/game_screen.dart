import 'dart:async';

import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid_header.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:bingo_core/bingo_core.dart';
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
          child: BingoScaffold(
            title: l10n.playerGameTitle,
            onBack: () => _onExit(viewModel),
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _LastCalledStrip(viewModel: viewModel),
                    ),
                    if (!viewModel.isConnected && !viewModel.roomClosed)
                      SliverToBoxAdapter(
                        child: _ConnectionBanner(viewModel: viewModel),
                      ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: BingoGridHeader(),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: BingoGrid(
                        bingoCard: viewModel.bingoCard,
                        markedNumbers: viewModel.markedNumbers,
                        calledNumbers: viewModel.calledNumbers,
                        onNumberTapped: viewModel.markNumber,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        child: BingoButton(
                          key: const Key('player_shout_button'),
                          label: viewModel.isShoutOnCooldown
                              ? l10n.playerGameShoutCooldown(
                                  viewModel.shoutCooldownRemaining.inSeconds +
                                      1,
                                )
                              : l10n.playerGameShout,
                          enabled: viewModel.canShout,
                          onPressed: viewModel.shoutBingo,
                        ),
                      ),
                    ),
                  ],
                ),
                if (viewModel.roomClosed)
                  _Overlay(
                    key: const Key('player_room_closed_overlay'),
                    title: l10n.playerGameRoomClosedTitle,
                    message: l10n.playerGameRoomClosedMessage,
                    buttonLabel: l10n.backToLobby,
                    onPressed: () => _leave(viewModel),
                  )
                else if (viewModel.isGameOver)
                  _Overlay(
                    key: const Key('player_winner_overlay'),
                    title: viewModel.isWinner
                        ? l10n.playerGameYouWon
                        : l10n.playerGameSomeoneWon(viewModel.winnerName ?? ''),
                    message: l10n.playerGameWaitNextRound,
                    buttonLabel: l10n.backToLobby,
                    onPressed: () => _leave(viewModel),
                    accent: viewModel.isWinner
                        ? AppColors.primary
                        : AppColors.secondary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "Última bola: B-12" + contagem de sorteados.
class _LastCalledStrip extends StatelessWidget {
  final PlayerGameViewModel viewModel;

  const _LastCalledStrip({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final last = viewModel.lastNumber;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    last == null
                        ? l10n.playerGameNoCallsYet
                        : l10n.playerGameLastCalled,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (last != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: StrokedText(
                        key: const Key('player_last_called'),
                        text: BingoCard.label(last),
                        style: textTheme.headlineMedium,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              l10n.drawnCount(viewModel.drawnNumbers.length),
              key: const Key('player_drawn_count'),
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final PlayerGameViewModel viewModel;

  const _ConnectionBanner({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = viewModel.connectionState;
    final isDisconnected = state == GameConnectionState.disconnected;
    final text = switch (state) {
      GameConnectionState.connecting => l10n.connectionConnecting,
      GameConnectionState.reconnecting => l10n.connectionReconnecting,
      GameConnectionState.disconnected => l10n.connectionDisconnected,
      GameConnectionState.connected || GameConnectionState.roomClosed => '',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        key: const Key('player_connection_banner'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDisconnected
              ? AppColors.error.withValues(alpha: 0.25)
              : AppColors.secondary.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline, width: 2),
        ),
        child: Row(
          children: [
            if (isDisconnected)
              const Icon(Icons.wifi_off_rounded, size: 20)
            else
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
            if (isDisconnected)
              TextButton(
                key: const Key('player_retry_button'),
                onPressed: viewModel.retryConnection,
                child: Text(l10n.connectionRetry),
              ),
          ],
        ),
      ),
    );
  }
}

/// Camada bloqueante (vencedor / sala encerrada) com botão para o lobby.
class _Overlay extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color accent;

  const _Overlay({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: false,
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outline, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: StrokedText(
                    text: title,
                    style: textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                BingoButton(
                  label: buttonLabel,
                  onPressed: onPressed,
                  color: AppColors.card,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
