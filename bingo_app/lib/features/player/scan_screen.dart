import 'dart:developer'; // Import for log
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bingo_app/l10n/app_localizations.dart';

class PlayerScanScreen extends StatefulWidget {
  final String? initialData;

  const PlayerScanScreen({super.key, this.initialData});

  @override
  State<PlayerScanScreen> createState() => _PlayerScanScreenState();
}

class _PlayerScanScreenState extends State<PlayerScanScreen> {
  late final MobileScannerController controller;
  String? _wifiName;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(PlayerScanViewModel viewModel, String data) async {
    if (viewModel.isLoading) return;

    final cardId = await viewModel.onQrCodeScanned(data);

    if (cardId != null && mounted) {
      try {
        await controller.stop();
        if (!mounted) return;
        final playerName = await _showNameEntryDialog(context);
        if (playerName != null && playerName.isNotEmpty && mounted) {
          context.go('/player/game/$cardId?name=$playerName');
        }
      } catch (e) {
        log("Error stopping scanner: $e");
      }
    }
  }

  Future<String?> _showNameEntryDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Digite seu nome'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context, text);
                }
              },
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showManualEntryDialog(
    BuildContext context,
    PlayerScanViewModel viewModel,
  ) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Entrar Manualmente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Cole o código ou link da sala abaixo:'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Código / Link',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                minLines: 1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context);
                  _handleScan(viewModel, text);
                }
              },
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchWifiName() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        final name = await GetIt.I.get<INetworkInfoDriver>().getWifiName();
        if (mounted) {
          setState(() {
            _wifiName = name?.replaceAll('"', '');
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching Wi-Fi name: $e');
    }
  }

  void _onDetect(BarcodeCapture capture, PlayerScanViewModel viewModel) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _handleScan(viewModel, barcodes.first.rawValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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

        // Auto-connect if data is provided via deep link
        if (widget.initialData != null) {
          _handleScan(viewModel, widget.initialData!);
        }
      },
      builder: (context, viewModel, child) {
        return BingoScaffold(
          title: 'Entrar em um Bingo',
          body: Stack(
            children: [
              MobileScanner(
                controller: controller,
                onDetect: (capture) => _onDetect(capture, viewModel),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 4),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aponte a câmera para o QR Code do Host',
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _wifiName != null 
                                ? l10n.scanWifiBannerConnected(_wifiName!) 
                                : l10n.scanWifiBannerDefault,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        if (_wifiName == null)
                          TextButton(
                            onPressed: _fetchWifiName,
                            child: Text(l10n.revealNetwork, style: const TextStyle(color: AppColors.primary)),
                          )
                        else
                          TextButton(
                            onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.wifi),
                            child: Text(l10n.buttonConfig, style: const TextStyle(color: AppColors.primary)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: BingoButton(
                  label: l10n.scanManualButton,
                  onPressed: () {
                    _showManualEntryDialog(context, viewModel);
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
