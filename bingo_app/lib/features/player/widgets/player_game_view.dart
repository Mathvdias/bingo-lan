import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid_header.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';

/// Layout da cartela do jogador, sem plugins nem navegação: a tela
/// ([PlayerGameScreen]) cuida de wakelock, GetIt e rotas; aqui só widgets,
/// para o teste conseguir montar com um [PlayerGameViewModel] real.
///
/// "GRITAR BINGO!" fica numa barra fixa no rodapé: em 360x640 dp a cartela
/// rola acima dele e o botão nunca sai da tela.
class PlayerGameView extends StatelessWidget {
  final PlayerGameViewModel viewModel;

  /// Voltar / fechar (com confirmação quando a rodada está em andamento).
  final VoidCallback onExit;

  /// Botão das camadas de fim de jogo / sala encerrada.
  final VoidCallback onLeave;

  const PlayerGameView({
    super.key,
    required this.viewModel,
    required this.onExit,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showOverlay = viewModel.roomClosed || viewModel.isGameOver;

    return BingoScaffold(
      title: l10n.playerGameTitle,
      onBack: onExit,
      // Com a camada de fim de jogo aberta o rodapé sai: a camada cobre o
      // corpo inteiro e não sobra um botão cinza por baixo.
      bottomNavigationBar: showOverlay
          ? null
          : _ShoutBar(key: const Key('player_shout_bar'), viewModel: viewModel),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _LastCalledStrip(viewModel: viewModel)),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: BingoGrid(
                  bingoCard: viewModel.bingoCard,
                  markedNumbers: viewModel.markedNumbers,
                  calledNumbers: viewModel.calledNumbers,
                  onNumberTapped: viewModel.markNumber,
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
              onPressed: onLeave,
            )
          else if (viewModel.isGameOver)
            _Overlay(
              key: const Key('player_winner_overlay'),
              title: viewModel.isWinner
                  ? l10n.playerGameYouWon
                  : l10n.playerGameSomeoneWon(viewModel.winnerName ?? ''),
              message: l10n.playerGameWaitNextRound,
              buttonLabel: l10n.backToLobby,
              onPressed: onLeave,
              accent: viewModel.isWinner
                  ? AppColors.primary
                  : AppColors.secondary,
            ),
        ],
      ),
    );
  }
}

/// Rodapé fixo com "GRITAR BINGO!" acima da barra de gestos do sistema.
class _ShoutBar extends StatelessWidget {
  final PlayerGameViewModel viewModel;

  const _ShoutBar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          // 16 embaixo cobre a sombra dura (4 px) do botão.
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: BingoButton(
            key: const Key('player_shout_button'),
            label: viewModel.isShoutOnCooldown
                ? l10n.playerGameShoutCooldown(
                    viewModel.shoutCooldownRemaining.inSeconds + 1,
                  )
                : l10n.playerGameShout,
            enabled: viewModel.canShout,
            onPressed: viewModel.shoutBingo,
          ),
        ),
      ),
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
        // spaceBetween + Flexible: a contagem fica encostada à direita e
        // encolhe (em vez de estourar) com escala de texto grande.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.drawnCount(viewModel.drawnNumbers.length),
                  key: const Key('player_drawn_count'),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
            // Texto e botão dividem a largura; cada um quebra linha dentro da
            // sua metade em vez de estourar com escala de texto grande.
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(text)),
                  if (isDisconnected)
                    Flexible(
                      child: TextButton(
                        key: const Key('player_retry_button'),
                        onPressed: viewModel.retryConnection,
                        child: Text(l10n.connectionRetry),
                      ),
                    ),
                ],
              ),
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
