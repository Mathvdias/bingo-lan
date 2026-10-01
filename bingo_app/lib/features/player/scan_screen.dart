import 'dart:developer'; // Import for log

import 'package:app_settings/app_settings.dart';
import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class PlayerScanScreen extends StatefulWidget {
  final String? initialData;

  const PlayerScanScreen({super.key, this.initialData});

  static const String screenKey = 'player_scan_screen';

  @override
  State<PlayerScanScreen> createState() => _PlayerScanScreenState();
}

class _PlayerScanScreenState extends State<PlayerScanScreen> {
  late final MobileScannerController controller;
  final GlobalKey _scannerShowcaseKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('first_launch_scan') ?? false;
    if (!hasShown && mounted) {
      ShowcaseView.get().startShowCase([_scannerShowcaseKey]);
      await prefs.setBool('first_launch_scan', true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(PlayerScanViewModel viewModel, String data) async {
    if (viewModel.isLoading) return;

    final joined = await viewModel.onQrCodeScanned(data);
    if (!mounted) return;

    if (joined == null) {
      final error = viewModel.error;
      if (error != null) _showError(error);
      return;
    }

    try {
      await controller.stop();
    } catch (e) {
      log('Error stopping scanner: $e');
    }
    if (!mounted) return;

    final playerName = await _showNameEntryDialog(context);
    if (!mounted) return;

    if (playerName == null || playerName.isEmpty) {
      // Desistiu depois de conectar: libera a vaga no host e volta a ler.
      await viewModel.cancelJoin();
      try {
        await controller.start();
      } catch (e) {
        log('Error restarting scanner: $e');
      }
      return;
    }

    context.push(
      '/player/game',
      extra: PlayerGameArgs.fromJoined(joined, playerName: playerName),
    );
  }

  void _showError(PlayerScanError error) {
    final l10n = AppLocalizations.of(context)!;
    final text = switch (error) {
      PlayerScanError.invalidCode => l10n.scanErrorInvalidCode,
      PlayerScanError.rejected => l10n.scanErrorRejected,
      PlayerScanError.timeout => l10n.scanErrorTimeout,
      PlayerScanError.unexpected => l10n.scanErrorUnexpected,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<String?> _showNameEntryDialog(BuildContext context) async {
    String name = '';
    final l10n = AppLocalizations.of(context)!;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.scanEnterName),
          content: TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 24,
            decoration: InputDecoration(
              hintText: l10n.playerScanNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => name = value,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.scanCancel),
            ),
            BingoButton(
              label: l10n.scanJoin,
              onPressed: () => Navigator.of(context).pop(name.trim()),
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
    String manualCode = '';
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.scanManualTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.scanManualHint),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: manualCode),
                decoration: InputDecoration(
                  labelText: l10n.inviteRoomCode,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                minLines: 1,
                onChanged: (value) => manualCode = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.scanCancel),
            ),
            BingoButton(
              label: l10n.scanJoin,
              onPressed: () {
                final text = manualCode.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context);
                  _handleScan(viewModel, text);
                }
              },
            ),
          ],
        );
      },
    );
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
        // Deep link bingo://join?data=...: entra na sala sem ler o QR.
        final initialData = widget.initialData;
        if (initialData != null && initialData.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handleScan(viewModel, initialData);
          });
        }
      },
      builder: (context, viewModel, child) {
        return BingoScaffold(
          key: const ValueKey<String>('player_scan_screen'),
          title: l10n.playerScanTitle,
          body: Stack(
            children: [
              Showcase(
                key: _scannerShowcaseKey,
                description: l10n.scanShowcaseScanner,
                child: RepaintBoundary(
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (capture) => _onDetect(capture, viewModel),
                  ),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _ScannerOverlayPainter()),
                ),
              ),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: const Offset(0, 140),
                  child: Text(
                    l10n.playerScanCameraHint,
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
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.scanWifiBannerDefault,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => AppSettings.openAppSettings(
                            type: AppSettingsType.wifi,
                          ),
                          child: Text(
                            l10n.buttonConfig,
                            style: const TextStyle(color: AppColors.primary),
                          ),
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

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 200,
      height: 200,
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16)),
      );

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
