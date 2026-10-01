import 'dart:async';
import 'dart:developer';

import 'package:bingo_app/features/host/host_room_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart' show AppColors;
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/players_counter.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HostRoomScreen extends StatefulWidget {
  const HostRoomScreen({super.key});

  @override
  State<HostRoomScreen> createState() => _HostRoomScreenState();
}

class _HostRoomScreenState extends State<HostRoomScreen> {
  StreamSubscription<HostRoomAction>? _actionsSub;

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

  Future<bool> _showExitDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.stopRoomTitle),
          content: Text(l10n.stopRoomMessage),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.no),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(l10n.yes),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Encerra a sala (ROOM_CLOSED para todos) e volta ao lobby, passando pelo
  /// interstitial quando os anúncios estiverem ativos.
  Future<void> _endRoom(HostRoomViewModel viewModel) async {
    await viewModel.stopGame();
    if (!mounted) return;
    // AdService.canShowAds já cobre ads_enabled, premium (cache) e plataforma.
    if (AdService.canShowAds) {
      AdService.showInterstitialAd(
        onAdDismissed: () {
          if (mounted) context.go('/lobby');
        },
      );
    } else {
      context.go('/lobby');
    }
  }

  Future<void> _onExit(HostRoomViewModel viewModel) async {
    // Com a rodada encerrada não há o que perder: sai sem confirmar.
    final shouldPop = viewModel.isGameOver || await _showExitDialog(context);
    if (shouldPop && mounted) {
      await _endRoom(viewModel);
    }
  }

  void _onAction(HostRoomAction action, AppLocalizations l10n) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case ShowPaywall(:final source):
        context.push('/paywall?source=$source');
      case ShowError(:final error):
        final text = switch (error) {
          HostRoomError.invalidNumber => l10n.errorInvalidNumber,
          HostRoomError.alreadyDrawn => l10n.errorNumberDrawn,
          HostRoomError.connection => l10n.hostRoomErrorConnection,
        };
        messenger.showSnackBar(
          SnackBar(content: Text(text), backgroundColor: AppColors.error),
        );
      case AnnounceNumber(:final number, :final phrase):
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              key: const Key('host_announce_toast'),
              behavior: SnackBarBehavior.floating,
              // Acima do botão de sortear: o toast não pode cobrir a ação
              // principal do cantador entre uma bola e outra.
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.outline, width: 2),
              ),
              content: Text(
                '${BingoCard.label(number)}  ·  $phrase',
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
    }
  }

  /// "N" ou "N/M" (limite grátis e host não premium, modelo paywall_host),
  /// com o rótulo em linha própria. Mesmo componente da tela de convite.
  Widget _buildPlayerCount(BuildContext context, HostRoomViewModel viewModel) {
    return ValueListenableBuilder<bool>(
      valueListenable: SubscriptionService.isPremium,
      builder: (context, isPremium, _) {
        final showCap = RevenueConfigService.hasFreePlayerCap && !isPremium;
        return PlayersCounter(
          key: const Key('host_room_player_count'),
          count: viewModel.playerCount,
          max: showCap ? RevenueConfigService.maxFreePlayersPathA : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return ViewModelProvider<HostRoomViewModel>(
      onReady: (viewModel) {
        if (AdService.canShowAds) {
          AdService.loadInterstitialAd(
            onAdLoaded: () {
              if (kDebugMode) log('HostRoomScreen: interstitial carregado.');
            },
            onAdFailedToLoad: (error) {
              if (kDebugMode) {
                log('HostRoomScreen: interstitial falhou: $error');
              }
            },
          );
        }
        _actionsSub = viewModel.actionStream.listen(
          (action) => _onAction(action, l10n),
        );
      },
      builder: (context, viewModel, child) {
        final history = viewModel.drawnNumbersNewestFirst;
        final canDraw = viewModel.canDraw && !viewModel.isAutoPlaying;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _onExit(viewModel);
          },
          child: BingoScaffold(
            title: l10n.hostRoomTitle,
            onBack: () => _onExit(viewModel),
            actions: [
              IconButton(
                icon: const Icon(Icons.stop),
                tooltip: l10n.hostRoomEndRoom,
                onPressed: () => _onExit(viewModel),
              ),
            ],
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Último número sorteado (com a letra B-I-N-G-O)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.outline,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    StrokedText(
                                      key: const Key('host_last_number'),
                                      text: viewModel.lastNumber == null
                                          ? '--'
                                          : BingoCard.label(
                                              viewModel.lastNumber!,
                                            ),
                                      style: textTheme.headlineLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.drawnCount(
                                        viewModel.drawnNumbers.length,
                                      ),
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (viewModel.phase == GamePhase.waiting)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          l10n.hostRoomWaitingDraw,
                                          textAlign: TextAlign.center,
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Histórico: mais recente primeiro
                              SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  key: const Key('host_history'),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: history.length,
                                  itemBuilder: (context, index) {
                                    final number = history[index];
                                    final isLatest = index == 0;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLatest
                                            ? AppColors.primary
                                            : AppColors.success,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.outline,
                                          width: isLatest ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          BingoCard.label(number),
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Player Count (com dica de capacidade N/M)
                              _buildPlayerCount(context, viewModel),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Connected Players
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final playerName = viewModel.players[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(playerName),
                        );
                      }, childCount: viewModel.playerCount),
                    ),
                    // Bingo Claims
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final claim = viewModel.bingoClaims[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              '${claim.playerName} ${l10n.shoutedBingo}',
                            ),
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
                    SliverToBoxAdapter(
                      child: RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                TabBar(
                                  // Cores e indicador vêm do TabBarThemeData.
                                  tabs: [
                                    Tab(text: l10n.virtualGlobe),
                                    Tab(text: l10n.manualGlobe),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 200, // Fixed height for controls
                                  child: TabBarView(
                                    children: [
                                      // Virtual Globe
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          BingoButton(
                                            key: const Key('host_draw_button'),
                                            label: l10n.drawRandom,
                                            enabled: canDraw,
                                            onPressed:
                                                viewModel.drawRandomNumber,
                                          ),
                                          const SizedBox(height: 16),
                                          if (RevenueConfigService
                                              .purchasesEnabled)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Text(l10n.autoGlobe),
                                                ),
                                                Switch(
                                                  value:
                                                      viewModel.isAutoPlaying,
                                                  onChanged:
                                                      viewModel.isGameOver
                                                      ? null
                                                      : (value) => viewModel
                                                            .toggleAutoPlay(),
                                                  activeThumbColor:
                                                      AppColors.primary,
                                                ),
                                                if (viewModel.isAutoPlaying)
                                                  const SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                        ],
                                      ),

                                      // Manual Input
                                      _ManualInputControl(
                                        viewModel: viewModel,
                                        enabled: canDraw,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (viewModel.isGameOver)
                  _WinnerOverlay(
                    key: const Key('host_winner_overlay'),
                    winnerName: viewModel.winnerName ?? '',
                    onNewRound: viewModel.newRound,
                    onEndRoom: () => _endRoom(viewModel),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
              StrokedText(
                text: l10n.hostRoomWinnerTitle,
                style: textTheme.headlineLarge,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
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
