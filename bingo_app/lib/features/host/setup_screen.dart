import 'package:bingo_app/features/host/host_setup_view_model.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HostSetupScreen extends StatelessWidget {
  const HostSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Organizar um Bingo'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Dê um nome para a sala',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: viewModel.onRoomNameChanged,
                      decoration: InputDecoration(
                        hintText: 'Ex: Bingo do Tio Zé',
                        errorText: viewModel.errorMessage,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Escolha o tipo de jogo',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<GameType>(
                      segments: const [
                        ButtonSegment(
                          value: GameType.local,
                          label: Text('Local (Wi-Fi)'),
                          icon: Icon(Icons.wifi),
                        ),
                        ButtonSegment(
                          value: GameType.online,
                          label: Text('Online'),
                          icon: Icon(Icons.cloud),
                        ),
                      ],
                      selected: {viewModel.gameType},
                      onSelectionChanged: (Set<GameType> newSelection) {
                        viewModel.onGameTypeChanged(newSelection.first);
                      },
                    ),
                    const Spacer(),
                    BingoButton(
                      label: 'Criar Sala',
                      onPressed: () async {
                        final qrData = await viewModel.createRoom();
                        if (qrData != null && context.mounted) {
                          context.push('/host/invite', extra: qrData); // Changed from .go to .push
                        }
                      },
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
