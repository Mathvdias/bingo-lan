import 'package:bingo_app/features/host/host_invite_view_model.dart'; // Import ViewModel
import 'package:bingo_app/shared/di/service_locator.dart'; // Import serviceLocator
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HostInviteScreen extends StatelessWidget {
  final String qrData;

  const HostInviteScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    // Resolve ViewModel
    final viewModel = serviceLocator<HostInviteViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final players = viewModel.connectedPlayers;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Convide os Jogadores'),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Escaneie para entrar na sala!',
                    style: textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Jogadores Conectados: ${players.length}',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  // Simple list of first few players or count...
                  // Maybe a ScrollView if many. For now, let's keep it simple.
                  if (players.isEmpty)
                    Text(
                      'Aguardando jogadores...',
                      style: textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(players[index]),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  BingoButton(
                    label: 'Iniciar Bingo!',
                    onPressed: () {
                      context.go('/host/room');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
