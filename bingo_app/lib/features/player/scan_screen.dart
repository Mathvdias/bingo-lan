import 'dart:developer'; // Import for log

import 'package:app_settings/app_settings.dart';
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
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
            maxLength: 15,
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
              child: Text(
                l10n.scanCancel,
                style: const TextStyle(color: Colors.grey),
              ),
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
              child: Text(
                l10n.scanCancel,
                style: const TextStyle(color: Colors.grey),
              ),
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
                            _wifiName != null
                                ? l10n.scanWifiBannerConnected(_wifiName!)
                                : l10n.scanWifiBannerDefault,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (_wifiName == null)
                          TextButton(
                            onPressed: _fetchWifiName,
                            child: Text(
                              l10n.revealNetwork,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          )
                        else
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
