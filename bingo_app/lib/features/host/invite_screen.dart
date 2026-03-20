import 'package:bingo_app/features/host/host_invite_view_model.dart'; // Import ViewModel
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/di/service_locator.dart'; // Import serviceLocator
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class HostInviteScreen extends StatelessWidget {
  final String qrData;

  const HostInviteScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    // Resolve ViewModel
    final viewModel = serviceLocator<HostInviteViewModel>();
    // Initialize data in VM.
    viewModel.setInviteData(qrData);

    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final players = viewModel.connectedPlayers;
        final roomName = viewModel.roomName;

        return BingoScaffold(
          title: l10n.inviteTitle,
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
                        Text(
                          l10n.inviteConnectedPlayers(players.length),
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
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
                    label: l10n.inviteStartBingo,
                    onPressed: () {
                      context.go('/host/room');
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
