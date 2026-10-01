import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../tokens/app_colors.dart';

class BingoButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  /// Desabilitado: fica cinza e ignora toques.
  final bool enabled;

  const BingoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.enabled = true,
  });

  @override
  State<BingoButton> createState() => _BingoButtonState();
}

class _BingoButtonState extends State<BingoButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed();
    HapticFeedback.lightImpact();
    // SystemSound.play(SystemSoundType.click); // This can be uncommented if you want sound
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The "hard shadow" is achieved by using a second container
    // underneath the main one, which is only visible when not pressed.
    final hardShadow = _isPressed
        ? const BoxShadow(color: Colors.transparent)
        : const BoxShadow(
            color: AppColors.outline,
            offset: Offset(4, 4),
            blurRadius: 0,
          );

    final enabled = widget.enabled;

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: enabled ? _onTapDown : null,
        onTapUp: enabled ? _onTapUp : null,
        onTapCancel: enabled ? _onTapCancel : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: _isPressed
              ? Matrix4.translationValues(4, 4, 0)
              : Matrix4.translationValues(0, 0, 0),
          decoration: BoxDecoration(
            color: enabled ? widget.color : AppColors.disabled,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline, width: 2),
            boxShadow: [hardShadow],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          // Uma linha, centralizada: rótulos longos ou escala de texto grande
          // encolhem em vez de quebrar em duas linhas alinhadas à esquerda.
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.label.toUpperCase(),
                maxLines: 1,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'Bingo Button - Primary')
Widget bingoButtonPreview() {
  return Scaffold(
    body: Center(
      child: BingoButton(label: 'Start Game', onPressed: () {}),
    ),
  );
}
