import 'dart:math';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_theme.dart';

/// Luminância relativa (WCAG 2.x).
double _luminance(Color c) {
  double channel(double v) {
    return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// Razão de contraste WCAG entre [a] e [b] (1:1 .. 21:1).
double contrastRatio(Color a, Color b) {
  final l1 = _luminance(a);
  final l2 = _luminance(b);
  final hi = max(l1, l2);
  final lo = min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

class _Pair {
  final String name;
  final Color fg;
  final Color bg;

  /// AA para texto normal. Nenhum par do tema depende da exceção de 3:1 para
  /// texto grande: todos ficam acima de 4.5:1.
  static const double minimum = 4.5;

  const _Pair(this.name, this.fg, this.bg);
}

void main() {
  const pairs = <_Pair>[
    // Texto preto sobre todos os preenchimentos que o tema usa.
    _Pair('text on surface', AppColors.text, AppColors.surface),
    _Pair('text on card', AppColors.text, AppColors.card),
    _Pair('text on primary', AppColors.text, AppColors.primary),
    _Pair('onPrimary on primary', AppColors.onPrimary, AppColors.primary),
    _Pair('text on secondary', AppColors.text, AppColors.secondary),
    _Pair('text on success', AppColors.text, AppColors.success),
    _Pair('text on error (fill)', AppColors.text, AppColors.error),
    _Pair(
      'text on warningBackground',
      AppColors.text,
      AppColors.warningBackground,
    ),
    _Pair('text on disabled', AppColors.text, AppColors.disabled),
    _Pair('text on pastelRed', AppColors.text, AppColors.pastelRed),
    _Pair('text on pastelOrange', AppColors.text, AppColors.pastelOrange),
    _Pair('text on pastelYellow', AppColors.text, AppColors.pastelYellow),
    _Pair('text on pastelGreen', AppColors.text, AppColors.pastelGreen),
    _Pair('text on pastelBlue', AppColors.text, AppColors.pastelBlue),
    // Tokens de texto colorido sobre fundos claros.
    _Pair('accentText on surface', AppColors.accentText, AppColors.surface),
    _Pair('accentText on card', AppColors.accentText, AppColors.card),
    _Pair(
      'warningText on warningBackground',
      AppColors.warningText,
      AppColors.warningBackground,
    ),
    _Pair('warningText on surface', AppColors.warningText, AppColors.surface),
    _Pair('errorText on surface', AppColors.errorText, AppColors.surface),
    _Pair('errorText on card', AppColors.errorText, AppColors.card),
    _Pair(
      'textSecondary on surface',
      AppColors.textSecondary,
      AppColors.surface,
    ),
    _Pair('textSecondary on card', AppColors.textSecondary, AppColors.card),
    // Amarelo só é texto sobre fundo escuro (faixa da câmera, tooltips).
    _Pair('primary on outline (dark)', AppColors.primary, AppColors.outline),
    _Pair('card on outline (tooltip)', AppColors.card, AppColors.outline),
  ];

  group('Contraste WCAG dos tokens', () {
    for (final pair in pairs) {
      test('${pair.name} ≥ ${_Pair.minimum}:1', () {
        final ratio = contrastRatio(pair.fg, pair.bg);
        expect(
          ratio,
          greaterThanOrEqualTo(_Pair.minimum),
          reason: '${pair.name} = ${ratio.toStringAsFixed(2)}:1',
        );
      });
    }

    test('amarelo puro NÃO serve como texto sobre creme/branco', () {
      // Documenta o motivo de accentText existir.
      expect(contrastRatio(AppColors.primary, AppColors.surface), lessThan(3));
      expect(contrastRatio(AppColors.primary, AppColors.card), lessThan(3));
      expect(contrastRatio(Colors.white, AppColors.primary), lessThan(3));
    });
  });

  group('Tema aplica a regra "pastel é fundo, preto é texto"', () {
    final theme = testBingoTheme;
    const states = <WidgetState>{};

    test('colorScheme', () {
      expect(theme.colorScheme.onPrimary, AppColors.text);
      expect(theme.colorScheme.onSecondary, AppColors.text);
      expect(theme.colorScheme.onError, AppColors.text);
      expect(theme.colorScheme.onSurface, AppColors.text);
    });

    test('TextButton usa texto preto', () {
      final style = theme.textButtonTheme.style!;
      expect(style.foregroundColor!.resolve(states), AppColors.text);
      expect(style.textStyle!.resolve(states)!.fontWeight, FontWeight.w700);
    });

    test('Filled/Elevated/Outlined: fundo pastel ou branco + texto preto', () {
      for (final style in [
        theme.filledButtonTheme.style!,
        theme.elevatedButtonTheme.style!,
        theme.outlinedButtonTheme.style!,
      ]) {
        final bg = style.backgroundColor!.resolve(states)!;
        final fg = style.foregroundColor!.resolve(states)!;
        expect(fg, AppColors.text);
        expect(contrastRatio(fg, bg), greaterThanOrEqualTo(4.5));
        expect(style.side!.resolve(states)!.color, AppColors.outline);
      }
    });

    test('Dialog: cartão branco, contorno, texto preto', () {
      final dialog = theme.dialogTheme;
      expect(dialog.backgroundColor, AppColors.card);
      expect(dialog.titleTextStyle!.color, AppColors.text);
      expect(dialog.contentTextStyle!.color, AppColors.text);
      final shape = dialog.shape as RoundedRectangleBorder;
      expect(shape.side.color, AppColors.outline);
      expect(shape.side.width, 2);
    });

    test('TabBar: rótulos legíveis, indicador amarelo', () {
      final tabs = theme.tabBarTheme;
      expect(tabs.labelColor, AppColors.text);
      expect(tabs.unselectedLabelColor, AppColors.textSecondary);
      final indicator = tabs.indicator as UnderlineTabIndicator;
      expect(indicator.borderSide.color, AppColors.primary);
      expect(indicator.borderSide.width, 4);
    });

    test('SnackBar e Chip: texto preto sobre o preenchimento', () {
      expect(theme.snackBarTheme.backgroundColor, AppColors.card);
      expect(theme.snackBarTheme.contentTextStyle!.color, AppColors.text);
      expect(theme.chipTheme.backgroundColor, AppColors.primary);
      expect(theme.chipTheme.labelStyle!.color, AppColors.text);
    });

    test('erro de formulário usa errorText, não o rosa de fundo', () {
      expect(theme.inputDecorationTheme.errorStyle!.color, AppColors.errorText);
    });
  });
}
