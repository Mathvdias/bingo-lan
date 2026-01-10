import 'dart:developer'; // Import for log
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:mobile_scanner/mobile_scanner.dart';

class PlayerScanScreen extends StatelessWidget {
  const PlayerScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ViewModelProvider<PlayerScanViewModel>(
      onReady: (viewModel) {
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
            title: const Text('Entrar em um Bingo'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Stack(
            children: [
              MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  returnImage: false,
                ),
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty &&
                      barcodes.first.rawValue != null &&
                      !viewModel.isLoading) {
                    final cardId = await viewModel.onQrCodeScanned(
                      barcodes.first.rawValue!,
                    );
                    if (cardId != null && context.mounted) {
                      context.go('/player/game', extra: cardId);
                    }
                  }
                },
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aponte a câmera para o QR Code do Host',
                      style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: BingoButton(
                  label: 'Digitar Código Manualmente',
                  onPressed: () {
                    // TODO: Implement manual code entry dialog
                    log("Manual code entry not implemented yet.");
                  },
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
