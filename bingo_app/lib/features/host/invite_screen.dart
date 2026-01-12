import 'package:bingo_app/features/host/host_invite_view_model.dart'; // Import ViewModel
import 'package:bingo_app/shared/di/service_locator.dart'; // Import serviceLocator
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HostInviteScreen extends StatelessWidget {
  final String qrData;

  const HostInviteScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    // Resolve ViewModel
    final viewModel = serviceLocator<HostInviteViewModel>();
    // Initialize data in VM.
    // Ideally this should be done once; ListenableBuilder rebuilds might re-call this but it's cheap idempodent set.
    viewModel.setInviteData(qrData);

    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final players = viewModel.connectedPlayers;
        final roomName = viewModel.roomName;
        // The raw QR data is passed in, but the code (token) comes from the model
        // Actually, the user asked for "Manual Code" which usually implies the token, OR the Payload as base64 string?
        // In the previous step I used the Payload string as "Code".
        // Let's stick to what I had: `parsedData?['code']` was the payload string.
        // But `BingoInvite` model doesn't store the raw payload code, only the parsed fields.
        // Wait, `roomCode` in VM returns `_inviteInfo?.token`. The token is "short" usually.
        // But previously I was showing the *Base64* string as the "Room Code"?
        // Quick check: `setup_screen.dart` generates:
        // jsonPayload = jsonEncode(payload); base64Payload ...; deepLink = ...
        // If "manual entry" accepts base64 OR deeplink, we should probably show the Base64 as the "Manual Code".
        // The `BingoInvite.parse` handles base64 payload.
        // So I should probably expose the raw payload string in the VM if I want to show that.
        // Or I can re-generate it using `toDeepLink` (which has the "v=..." payload) or just `toJson` then base64.

        // Let's assume for now we want the Base64 Payload as the "Code".
        // I will use `Uri.parse(qrData).queryParameters['data']` or just `qrData` if it's base64.
        // Actually, simpler: I'll ask the VM for the "manual entry code".

        // For now, I will use `token` as short code if that's what was intended?
        // No, the user likely wants the full blob to copy paste.
        // Let's check `BingoInvite` model again. It has `toDeepLink`.
        // I'll assume the `qrData` passed IS the deep link or base64.
        // Let's just use `qrData` for the link copy, and extracting the code...
        // I'll update the VM to expose `invitePayload` which is the copyable string for manual entry.

        return Scaffold(
          appBar: AppBar(
            title: const Text('Convide os Jogadores'),
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    roomName,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                        color: AppColors.card,
                        border: Border.all(color: AppColors.outline, width: 2),
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
                      border: Border.all(color: AppColors.outline, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text('Código da Sala', style: textTheme.labelLarge),
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
                              icon: const Icon(Icons.copy),
                              tooltip: 'Copiar Código',
                              onPressed: () {
                                _copyToClipboard(
                                  context,
                                  qrData,
                                  'Código copiado!',
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
                                _copyToClipboard(
                                  context,
                                  qrData,
                                  'Link copiado!',
                                );
                              },
                              icon: const Icon(Icons.link),
                              label: const Text('Copiar Link de Convite'),
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(players[index]),
                      );
                    },
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

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
