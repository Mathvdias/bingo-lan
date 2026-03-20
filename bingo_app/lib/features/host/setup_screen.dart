import 'package:bingo_app/features/host/host_setup_view_model.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/flippable_card.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HostSetupScreen extends StatelessWidget {
  const HostSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return ViewModelProvider<HostSetupViewModel>(
      onReady: (viewModel) {
        // Listen for error messages to show a Snackbar
        viewModel.addListener(() {
          if (viewModel.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        });
      },
      builder: (context, viewModel, child) {
        return BingoScaffold(
          title: l10n.hostSetupTitle,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.hostSetupNameLabel,
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: viewModel.onRoomNameChanged,
                        decoration: InputDecoration(
                          hintText: l10n.hostSetupRoomHint,
                          errorText: viewModel.errorMessage,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wifi_rounded,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.hostSetupWifiWarning,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      FlippableCard(
                        image: 'assets/images/bingo_local.png',
                        text:
                            l10n.hostSetupWifiDesc,
                      ),
                      const SizedBox(height: 32),
                      BingoButton(
                        label: l10n.hostSetupCreate,
                        onPressed: () async {
                          final qrData = await viewModel.createRoom();
                          if (qrData != null && context.mounted) {
                            context.push(
                              '/host/invite',
                              extra: qrData,
                            ); // Changed from .go to .push
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
