import 'dart:developer'; // Import for log

import 'package:app_settings/app_settings.dart';
import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_app/features/player/widgets/camera_error_view.dart';
import 'package:bingo_app/features/player/widgets/manual_code_dialog.dart';
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

class _PlayerScanScreenState extends State<PlayerScanScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController controller;
  final GlobalKey _scannerShowcaseKey = GlobalKey();
  PlayerScanViewModel? _viewModel;

  /// Último convite lido, para o "Tentar de novo" do aviso de erro.
  String? _lastScanData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Voltou das configurações de Wi-Fi: atualiza o aviso de rede.
    if (state == AppLifecycleState.resumed) {
      _viewModel?.refreshNetwork();
    }
  }

  Future<void> _handleScan(PlayerScanViewModel viewModel, String data) async {
    if (viewModel.isLoading) return;
    _lastScanData = data;

    final joined = await viewModel.onQrCodeScanned(data);
    if (!mounted) return;

    if (joined == null) {
      final error = viewModel.error;
      if (error != null) _showError(viewModel, error);
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

  void _showError(PlayerScanViewModel viewModel, PlayerScanError error) {
    final l10n = AppLocalizations.of(context)!;
    final text = switch (error) {
      PlayerScanError.invalidCode => l10n.scanErrorInvalidCode,
      PlayerScanError.notOnWifi => l10n.scanErrorNotOnWifi,
      PlayerScanError.differentNetwork => l10n.scanErrorDifferentNetwork(
        viewModel.wifiIp ?? '?',
        viewModel.invite?.ip ?? '?',
      ),
      PlayerScanError.hostUnreachable => l10n.scanErrorHostUnreachable,
      PlayerScanError.roomClosed => l10n.scanErrorRoomClosed,
      PlayerScanError.rejected => l10n.scanErrorRejected,
      PlayerScanError.timeout => l10n.scanErrorTimeout,
      PlayerScanError.unexpected => l10n.scanErrorUnexpected,
    };
    // Erros de rede merecem tempo de leitura e um atalho para repetir (o
    // QR já foi lido; sem isso, quem veio pelo link teria que reabri-lo).
    final isNetwork = switch (error) {
      PlayerScanError.notOnWifi ||
      PlayerScanError.differentNetwork ||
      PlayerScanError.hostUnreachable ||
      PlayerScanError.timeout => true,
      _ => false,
    };
    final lastData = _lastScanData;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        key: const Key('scan_error_snackbar'),
        content: Text(text),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: isNetwork ? 8 : 4),
        action: isNetwork && lastData != null
            ? SnackBarAction(
                key: const Key('scan_retry_action'),
                label: l10n.connectionRetry,
                textColor: Colors.white,
                onPressed: () => _handleScan(viewModel, lastData),
              )
            : null,
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
    final code = await showManualCodeDialog(context);
    if (code == null || !mounted) return;
    await _handleScan(viewModel, code);
  }

  void _onDetect(BarcodeCapture capture, PlayerScanViewModel viewModel) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _handleScan(viewModel, barcodes.first.rawValue!);
    }
  }

  /// Sem permissão de localização não dá para ler o nome da rede; o IP do
  /// Wi-Fi (que não exige permissão) já diz se o aparelho está no Wi-Fi.
  String _bannerText(AppLocalizations l10n, PlayerScanViewModel viewModel) {
    if (!viewModel.networkChecked) return l10n.scanWifiBannerDefault;
    final ip = viewModel.wifiIp;
    if (ip == null) return l10n.scanWifiBannerNoWifi;
    return l10n.scanWifiBannerOnWifi(ip);
  }

  IconData _bannerIcon(PlayerScanViewModel viewModel) {
    if (viewModel.networkChecked && viewModel.wifiIp == null) {
      return Icons.wifi_off_rounded;
    }
    return Icons.wifi_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return ViewModelProvider<PlayerScanViewModel>(
      onReady: (viewModel) {
        _viewModel = viewModel;
        viewModel.refreshNetwork();
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
                    // Câmera negada ou indisponível: mensagem amigável no
                    // lugar do erro padrão do plugin.
                    errorBuilder: (context, error) => CameraErrorView(
                      error: error,
                      onRetry: () => controller.start(),
                    ),
                  ),
                ),
              ),
              // Máscara, moldura e dica só fazem sentido com a câmera aberta.
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: controller,
                builder: (context, state, child) {
                  if (state.error != null) return const SizedBox.shrink();
                  return child!;
                },
                child: Stack(
                  children: [
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
                          // Amarelo como moldura sobre a máscara escura.
                          border: Border.all(
                            color: AppColors.primary,
                            width: 4,
                          ),
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
                  ],
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
                        Icon(
                          _bannerIcon(viewModel),
                          key: const Key('scan_wifi_banner_icon'),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _bannerText(l10n, viewModel),
                            key: const Key('scan_wifi_banner_text'),
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
              // Acima da barra de gestos do sistema.
              Positioned(
                bottom: 24 + MediaQuery.paddingOf(context).bottom,
                left: 24,
                right: 24,
                child: BingoButton(
                  key: const Key('scan_manual_button'),
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
