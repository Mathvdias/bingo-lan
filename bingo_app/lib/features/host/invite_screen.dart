import 'package:bingo_app/features/host/host_invite_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HostInviteScreen extends StatefulWidget {
  final String qrData;

  const HostInviteScreen({super.key, required this.qrData});

  @override
  State<HostInviteScreen> createState() => _HostInviteScreenState();
}

class _HostInviteScreenState extends State<HostInviteScreen> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  /// Voltar = desistir da sala: derruba o servidor antes de sair.
  Future<void> _onBack(HostInviteViewModel viewModel) async {
    await viewModel.leaveRoom();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/lobby');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final qrData = widget.qrData;

    return ViewModelProvider<HostInviteViewModel>(
      onReady: (viewModel) => viewModel.setInviteData(qrData),
      builder: (context, viewModel, _) {
        final players = viewModel.connectedPlayers;
        final roomName = viewModel.roomName ?? l10n.inviteDefaultRoomName;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _onBack(viewModel);
          },
          child: BingoScaffold(
            title: l10n.inviteTitle,
            onBack: () => _onBack(viewModel),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FittedBox(
                            fit: BoxFit.contain,
                            child: StrokedText(
                              key: const Key('invite_room_name'),
                              text: roomName,
                              style: textTheme.headlineMedium,
                            ),
                          ),
                          Text(
                            l10n.inviteScanDesc,
                            style: textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: RepaintBoundary(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  border: Border.all(
                                    color: AppColors.outline,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: AppColors.card,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
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
                                Text(
                                  l10n.inviteRoomCode,
                                  style: textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        qrData,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'Courier',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      tooltip: l10n.inviteShareCodeTooltip,
                                      onPressed: () {
                                        SharePlus.instance.share(
                                          ShareParams(
                                            text: l10n.inviteShareCodeMessage(
                                              qrData,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(color: AppColors.outline),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        // qrData já é o deep link
                                        // bingo://join?data=... gerado pelo host.
                                        SharePlus.instance.share(
                                          ShareParams(
                                            text: l10n.inviteShareLinkMessage(
                                              qrData,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.share),
                                      label: Text(l10n.inviteShareLink),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // "N jogadores conectados" ou "N/M grátis" quando há
                          // limite e o host não é premium (modelo paywall_host).
                          ValueListenableBuilder<bool>(
                            valueListenable: SubscriptionService.isPremium,
                            builder: (context, isPremium, _) {
                              final showCap =
                                  RevenueConfigService.hasFreePlayerCap &&
                                  !isPremium;
                              return Text(
                                showCap
                                    ? l10n.inviteConnectedPlayersCapacity(
                                        players.length,
                                        RevenueConfigService
                                            .maxFreePlayersPathA,
                                      )
                                    : l10n.inviteConnectedPlayers(
                                        players.length,
                                      ),
                                key: const Key('invite_player_count'),
                                style: textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                          if (players.isEmpty)
                            Text(
                              l10n.inviteWaitingPlayers,
                              style: textTheme.bodyLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(players[index]),
                    );
                  }, childCount: players.length),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BingoButton(
                      key: const Key('start_room_button'),
                      label: l10n.inviteStartBingo,
                      onPressed: () {
                        // go(): a tela de convite é descartada sem derrubar o
                        // servidor; a sala continua na tela do host.
                        context.go('/host/room');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
