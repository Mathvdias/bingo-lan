import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// Botão de voltar do app: disco com contorno, alvo de toque de 48 px,
/// semântica de botão e tooltip localizado pelo MaterialLocalizations.
class BingoBackButton extends StatelessWidget {
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  /// Rótulo acessível e tooltip. Padrão: "Voltar" no idioma do app.
  final String? label;

  const BingoBackButton({
    super.key,
    this.backgroundColor,
    this.onPressed,
    this.label,
  });

  static const double _targetSize = 48;
  static const double _discSize = 40;

  @override
  Widget build(BuildContext context) {
    final tooltip =
        label ?? MaterialLocalizations.of(context).backButtonTooltip;
    final onTap = onPressed ?? () => Navigator.of(context).maybePop();

    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: _targetSize,
                height: _targetSize,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _discSize,
                    height: _discSize,
                    decoration: BoxDecoration(
                      color: backgroundColor ?? AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outline, width: 2),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.text,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
