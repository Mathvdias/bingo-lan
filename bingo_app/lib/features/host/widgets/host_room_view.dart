import 'package:bingo_app/features/host/host_room_view_model.dart';
import 'package:bingo_app/features/host/widgets/host_draw_panel.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_icon_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Layout da sala do host, sem plugins, DI nem navegação: a tela
/// ([HostRoomScreen]) cuida de wakelock, anúncios, GetIt e rotas; aqui só
/// widgets, para o teste conseguir montar com um [HostRoomViewModel] real.
///
/// A ação principal do cantador fica numa barra fixa no rodapé: as abas
/// Virtual/Manual e o botão SORTEAR nunca saem da tela, mesmo em 360x640 dp
/// com escala de texto grande. Última bola, histórico, desfazer, contador e
/// lista de jogadores rolam no meio.
class HostRoomView extends StatelessWidget {
  final HostRoomViewModel viewModel;

  /// Voltar / botão "Encerrar sala" da barra (com confirmação na tela).
  final VoidCallback onExit;

  /// Botão "Encerrar sala" da camada de vencedor (sem confirmação).
  final VoidCallback onEndRoom;

  /// Limite do plano grátis mostrado no contador; `null` sem limite.
  final int? maxPlayers;

  /// Mostra o interruptor do globo automático (premium).
  final bool purchasesEnabled;

  const HostRoomView({
    super.key,
    required this.viewModel,
    required this.onExit,
    required this.onEndRoom,
    required this.maxPlayers,
    required this.purchasesEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Sortear na mão é permitido fora do fim de jogo e enquanto o globo
    // automático não estiver rodando (pausado pode).
    final canDraw = viewModel.canDraw && !viewModel.isAutoRunning;

    return BingoScaffold(
      title: l10n.hostRoomTitle,
      onBack: onExit,
      actions: [
        // Disco rosa com contorno: ação destrutiva, visível de longe.
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: BingoIconButton(
            key: const Key('host_end_room_action'),
            icon: Icons.logout,
            label: l10n.hostRoomEndRoom,
            backgroundColor: AppColors.error,
            onPressed: onExit,
          ),
        ),
      ],
      // Com a camada de vencedor aberta o rodapé sai: a camada cobre o corpo
      // inteiro e não sobra um botão por baixo.
      bottomNavigationBar: viewModel.isGameOver
          ? null
          : HostDrawFooter(
              key: const Key('host_draw_footer'),
              viewModel: viewModel,
              canDraw: canDraw,
              purchasesEnabled: purchasesEnabled,
            ),
      body: Stack(
        children: [
          // SafeArea(bottom) só importa sem rodapé (camada de vencedor); com
          // ele o Scaffold já desconta a barra de gestos.
          SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: HostDrawPanel(
                      lastNumber: viewModel.lastNumber,
                      drawnNumbersNewestFirst:
                          viewModel.drawnNumbersNewestFirst,
                      canUndo: viewModel.canUndo,
                      onUndo: viewModel.undoLastDraw,
                      playerCount: viewModel.playerCount,
                      maxPlayers: maxPlayers,
                    ),
                  ),
                ),
                // Jogadores conectados.
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final playerName = viewModel.players[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(playerName),
                    );
                  }, childCount: viewModel.playerCount),
                ),
                // Reivindicações de bingo.
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final claim = viewModel.bingoClaims[index];
                    return Card(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: ListTile(
                        title: Text('${claim.playerName} ${l10n.shoutedBingo}'),
                        subtitle: Text('${l10n.cardId} ${claim.cardId}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: viewModel.isLoading
                              ? null
                              : () => viewModel.validateClaim(claim),
                        ),
                      ),
                    );
                  }, childCount: viewModel.bingoClaims.length),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
              ],
            ),
          ),
          if (viewModel.isGameOver)
            _WinnerOverlay(
              key: const Key('host_winner_overlay'),
              winnerName: viewModel.winnerName ?? '',
              onNewRound: viewModel.newRound,
              onEndRoom: onEndRoom,
            ),
        ],
      ),
    );
  }
}

/// Rodapé fixo: abas "Virtual" / "Manual" e os controles da aba ativa
/// (SORTEAR + globo automático, ou o campo do número), acima da barra de
/// gestos do sistema.
///
/// Ícones Lava no estilo Airbnb: o dado rola e o lápis escreve UMA vez quando
/// a aba é selecionada; a outra aba fica no primeiro quadro, acinzentada.
/// Cores e indicador vêm do TabBarThemeData.
class HostDrawFooter extends StatefulWidget {
  final HostRoomViewModel viewModel;
  final bool canDraw;
  final bool purchasesEnabled;

  const HostDrawFooter({
    super.key,
    required this.viewModel,
    required this.canDraw,
    required this.purchasesEnabled,
  });

  @override
  State<HostDrawFooter> createState() => _HostDrawFooterState();
}

class _HostDrawFooterState extends State<HostDrawFooter>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.surface,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outline, width: 2)),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _tabs,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rótulos curtos (<= 12 caracteres) com ícone. `index` muda
                  // no toque: o ícone começa a tocar na hora.
                  TabBar(
                    controller: _tabs,
                    tabs: [
                      Tab(
                        key: const Key('host_tab_virtual'),
                        icon: BingoLavaTabIcon(
                          key: const Key('host_tab_virtual_icon'),
                          icon: BingoLavaIcon.dice,
                          selected: _tabs.index == 0,
                          size: 32,
                          fallback: const Icon(Icons.casino),
                        ),
                        text: l10n.virtualGlobe,
                      ),
                      Tab(
                        key: const Key('host_tab_manual'),
                        icon: BingoLavaTabIcon(
                          key: const Key('host_tab_manual_icon'),
                          icon: BingoLavaIcon.pencil,
                          selected: _tabs.index == 1,
                          size: 32,
                          fallback: const Icon(Icons.edit),
                        ),
                        text: l10n.manualGlobe,
                      ),
                    ],
                  ),
                  Padding(
                    // 16 embaixo cobre a sombra dura (4 px) do botão.
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    // IndexedStack: o rodapé tem a altura do maior controle e
                    // não pula ao trocar de aba; o campo manual mantém o
                    // texto digitado.
                    child: IndexedStack(
                      index: _tabs.index,
                      children: [
                        _VirtualGlobeControl(
                          viewModel: widget.viewModel,
                          canDraw: widget.canDraw,
                          purchasesEnabled: widget.purchasesEnabled,
                        ),
                        _ManualInputControl(
                          viewModel: widget.viewModel,
                          enabled: widget.canDraw,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Aba "Virtual": sortear, globo automático (premium) e pausar/retomar.
class _VirtualGlobeControl extends StatelessWidget {
  final HostRoomViewModel viewModel;
  final bool canDraw;
  final bool purchasesEnabled;

  const _VirtualGlobeControl({
    required this.viewModel,
    required this.canDraw,
    required this.purchasesEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BingoButton(
          key: const Key('host_draw_button'),
          label: l10n.drawRandom,
          enabled: canDraw,
          onPressed: viewModel.drawRandomNumber,
        ),
        if (purchasesEnabled) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text(l10n.autoGlobe)),
              Switch(
                key: const Key('host_auto_switch'),
                value: viewModel.isAutoPlaying,
                onChanged: viewModel.isGameOver
                    ? null
                    : (value) => viewModel.toggleAutoPlay(),
                activeThumbColor: AppColors.outline,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          if (viewModel.isAutoPlaying)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  key: const Key('host_auto_pause_button'),
                  onPressed: viewModel.isAutoPaused
                      ? viewModel.resumeAutoPlay
                      : viewModel.pauseAutoPlay,
                  icon: Icon(
                    viewModel.isAutoPaused ? Icons.play_arrow : Icons.pause,
                  ),
                  label: Text(
                    viewModel.isAutoPaused
                        ? l10n.hostRoomResume
                        : l10n.hostRoomPause,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    textStyle: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (viewModel.isAutoRunning) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ],
    );
  }
}

/// Aba "Manual": número do globo físico + confirmar.
class _ManualInputControl extends StatefulWidget {
  final HostRoomViewModel viewModel;
  final bool enabled;

  const _ManualInputControl({required this.viewModel, required this.enabled});

  @override
  State<_ManualInputControl> createState() => _ManualInputControlState();
}

class _ManualInputControlState extends State<_ManualInputControl> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!widget.enabled) return;
    final number = int.tryParse(_controller.text);
    if (number != null) {
      widget.viewModel.drawManualNumber(number);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: TextField(
                key: const Key('host_manual_field'),
                controller: _controller,
                enabled: widget.enabled,
                // Só dígitos, no máximo dois (1 a 75): o teclado numérico
                // sozinho não impede letras em teclados físicos, tablets e
                // alguns teclados Android.
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.numberInput,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 16),
            // Fundo amarelo + texto preto vêm do ElevatedButtonThemeData.
            ElevatedButton(
              key: const Key('host_manual_confirm'),
              onPressed: widget.enabled ? _submit : null,
              child: Text(l10n.confirm),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.manualInputInstruction,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Camada bloqueante de vencedor: nova rodada ou encerrar a sala.
class _WinnerOverlay extends StatelessWidget {
  final String winnerName;
  final VoidCallback onNewRound;
  final VoidCallback onEndRoom;

  const _WinnerOverlay({
    super.key,
    required this.winnerName,
    required this.onNewRound,
    required this.onEndRoom,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outline, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BingoLavaIconView(
                key: Key('host_winner_trophy'),
                icon: BingoLavaIcon.trophy,
                size: 72,
                fallback: Icon(
                  Icons.emoji_events_rounded,
                  size: 56,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: StrokedText(
                  text: l10n.hostRoomWinnerTitle,
                  style: textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.hostRoomWinnerMessage(winnerName),
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.hostRoomRoundOverHint,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              BingoButton(
                key: const Key('host_new_round_button'),
                label: l10n.hostRoomNewRound,
                onPressed: onNewRound,
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              BingoButton(
                key: const Key('host_end_room_button'),
                label: l10n.hostRoomEndRoom,
                onPressed: onEndRoom,
                color: AppColors.card,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
