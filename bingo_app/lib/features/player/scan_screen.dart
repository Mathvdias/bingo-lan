import 'dart:developer'; // Import for log
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:mobile_scanner/mobile_scanner.dart';

class PlayerScanScreen extends StatefulWidget {
  const PlayerScanScreen({super.key});

  @override
  State<PlayerScanScreen> createState() => _PlayerScanScreenState();
}

class _PlayerScanScreenState extends State<PlayerScanScreen> {
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ViewModelProvider<PlayerScanViewModel>(
      onReady: (viewModel) {
        viewModel.addListener(() {
          if (viewModel.errorMessage != null && mounted) {
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
                controller: _scannerController,
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty &&
                      barcodes.first.rawValue != null &&
                      !viewModel.isLoading) {
                    // Stop camera before processing to prevent double scan or lag
                    // await _scannerController.stop();
                    // Actually, don't stop strictly yet, just pause detection logic via isLoading check.
                    // But user says camera KEEPS active.

                    final cardId = await viewModel.onQrCodeScanned(
                      barcodes.first.rawValue!,
                    );

                    if (cardId != null && mounted) {
                      try {
                        // Stop the camera explicitly before navigating away
                        await _scannerController.stop();
                      } catch (e) {
                        log("Error stopping scanner: $e");
                      }
                      if (mounted) {
                        context.go('/player/game/$cardId');
                      }
                    } else {
                      // If failed, maybe resume? It is still running.
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
                  color: const Color.fromRGBO(0, 0, 0, 0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
