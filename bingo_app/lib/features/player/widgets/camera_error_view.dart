import 'package:app_settings/app_settings.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Tela amigável quando a câmera falha. Permissão negada: explica e leva às
/// configurações do app. Outros erros: tentar de novo. O botão "código
/// manual" continua visível embaixo, então sempre há um caminho.
class CameraErrorView extends StatelessWidget {
  final MobileScannerException error;
  final VoidCallback onRetry;

  const CameraErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;

    return ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Container(
            key: const Key('scan_camera_error'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline, width: 2),
              boxShadow: const [
                BoxShadow(color: AppColors.outline, offset: Offset(4, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celular lendo um QR: é o que o usuário quer fazer; sem o
                // bundle fica o disco de aviso do mesmo tamanho.
                BingoLavaIconView(
                  key: const Key('scan_hero_phone'),
                  icon: BingoLavaIcon.cameraScan,
                  size: 64,
                  fallback: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.warningBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outline, width: 2),
                    ),
                    child: const Icon(
                      Icons.no_photography_outlined,
                      size: 32,
                      color: AppColors.warningText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  denied
                      ? l10n.scanCameraDeniedTitle
                      : l10n.scanErrorUnexpected,
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  denied
                      ? l10n.scanCameraDeniedMessage
                      : l10n.scanCameraErrorMessage,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                if (denied)
                  BingoButton(
                    key: const Key('scan_open_settings'),
                    label: l10n.scanOpenSettings,
                    onPressed: () => AppSettings.openAppSettings(),
                  )
                else
                  BingoButton(
                    key: const Key('scan_retry_camera'),
                    label: l10n.connectionRetry,
                    onPressed: onRetry,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
