import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// Caixa de aviso (ex.: "todos na mesma rede Wi-Fi").
///
/// Fundo [AppColors.warningBackground], contorno preto, ícone e texto em
/// [AppColors.warningText] (6.2:1). Substitui as caixas rosa-sobre-rosa.
class WarningBox extends StatelessWidget {
  final String text;
  final IconData icon;

  /// Ação opcional à direita (ex.: abrir configurações de Wi-Fi).
  final String? actionLabel;
  final VoidCallback? onAction;

  const WarningBox({
    super.key,
    required this.text,
    this.icon = Icons.wifi_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = actionLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.warningText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.warningText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (label != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warningText,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(label),
            ),
        ],
      ),
    );
  }
}
