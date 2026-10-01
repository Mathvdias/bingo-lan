import 'package:bingo_app/features/host/host_invite_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/players_counter.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// O texto compartilhado carrega o deep link `bingo://join?data=...`; o
  /// link bruto nunca aparece na tela.
  void _share(AppLocalizations l10n) {
    SharePlus.instance.share(
      ShareParams(text: l10n.inviteShareLinkMessage(widget.qrData)),
    );
  }

  Future<void> _copyLink(AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: widget.qrData));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('invite_link_copied'),
          content: Text(l10n.inviteLinkCopied),
          duration: const Duration(seconds: 2),
        ),
      );
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: StrokedText(
                            key: const Key('invite_room_name'),
                            text: roomName,
                            style: textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.inviteScanDesc,
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: RepaintBoundary(
                            child: Semantics(
                              label: l10n.inviteScanDesc,
                              image: true,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  border: Border.all(
                                    color: AppColors.outline,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.outline,
                                      offset: Offset(4, 4),
                                    ),
                                  ],
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
                        ),
                        const SizedBox(height: 24),
                        BingoButton(
                          key: const Key('invite_share_button'),
                          label: l10n.inviteShareInvite,
                          onPressed: () => _share(l10n),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const Key('invite_copy_button'),
                          onPressed: () => _copyLink(l10n),
                          icon: const Icon(Icons.link),
                          label: Text(l10n.inviteCopyLink),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.invitePasteHint(l10n.scanManualButton),
                          key: const Key('invite_paste_hint'),
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // "N/M" + "jogadores (plano grátis)" quando há limite e
                        // o host não é premium (modelo paywall_host).
                        ValueListenableBuilder<bool>(
                          valueListenable: SubscriptionService.isPremium,
                          builder: (context, isPremium, _) {
                            final showCap =
                                RevenueConfigService.hasFreePlayerCap &&
                                !isPremium;
                            return PlayersCounter(
                              key: const Key('invite_player_count'),
                              count: players.length,
                              max: showCap
                                  ? RevenueConfigService.maxFreePlayersPathA
                                  : null,
                            );
                          },
                        ),
                        if (players.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              l10n.inviteWaitingPlayers,
                              style: textTheme.bodyLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
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
                      color: AppColors.success,
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
