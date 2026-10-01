import 'package:bingo_app/features/host/host_setup_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/flippable_card.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:bingo_app/shared/ui/widgets/warning_box.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HostSetupScreen extends StatelessWidget {
  const HostSetupScreen({super.key});

  static String _errorText(AppLocalizations l10n, HostSetupError error) {
    return switch (error) {
      HostSetupError.emptyName => l10n.hostSetupErrorEmptyName,
      HostSetupError.noWifi => l10n.hostSetupErrorNoWifi,
      HostSetupError.portUnavailable => l10n.hostSetupErrorPortUnavailable,
      HostSetupError.unexpected => l10n.hostSetupErrorUnexpected,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return ViewModelProvider<HostSetupViewModel>(
      builder: (context, viewModel, child) {
        final error = viewModel.error;
        final fieldError = error == HostSetupError.emptyName
            ? _errorText(l10n, error!)
            : null;

        return BingoScaffold(
          key: const Key('host_setup_screen'),
          title: l10n.hostSetupTitle,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.hostSetupNameLabel, style: textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      TextField(
                        key: const Key('room_name_field'),
                        onChanged: viewModel.onRoomNameChanged,
                        decoration: InputDecoration(
                          hintText: l10n.hostSetupRoomHint,
                          errorText: fieldError,
                        ),
                      ),
                      const SizedBox(height: 24),
                      WarningBox(text: l10n.hostSetupWifiWarning),
                      const SizedBox(height: 32),
                      // Roteador Wi-Fi com bolas (Lava, 220 px) no lugar da
                      // ilustração de 8 MB; toque vira o cartão e mostra o
                      // texto.
                      FlippableCard(
                        hero: const BingoLavaIconView(
                          key: Key('host_setup_wifi_hero'),
                          icon: BingoLavaIcon.wifiRouter,
                          size: 220,
                          fallback: Icon(
                            Icons.wifi_rounded,
                            size: 96,
                            color: AppColors.secondary,
                          ),
                        ),
                        text: l10n.hostSetupWifiDesc,
                      ),
                      const SizedBox(height: 32),
                      BingoButton(
                        key: const Key('create_room_button'),
                        label: l10n.hostSetupCreate,
                        onPressed: () async {
                          if (viewModel.isLoading) return;
                          final qrData = await viewModel.createRoom();
                          if (!context.mounted) return;
                          if (qrData != null) {
                            context.push('/host/invite', extra: qrData);
                            return;
                          }
                          final error = viewModel.error;
                          if (error != null &&
                              error != HostSetupError.emptyName) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_errorText(l10n, error)),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
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
