import 'package:flutter/material.dart';

/// Paleta do design system do Bingo ("neo-brutalista pastel").
///
/// Regra de ouro: amarelo e pastéis são PREENCHIMENTO, nunca texto. Texto é
/// sempre [text] (preto) sobre os preenchimentos, ou um dos tokens `*Text`
/// abaixo sobre [surface]/[card]. Todos os pares usados pelo tema são
/// verificados em `test/unit/color_contrast_test.dart` (WCAG AA ≥ 4.5:1).
class AppColors {
  AppColors._(); // This class is not meant to be instantiated.

  // ------------------------------------------------------- preenchimentos
  static const Color primary = Color(0xFFFFEB3B);
  static const Color secondary = Color(0xFF4FC3F7);
  static const Color success = Color(0xFFAED581);
  static const Color error = Color(0xFFFF8A80);
  static const Color surface = Color(0xFFFFFDF5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFF121212);
  static const Color background = Color(0xFFFFFDF5); // Same as surface
  static const Color disabled = Color(0xFFBDBDBD); // Botões desabilitados

  /// Fundo de avisos (caixa "mesma rede Wi-Fi" etc.). Par com [warningText].
  static const Color warningBackground = Color(0xFFFFF3E0);

  // ------------------------------------------------------------------ texto
  static const Color text = Color(0xFF121212); // Same as outline

  /// Texto sobre [primary], [secondary], [success], [error] e [card]: preto.
  static const Color onPrimary = text;

  /// Cinza para texto secundário. 4.5:1 em [surface] e [card]; não usar
  /// sobre os preenchimentos pastéis.
  static const Color textSecondary = Color(0xFF757575);

  /// Âmbar escuro: a única forma de "amarelo" permitida como texto ou ícone
  /// sobre [surface]/[card] (6.1:1). O amarelo [primary] puro fica em 1.2:1.
  static const Color accentText = Color(0xFF7A5D00);

  /// Texto de aviso sobre [warningBackground] (6.2:1) ou [surface] (6.7:1).
  static const Color warningText = Color(0xFF8A4B00);

  /// Texto de erro sobre [surface]/[card] (6.4:1). O rosa [error] é só fundo.
  static const Color errorText = Color(0xFFB3261E);

  // Bingo Header Pastels
  static const Color pastelRed = Color(0xFFEF9A9A);
  static const Color pastelOrange = Color(0xFFFFCC80);
  static const Color pastelYellow = Color(0xFFFFF59D);
  static const Color pastelGreen = Color(0xFFA5D6A7);
  static const Color pastelBlue = Color(0xFF90CAF9);
}
