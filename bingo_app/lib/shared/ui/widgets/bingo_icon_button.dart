import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// Botão de ícone do app: disco de 40 px com contorno preto, alvo de toque
/// de 48 px, tooltip e rótulo de semântica obrigatórios. Mesma linguagem do
/// [BingoBackButton]; o preenchimento pastel sinaliza a intenção (ex.: rosa
/// para encerrar) e o ícone é sempre preto.
class BingoIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const BingoIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.card,
  });

  static const double _targetSize = 48;
  static const double _discSize = 40;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      // excludeSemantics tira o nó do InkWell; o toque entra por aqui.
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: _targetSize,
              height: _targetSize,
              child: Center(
                child: Container(
                  width: _discSize,
                  height: _discSize,
                  decoration: BoxDecoration(
                    color: onPressed == null
                        ? AppColors.disabled
                        : backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outline, width: 2),
                  ),
                  child: Icon(icon, color: AppColors.text, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
