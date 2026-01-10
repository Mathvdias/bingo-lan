import 'dart:developer';
import 'package:bingo_app/features/host/host_room_view_model.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';

class HostRoomScreen extends StatelessWidget {
  const HostRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ViewModelProvider<HostRoomViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sala do Bingo (Host)'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () {
                  // TODO: Implement logic to stop the game and disconnect.
                  log("Stop game functionality not implemented.");
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Last Drawn Number
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outline, width: 2),
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
                            margin: const EdgeInsets.symmetric(horizontal: 4),
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
                    // Bingo Claims
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.bingoClaims.length,
                        itemBuilder: (context, index) {
                          final claim = viewModel.bingoClaims[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text('${claim.playerName} gritou BINGO!'),
                              subtitle: Text('Cartela ID: ${claim.cardId}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () => viewModel.validateClaim(claim),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Draw Next Number Button
                    BingoButton(
                      label: 'Sortear Próximo Número',
                      onPressed: viewModel.drawNextNumber,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
