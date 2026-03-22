import 'package:bingo_app/features/host/host_room_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart' show AppColors;
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HostRoomScreen extends StatelessWidget {
  const HostRoomScreen({super.key});

  Future<bool> _showExitDialog(
    BuildContext context,
    HostRoomViewModel viewModel,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.stopRoomTitle),
          content: Text(AppLocalizations.of(context)!.stopRoomMessage),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () {
                viewModel.stopGame();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _onExit(
    BuildContext context,
    HostRoomViewModel viewModel,
  ) async {
    final shouldPop = await _showExitDialog(context, viewModel);
    if (shouldPop && context.mounted) {
      context.go('/lobby');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ViewModelProvider<HostRoomViewModel>(
      onReady: (viewModel) {
        viewModel.actionStream.listen((event) {
          if (!context.mounted) return;
          switch (event) {
            case ShowPaywall():
              context.push('/paywall');
              break;
            case ShowError(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.error,
                ),
              );
              break;
          }
        });
      },
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              await _onExit(context, viewModel);
            }
          },
          child: BingoScaffold(
            title: AppLocalizations.of(context)!.hostRoomTitle,
            onBack: () => _onExit(context, viewModel),
            actions: [
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () => _onExit(context, viewModel),
              ),
            ],
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Last Drawn Number
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
                            child: Center(
                              child: Text(
                                viewModel.lastNumber?.toString() ?? '--',
                                style: textTheme.headlineLarge,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Drawn Numbers History
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.drawnNumbers.length,
                              itemBuilder: (context, index) {
                                final number = viewModel.drawnNumbers[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      number.toString(),
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
                          // Player Count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people),
                              const SizedBox(width: 8),
                              Text(
                                '${viewModel.playerCount} ${AppLocalizations.of(context)!.playersInRoom}',
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
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
                          '${claim.playerName} ${AppLocalizations.of(context)!.shoutedBingo}',
                        ),
                        subtitle: Text(
                          '${AppLocalizations.of(context)!.cardId} ${claim.cardId}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => viewModel.validateClaim(claim),
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
                              tabs: [
                                Tab(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.virtualGlobe,
                                ),
                                Tab(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.manualGlobe,
                                ),
                              ],
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200, // Fixed height for controls
                              child: TabBarView(
                                children: [
                                  // Virtual Globe
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BingoButton(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.drawRandom,
                                        onPressed: viewModel.drawRandomNumber,
                                        // Disable if auto-playing
                                        color: viewModel.isAutoPlaying
                                            ? Colors.grey
                                            : AppColors.primary,
                                      ),
                                      const SizedBox(height: 16),
                                      if (RevenueConfigService.purchasesEnabled)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Globo Automático (Premium): ',
                                            ),
                                            Switch(
                                              value: viewModel.isAutoPlaying,
                                              onChanged: (value) =>
                                                  viewModel.toggleAutoPlay(),
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
                                  _ManualInputControl(viewModel: viewModel),
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
          ),
        );
      },
    );
  }
}

class _ManualInputControl extends StatefulWidget {
  final HostRoomViewModel viewModel;
  const _ManualInputControl({required this.viewModel});

  @override
  State<_ManualInputControl> createState() => _ManualInputControlState();
}

class _ManualInputControlState extends State<_ManualInputControl> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text;
    final number = int.tryParse(text);
    if (number != null) {
      widget.viewModel.drawManualNumber(number);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.numberInput,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.manualInputInstruction,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
